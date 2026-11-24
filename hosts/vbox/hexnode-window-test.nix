{ lib, pkgs, ... }:

let
  wrapper = pkgs.writeTextFile {
    name = "hexnode-window-systemctl";
    destination = "/bin/systemctl";
    executable = true;
    text = ''
      #!${pkgs.runtimeShell} -p
      export PATH=${lib.makeBinPath [ pkgs.coreutils pkgs.gnugrep pkgs.systemd ]}
      ${builtins.readFile ./hexnode-window-systemctl}
    '';
    checkPhase = "${pkgs.runtimeShell} -n \"$target\"";
  };
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
      PATH = lib.mkForce "${wrapper}/bin:/run/current-system/sw/bin:/run/wrappers/bin";
    };
    serviceConfig = {
      Type = "simple";
      ExecStart = "/usr/local/bin/hexnode_agent";
      ExecStopPost = "${wrapper}/bin/systemctl cleanup";
      Restart = "no";
      RuntimeDirectory = "hexnode-window-staging";
      RuntimeDirectoryMode = "0700";
      # Only the agent sees a writable directory at its hard-coded unit path.
      BindPaths = "/run/hexnode-window-staging:/etc/systemd/system";
    };
  };

  systemd.services.hexnode-window-test-start = callback "start";
  systemd.services.hexnode-window-test-stop = callback "stop";
}
