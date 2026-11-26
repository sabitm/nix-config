from contextlib import contextmanager
import hashlib
import os
from pathlib import Path
import shutil
import stat
import struct
import subprocess
import sys
import tempfile
import time

AGENT = "hexnode_agent.service"
INSTALLED = Path("/usr/local/bin/hexnode_agent")
DOWNLOAD = Path("/tmp/new_hexnode_agent")
HEALTH_SECONDS = 15
ELF_HEADER = struct.Struct("<16sHHIQQQIHHHHHH")
PROGRAM_HEADER = struct.Struct("<IIQQQQQQ")


@contextmanager
def checked_binary(path):
    fd = os.open(path, os.O_RDONLY | os.O_NOFOLLOW | os.O_NONBLOCK)
    with os.fdopen(fd, "rb") as file:
        st = os.fstat(file.fileno())
        if not (
            stat.S_ISREG(st.st_mode)
            and st.st_uid == st.st_gid == 0
            and not st.st_mode & 0o022
            and st.st_nlink == 1
            and 0 < st.st_size <= 256 * 1024 * 1024
        ):
            raise ValueError(f"Unsafe agent file: {path}")
        yield file, st


def validate_elf(file, size):
    data = file.read(ELF_HEADER.size)
    if len(data) != ELF_HEADER.size:
        raise ValueError("Truncated ELF header")
    ident, kind, machine, version, _, offset, _, _, _, entry_size, count, *_ = ELF_HEADER.unpack(data)
    if not (
        ident.startswith(b"\x7fELF\x02\x01\x01")
        and kind in (2, 3)
        and machine == 62
        and version == 1
        and offset >= ELF_HEADER.size
        and entry_size == PROGRAM_HEADER.size
        and 0 < count <= 128
        and offset + count * entry_size <= size
    ):
        raise ValueError("Expected an x86-64 ELF executable")
    file.seek(offset)
    executable_segment = False
    for _ in range(count):
        kind, flags, offset, _, _, length, _, _ = PROGRAM_HEADER.unpack(file.read(entry_size))
        if kind == 1:
            if offset + length > size:
                raise ValueError("Truncated ELF load segment")
            executable_segment |= bool(length and flags & 1)
    if not executable_segment:
        raise ValueError("ELF has no executable segment")
    file.seek(0)


def digest(file):
    return hashlib.file_digest(file, "sha256").digest()


def systemctl(*args, check=True, **kwargs):
    return subprocess.run(["systemctl", *args], check=check, timeout=30, **kwargs)


def start_and_check(verb="start"):
    systemctl(verb, AGENT)
    pid = None
    until = time.monotonic() + HEALTH_SECONDS
    while True:
        output = systemctl(
            "show", "-p", "ActiveState", "-p", "MainPID", AGENT,
            text=True, capture_output=True,
        ).stdout
        state = dict(line.split("=", 1) for line in output.splitlines())
        current = int(state.get("MainPID", "0"))
        if state.get("ActiveState") != "active" or not current or pid not in (None, current):
            raise RuntimeError("Agent did not remain active")
        if time.monotonic() >= until:
            return
        pid = current
        time.sleep(1)


def install(download, installed):
    work = Path(tempfile.mkdtemp(prefix=".hexnode-update-", dir=installed.parent))
    candidate = work / "candidate"
    backup = work / "previous"
    preserve_backup = False
    replaced = False
    try:
        with checked_binary(download) as (source, before), candidate.open("xb") as pending:
            shutil.copyfileobj(source, pending)
            after = os.fstat(source.fileno())
            if (before.st_size, before.st_mtime_ns, before.st_ctime_ns) != (
                after.st_size, after.st_mtime_ns, after.st_ctime_ns
            ) or pending.tell() != before.st_size:
                raise ValueError("Agent download changed during staging")
            os.fchmod(pending.fileno(), 0o755)
            pending.flush()
            os.fsync(pending.fileno())

        with candidate.open("rb") as pending, checked_binary(installed) as (old, _):
            validate_elf(pending, before.st_size)
            if digest(pending) == digest(old):
                print("Agent binary is unchanged. Skipping update.", flush=True)
                return

        # Work and the installed binary are on the same filesystem, so replacement is atomic.
        os.link(installed, backup, follow_symlinks=False)
        try:
            systemctl("stop", AGENT)
            os.replace(candidate, installed)
            replaced = True
            start_and_check()
        except (OSError, ValueError, RuntimeError, subprocess.SubprocessError) as error:
            print(f"Update failed: {error}. Restoring the previous agent.", file=sys.stderr, flush=True)
            if replaced:
                preserve_backup = True
                os.replace(backup, installed)
                preserve_backup = False
            start_and_check("restart" if replaced else "start")
            raise RuntimeError("Update failed and the previous agent was restarted") from error
        print("Updated agent stayed active during the startup check.", flush=True)
    finally:
        if preserve_backup:
            print(f"Previous binary retained at {backup}", file=sys.stderr, flush=True)
        else:
            shutil.rmtree(work)


if __name__ == "__main__":
    # Let the agent send its action result before stopping it, as the vendor launcher does.
    time.sleep(10)
    install(DOWNLOAD, INSTALLED)
