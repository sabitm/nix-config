{ config, lib, pkgs, ... }:

{
  # Enable kanata
  services.kanata.enable = true;
  services.kanata.keyboards.default = {
    devices = [
      "/dev/input/by-id/usb-SEJIN_SEJIN_USB_joint_Keyboard-event-kbd"
      "/dev/input/by-id/usb-Compx_2.4G_Receiver-if01-event-mouse"
      "/dev/input/by-path/platform-i8042-serio-0-event-kbd"
    ];
    extraDefCfg = "process-unmapped-keys yes";
    config = ''
      (defsrc
        caps lctl rsft
      )

      (deflayer default
        @cap lmet @rsf
      )

      (defalias
        cap (tap-hold-press 200 200 esc lctl)
        rsf (tap-hold-press 200 200 caps rsft)
      )
    '';
  };
}
