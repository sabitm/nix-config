## Getting Started

### Nix Install

1. Start `wpa_supplicant` service

```
sudo systemctl start wpa_supplicant
```

1. Run `wpa_cli`

```
add_network
0
set_network 0 ssid "myhomenetwork"
OK
set_network 0 psk "mypassword"
OK
enable_network 0
OK
```

1. Partitioning and formatting

```
parted /dev/sda -- mklabel gpt
parted /dev/sda -- mkpart root ext4 512MB -8GB
parted /dev/sda -- mkpart ESP fat32 1MB 512MB
parted /dev/sda -- set 3 esp on
```

```
mkfs.ext4 -L nixos /dev/sda1
mkfs.fat -F 32 -n boot /dev/sda3
```

1. Installing NixOS

```
mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot
mount -o umask=077 /dev/disk/by-label/boot /mnt/boot
```

```
nixos-generate-config --root /mnt
nixos-install --flake 'path/to/flake.nix#nixos'
```

```
nixos-enter --root /mnt -c 'passwd sabit'
```

### Getting SSH keys from Bitwarden

Add experimental feature into nix configuration if needed

```shell
./scripts/add-exp-feat
```

Activate `nix shell` with current flake `rbw` package

```shell
nix shell .#rbw
```

Inside the shell, add email and login to bitwarden

```shell
# Add email into configuration
rbw config set email "example@email.com"
# Attempt login
rbw login
```

And then execute the scripts

```shell
# Get ssh key from bitwarden
./scripts/get-ssh-key
# Generate sops age key from ssh key
./scripts/gen-sops-age
# Print public key of user and host
./scripts/get-age-pubkey
```

### Edit `config.nix`

Before evaluating nix config, edit `config.nix` according to your needs.

### Running nix config

Build nix config and switch using command below:

```shell
sudo nixos-rebuild switch --flake .#<name>
```

Where `<name>` is the name of your configuration.

## Remote Build

One machine acts as the builder (host), the other offloads builds to it (client).

### Host setup

Import `modules/system/remote-builder.nix` in the host's configuration. This configures SSH and enables aarch64 emulation, but SSH does not start on boot.

Toggle SSH on the host when needed:

```shell
./scripts/nb-host start   # open SSH for incoming builds
./scripts/nb-host stop    # close when done
./scripts/nb-host status  # check current state
```

### Client usage

```shell
./scripts/nb-client <host> <nixos-rebuild args> [--user <user>]
```

Examples:

```shell
# Build and switch using lbox as the remote builder
./scripts/nb-client lbox switch --flake .#min

# Override the SSH user (defaults to sabit)
./scripts/nb-client lbox switch --flake .#min --user john
```

The script checks SSH connectivity first and exits with an error if the host is unreachable.

## Installing Packages

To install packages from `packages` directory, simply head to one of package directory and run:

```shell
nix profile install .#<package-name>
```
