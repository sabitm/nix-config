# nix-config

NixOS flake configuration for a single user (`sabit`) across multiple hosts.
Structured with the dendritic pattern on top of flake-parts: every `.nix` file
under `modules/` is a flake-parts module, auto-imported by `import-tree`, and
features compose by contributing to shared aggregates.

## Repository Layout

```
flake.nix              thin entry point: mkFlake (import-tree ./modules)
config.nix             canonical personal config: { username = "sabit"; }
modules/               import-tree root; EVERY .nix file here is a flake-parts module
  flake/
    options.nix        declares the merging flake.modules.<class>.<name> option
    systems.nix        systems list + perSystem pkgs (allowUnfree)
    lib.nix            flake.lib: username (from config.nix) + mkHost helper
    packages.nix       perSystem.packages (custom derivations)
  system/              NixOS-class feature modules
    base.nix           nixos.base: universal system config
    home-manager.nix   nixos.base += home-manager integration
    kanata.nix         nixos.base += kanata keyboard remapper
    desktop.nix        nixos.desktop: fonts, wl-clipboard; wires in homeManager.desktop
    gnome.nix          nixos.desktop += GNOME/GDM
    secrets.nix        nixos.secrets: sops; wires in homeManager.secrets
    remote-builder.nix nixos.remote-builder
  home/                home-manager-class feature modules
    base.nix, cli.nix, fish.nix, ...   homeManager.base (universal home)
    chrome.nix, ghostty.nix, gnome.nix, mpv.nix   homeManager.desktop (GUI)
    sops.nix, rclone.nix, yt-viewer.nix           homeManager.secrets
  hosts/
    lbox.nix           builds nixosConfigurations base + lbox
    vbox.nix           builds nixosConfigurations vbox + vbox-min
hosts/                 raw NixOS modules OUTSIDE the import-tree (never flake-parts modules)
  lbox/                physical machine (ZFS, DroidCam) hardware + host specifics
  vbox/                VM hardware + host specifics (shared by vbox and vbox-min)
packages/              custom derivations (callPackage), referenced by modules/flake/packages.nix
data/                  raw config files linked into place; never evaluated as Nix
scripts/               shell utilities for bootstrapping and remote builds
```

`hosts/`, `packages/`, and `data/` live outside `modules/` on purpose: `import-tree`
treats everything under `modules/` as a flake-parts module, whereas these are plain
NixOS modules, derivations, and raw files respectively.

## Dendritic Pattern

`modules/flake/options.nix` declares `flake.modules.<class>.<name>` as a
`lazyAttrsOf (lazyAttrsOf deferredModule)`. Because the leaf type is
`deferredModule`, every file that sets the same path is merged into one combined
module. So a feature file just declares its contribution:

```nix
{ ... }:
{
  flake.modules.homeManager.base = { pkgs, ... }: { /* a home-manager module */ };
}
```

`import-tree ./modules` feeds all such files to flake-parts; the matching
declarations across the tree merge per aggregate. Hosts then pull aggregates in
via `mkHost`. Stock flake-parts treats unknown `flake.*` attributes as
non-merging raw values, which is why the explicit option declaration is required.

## Aggregates

```
flake.modules.nixos.base            boot, nix, networking, user, fish, docker, kanata,
                                    nix-ld; + home-manager integration (wires homeManager.base)
flake.modules.nixos.desktop         GNOME/GDM, fonts, wl-clipboard; wires homeManager.desktop
flake.modules.nixos.secrets         sops-nix (system + home side); wires homeManager.secrets
flake.modules.nixos.remote-builder  SSH builder + aarch64 emulation (SSH not started on boot)

flake.modules.homeManager.base      home basics, shell, git, cli + dev tooling, yazi, editor
flake.modules.homeManager.desktop   chrome, ghostty, GNOME dconf/gtk, mpv
flake.modules.homeManager.secrets   rclone, youtube-viewer (sops-backed)
```

Each `nixos.*` aggregate that has a home-side counterpart wires it into
`home-manager.users.<user>.imports`, so opting a host into `desktop` or `secrets`
pulls in both the system and home parts together.

## Hosts

Built by `mkHost` in `modules/hosts/{lbox,vbox}.nix`.

| Name       | Hardware     | desktop | secrets | remote-builder | Notes                          |
|------------|--------------|---------|---------|----------------|--------------------------------|
| `base`     | `hosts/lbox` | yes     | no      | yes            | lbox hardware, build/test target |
| `lbox`     | `hosts/lbox` | yes     | yes     | yes            | full physical machine          |
| `vbox`     | `hosts/vbox` | yes     | yes     | no             | VM, full desktop               |
| `vbox-min` | `hosts/vbox` | no      | yes     | no             | VM, minimal/server, no DE/GUI  |

`lbox` specifics: ZFS pool `tank0`, `/var/lib/docker` on a zvol, v4l2loopback for
DroidCam (port 4747), acts as remote builder. `vbox-min` shares `vbox`'s hardware
config; its hostname differs because it comes from `myconf`, not the hardware file.

## `mkHost`

```nix
config.flake.lib.mkHost {
  hostname,            # per-host; merged into myconf and used as networking.hostName source
  hostModule,          # path to hosts/<h> (hardware + host specifics)
  desktop  ? true,     # include nixos.desktop
  withSops ? true,     # include nixos.secrets
  extraModules ? [ ],  # e.g. [ config.flake.modules.nixos.remote-builder ]
}
```

Always includes `nixos.base`. Adds `nixos.desktop` / `nixos.secrets` per the flags,
then appends `extraModules`. Passes `specialArgs.myconf` (and `inputs`) to NixOS
modules; home-manager receives `myconf` via `extraSpecialArgs`.

## `myconf` Pattern

`config.nix` exports personal fields (currently `{ username }`). `mkHost` merges
`hostname` per host (`myconf = import ./config.nix // { inherit hostname; }`) and
passes the result to every NixOS and home-manager module. Access it as a regular
argument: `{ myconf, ... }`. Add a field to `config.nix` and it flows everywhere.

## `data/` Convention

Raw dotfiles and config files live under `data/`. Modules link them into place via
`home.file`, `xdg.configFile`, or `xdg.dataFile`. They are never imported or
evaluated as Nix expressions.

## Secrets

Managed by sops-nix (the `secrets` aggregate). Secrets repo expected at
`~/nix-secret/`. Age key is derived from `~/.ssh/id_ed25519` and stored at
`~/.config/sops/age/keys.txt`. `sops.validateSopsFiles = false` — the secrets repo
is external and not present at eval time.

## Custom Packages

Derivations in `packages/` are exposed as `perSystem.packages` (see
`modules/flake/packages.nix`). Install with:

```shell
nix profile install .#<package-name>
```

Current packages: `crossover`, `elyprismlauncher`, `freedownloadmanager`,
`gtranslate`, `hurl`, `kiro`, `postman9`, `rbw`, `spread`, `steam-run`,
`whatsapp-web`.

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
