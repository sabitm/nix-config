{ config, lib, pkgs, ... }:

{
  # Enable yazi
  programs.yazi = {
    enable = true;
    plugins = {
      smart-switch = ../../data/yazi/plugins/smart-switch.yazi;
    };
    settings = {
      mgr = {
        show_hidden = true;
      };
    };
    flavors = {
      gruvbox-dark = ../../data/yazi/plugins/gruvbox-dark.yazi;
    };
    theme = {
      dark = "gruvbox-dark";
    };
    keymap = {
      mgr.prepend_keymap = [
        { on = "Q"; run = "quit"; desc = "Quit the process"; }
        { on = "q"; run = "quit --no-cwd-file"; desc = "Quit the process without outputting cwd-file"; }

        # Using '' for shell commands
        { on = "!"; run = ''shell "$SHELL" --block''; desc = "Open shell here"; }
        { on = "O"; run = "plugin open-with-cmd block"; desc = "Open with in terminal"; }

        { on = "2"; run = "plugin smart-switch 1"; desc = "Switch or create tab 2"; }
        { on = "3"; run = "plugin smart-switch 2"; desc = "Switch or create tab 3"; }
        { on = "4"; run = "plugin smart-switch 3"; desc = "Switch or create tab 4"; }

        # TOML's array [ "g", "/" ] becomes a Nix list [ "g" "/" ]
        { on = [ "g" "/" ]; run = "cd /"; desc = "Go to root dir"; }
        { on = [ "g" "b" ]; run = ''cd "$ORIGIN"''; desc = "Go back to origin dir"; }
        { on = [ "g" "l" ]; run = ''cd "~/.local"''; desc = "Go to ~/.local"; }
      ];
      input.prepend_keymap = [
        { on = "<Esc>"; run = "close"; desc = "Cancel input"; }
      ];
    };
  };
}
