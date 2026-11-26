{ lib, pkgs, ... }:

let
  mkWrapper = name: command: runtimeInputs: source:
    pkgs.writeTextFile {
      inherit name;
      destination = "/bin/${command}";
      executable = true;
      text = ''
        #!${pkgs.runtimeShell} -p
        export PATH=${lib.makeBinPath runtimeInputs}
        ${builtins.readFile source}
      '';
      checkPhase = "${pkgs.runtimeShell} -n \"$target\"";
    };
  timerWrapper = mkWrapper "hexnode-window-systemctl" "systemctl"
    [ pkgs.coreutils pkgs.gnugrep pkgs.systemd ] ./hexnode-window-systemctl;
  updaterWrapper = mkWrapper "hexnode-update-systemd-run" "systemd-run"
    [ pkgs.systemd ] ./hexnode-update-systemd-run;
  callback = edge: {
    description = "Hexnode maintenance window ${edge} (log-only test)";
    serviceConfig = {
      Type = "oneshot";
      DynamicUser = true;
      NoNewPrivileges = true;
      ExecStart = "${pkgs.coreutils}/bin/echo Hexnode maintenance window ${edge} (log-only test)";
    };
  };
in
{
  systemd.services.hexnode_agent = {
    description = "Hexnode Linux Agent Service";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    unitConfig.ConditionPathExists = [
      "/usr/local/bin/hexnode_agent"
      "/etc/hexnode_agent/config.enc"
    ];
    environment = {
      NIX_LD = "/run/current-system/sw/share/nix-ld/lib/ld.so";
      NIX_LD_LIBRARY_PATH = "/run/current-system/sw/share/nix-ld/lib";
      LD_LIBRARY_PATH = lib.makeLibraryPath [ pkgs.glib ];
      PATH = lib.mkForce (lib.makeBinPath [ timerWrapper updaterWrapper ] + ":/run/current-system/sw/bin:/run/wrappers/bin");
    };
    serviceConfig = {
      Type = "simple";
      ExecStart = "/usr/local/bin/hexnode_agent";
      ExecStopPost = "${timerWrapper}/bin/systemctl cleanup";
      Restart = "no";
      RuntimeDirectory = "hexnode-window-staging";
      RuntimeDirectoryMode = "0700";
      # Only the agent sees a writable directory at its hard-coded unit path.
      BindPaths = "/run/hexnode-window-staging:/etc/systemd/system";
    };
  };

  systemd.services.hexnode-agent-safe-update = {
    description = "Replace the Hexnode agent with rollback on startup failure";
    environment.PATH = lib.mkForce (lib.makeBinPath [ pkgs.systemd ]);
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.python3}/bin/python3 -I -B ${./hexnode-update-agent.py}";
      TimeoutStartSec = "3min";
      NoNewPrivileges = true;
      ProtectSystem = "strict";
      ReadWritePaths = [ "/usr/local/bin" ];
    };
  };

  systemd.services.hexnode-window-test-start = callback "start";
  systemd.services.hexnode-window-test-stop = callback "stop";
}
