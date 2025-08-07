{ config, lib, pkgs, ... }:

{
  imports = [
    ./subs/kanata.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Change /tmp to use tmpfs
  boot.tmp.useTmpfs = true;

  # Networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Jakarta";

  # Enable GNOME
  services.desktopManager.gnome.enable = true;
  services.displayManager.gdm.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.sabit = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
    shell = pkgs.fish;
  };

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    adbfs-rootless
    android-tools
    fd
    gcc
    git
    go
    lazygit
    neovim
    nodejs
    php
    python3
    ripgrep
    unzip
    wl-clipboard
    yazi
  ];

  # Set environment variable
  environment.variables = {
    EDITOR = "nvim";
  };

  # Enable fish
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

  # Allow unfree package
  nixpkgs.config.allowUnfree = true;

  # Allow insecure packages
  nixpkgs.config.permittedInsecurePackages = [
    # For postman9
    "openssl-1.1.1w"
  ];

  # Nix settings
  nix = {
    settings = {
      auto-optimise-store = true;
      # Change build-dir to avoid memory exhaustion
      build-dir = "/var/tmp";
      experimental-features = [ "nix-command" "flakes" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "–delete-older-than 45d";
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
