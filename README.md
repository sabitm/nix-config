## Getting Started

### Nix Install

1. Start `wpa_supplicant` service

```shell
sudo systemctl start wpa_supplicant
```

1. Run `wpa_cli`

```shell
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

```shell
parted /dev/sda -- mklabel gpt
parted /dev/sda -- mkpart root ext4 512MB -8GB
parted /dev/sda -- mkpart ESP fat32 1MB 512MB
parted /dev/sda -- set 3 esp on
```

```shell
mkfs.ext4 -L nixos /dev/sda1
mkfs.fat -F 32 -n boot /dev/sda3
```

1. Installing NixOS

```shell
mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot
mount -o umask=077 /dev/disk/by-label/boot /mnt/boot
```

```shell
# Generate hardware config that you can copy to flake
nixos-generate-config --root /mnt
```

```shell
nixos-install --flake 'path/to/flake.nix#nixos'
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

Reuild your system using command below:

```shell
sudo nixos-rebuild switch --flake .#<name>
```

Where `<name>` is the name of your flake config.

## Remote Build and Substituter

One machine acts as the builder and substituter (host), the other offloads builds to it (client).

### Host setup

Import `modules/system/remote-builder.nix` in the host's configuration. This configures SSH and enables aarch64 emulation, but SSH does not start on boot.

Toggle SSH on the host when needed:

```shell
./scripts/nb-host start   # open SSH for incoming builds
./scripts/nb-host stop    # close when done
./scripts/nb-host status  # check current state
```

### Client usage

Both scripts check SSH connectivity first and exit with an error if the host is unreachable. The host is used as both a remote builder and a local substituter (checked before `cache.nixos.org` to save bandwidth).

**Rebuilding an existing system:**

```shell
./scripts/nb-client <host> <nixos-rebuild args> [--user <user>]
```

```shell
./scripts/nb-client lbox switch --flake .#base
./scripts/nb-client lbox switch --flake .#base --user john
```

**Installing onto a new system (e.g. from a live USB):**

```shell
./scripts/nb-install <host> <nixos-install args> [--user <user>]
```

```shell
./scripts/nb-install lbox --flake /mnt/etc/nixos#myhost --root /mnt
./scripts/nb-install lbox --flake /mnt/etc/nixos#myhost --root /mnt --user john
```

The host's root SSH key must be authorized on the builder. Run `./scripts/get-ssh-key` on the client to ensure `/root/.ssh/id_ed25519` is populated.

## Installing Packages

To install packages from `packages` directory, simply run:

```shell
nix profile install .#<package-name>
```
