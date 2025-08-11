# Getting Started

## Getting SSH keys from bitwarden-cli

Activate nix-shell with bitwarden-cli and jq package

```shell
nix-shell -p bitwarden-cli jq
```

Inside the shell, login to bitwarden

```shell
bw login
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

## Edit `config.nix`

Before evaluating nix config, edit `config.nix` according to your needs.

## Running nix config

Build nix config and switch using command below:

```shell
sudo nixos-rebuild switch --flake .#<name>
```

Where `<name>` is the name of your configuration.
