{ config, pkgs, myconf, ... }:

{
  imports = [
    ./system/gnome.nix
    ./system/kanata.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Change /tmp to use tmpfs
  boot.tmp.useTmpfs = true;

  # Enable zram
  zramSwap.enable = true;

  # Networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Jakarta";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."${myconf.username}" = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
    shell = pkgs.fish;
  };

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    git
    neovim
    unzip
    wl-clipboard
  ];

  # Set environment variable
  environment.variables = {
    EDITOR = "nvim";
  };

  # Default shell
  programs.fish.enable = true;

  # Enable nix-ld to support traditional FHS
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # Lib here
  ];

  # Add nerd font
  fonts.packages = with pkgs; [
    meslo-lgs-nf
  ];

  # Enable docker
  virtualisation.docker.enable = true;

  # Nixpkgs config
  nixpkgs.config = {
    # Allow unfree package
    allowUnfree = true;
  };

  # Nix settings
  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 45d";
    };
  };

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Did you read the comment?
}
