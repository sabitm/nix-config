# nix-config

NixOS flake configuration for a single user (`sabit`) across multiple hosts.

## Repository Layout

```
flake.nix              entry point; defines nixosConfigurations and packages outputs
config.nix             personal config: currently only { username = "sabit"; }
hosts/
  lbox/               physical machine (ZFS, DroidCam, remote-builder SSH)
  vbox/               VM, minimal
modules/
  system.nix          shared NixOS config imported by all hosts
  base.nix            shared home-manager config (the base layer)
  home.nix            extends base.nix with sops, rclone, yt-viewer
  home/               leaf home-manager modules (one concern each)
  system/             leaf NixOS modules (gnome, kanata, remote-builder)
packages/             custom derivations not in nixpkgs
data/                 raw config files linked into place; never evaluated as Nix
scripts/              shell utilities for bootstrapping and remote builds
```

## Hosts

| Name   | Config               | Home module    | Notes                                      |
|--------|----------------------|----------------|--------------------------------------------|
| `base` | `hosts/lbox`         | `modules/base.nix` | lbox hardware, no sops, minimal home   |
| `lbox` | `hosts/lbox`         | `modules/home.nix` | full config with secrets                |
| `vbox` | `hosts/vbox`         | `modules/home.nix` | VM, no ZFS, no remote-builder           |

`lbox` specifics: ZFS pool `tank0`, `/var/lib/docker` on a zvol, v4l2loopback for DroidCam (port 4747), acts as remote builder.

## Module Layering

```
home.nix
  └── base.nix
        └── home/{chrome,cli,fish,ghostty,git,gnome,misc,navi,neovim,nixpkgs,node,rust,yazi,zk}.nix
  (+ sops.nix, rclone.nix, yt-viewer.nix)

system.nix
  └── system/{gnome.nix, kanata.nix}

hosts/lbox also imports system/remote-builder.nix
```

## `myconf` Pattern

`config.nix` exports `{ username }`. The flake injects `hostname` per host and passes the merged attrset as `_module.args.myconf` to every module. Access it as a regular argument: `{ myconf, ... }`.

## `data/` Convention

Raw dotfiles and config files live under `data/`. Modules link them into place via `home.file`, `xdg.configFile`, or `xdg.dataFile`. They are never imported or evaluated as Nix expressions.

## Secrets

Managed by sops-nix. Secrets repo expected at `~/nix-secret/`. Age key is derived from `~/.ssh/id_ed25519` and stored at `~/.config/sops/age/keys.txt`. `sops.validateSopsFiles = false` — the secrets repo is external and not present at eval time.

## Custom Packages

Derivations in `packages/` are exposed under the `packages` flake output. Install with:

```shell
nix profile install .#<package-name>
```

Current packages: `crossover`, `elyprismlauncher`, `freedownloadmanager`, `gtranslate`, `hurl`, `kiro`, `postman9`, `rbw`, `spread`, `steam-run`, `whatsapp-web`.

## Common Commands

```shell
# Rebuild active host
sudo nixos-rebuild switch --flake .#lbox

# Remote build from client to lbox as builder
./scripts/nb-client lbox switch --flake .#base

# Install onto new system via lbox as builder
./scripts/nb-install lbox --flake /mnt/etc/nixos#myhost --root /mnt

# Manage remote-builder SSH on lbox (host side)
./scripts/nb-host start | stop | status
```

## Bootstrap Order (new machine)

1. Connect to Wi-Fi via `wpa_cli`.
2. Partition, format, generate hardware config.
3. `nixos-install --flake .#<host>` (or use `nb-install` if a builder is available).
4. Boot into new system; run `./scripts/get-ssh-key` to populate SSH keys from Bitwarden (`rbw`).
5. Run `./scripts/gen-sops-age` then `./scripts/get-age-pubkey` to set up sops age key.
