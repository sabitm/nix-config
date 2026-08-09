# nix-config

Single-user (`sabit`) NixOS flake using flake-parts, `import-tree`, and dendritic
module aggregation. Supported system: `x86_64-linux`.

## Layout

```text
flake.nix          flake-parts entry point; imports ./modules
config.nix         shared personal values (`username`)
modules/flake/     aggregate option, systems, mkHost, package outputs
modules/system/    contributions to reusable NixOS aggregates
modules/home/      contributions to reusable home-manager aggregates
modules/hosts/     nixosConfigurations assembled with mkHost
hosts/             raw host/hardware NixOS modules
packages/          local callPackage derivations
data/              raw configuration files linked by home-manager
scripts/           bootstrap and remote-build utilities
```

Every `.nix` file under `modules/` is auto-imported and must be a flake-parts
module. Keep raw NixOS modules, derivations, and data outside that directory.

## Module Model

`modules/flake/options.nix` declares
`flake.modules.<class>.<name>` as nested lazy attribute sets of
`deferredModule`. Files can therefore contribute independently to the same
aggregate, for example:

```nix
flake.modules.homeManager.base = { pkgs, ... }: { /* contribution */ };
```

Current aggregates:

| Aggregate | Contents |
|---|---|
| `nixos.base` | Core system, user, networking, Docker, fish, nix-ld, zram, kanata; wires `homeManager.base` |
| `nixos.desktop` | GNOME/GDM, fonts, clipboard; wires `homeManager.desktop` |
| `nixos.secrets` | sops-nix system/home integration; wires `homeManager.secrets` |
| `nixos.ssh` | OpenSSH started at boot |
| `nixos.remote-builder` | OpenSSH started manually, trusted build user, aarch64 emulation |
| `homeManager.base` | Home basics, shell, Git, CLI/dev tools, editor, yazi |
| `homeManager.desktop` | Chrome, Ghostty, GNOME settings, mpv |
| `homeManager.secrets` | sops-backed rclone and youtube-viewer configuration |

## Hosts

| Name | Hardware | Desktop | Secrets | SSH | Notes |
|---|---|---:|---:|---|---|
| `base` | `hosts/lbox` | yes | no | manual | lbox build/test target; remote builder |
| `lbox` | `hosts/lbox` | yes | yes | manual | full physical host; remote builder |
| `vbox` | `hosts/vbox` | yes | yes | no | full VM |
| `vbox-min` | `hosts/vbox` | no | yes | boot | minimal/server VM |

`lbox` uses ZFS pool `tank0`, an ext4 Docker zvol, and v4l2loopback/DroidCam on
port 4747. `vbox-min` disables base zram and raises AMDGPU GTT limits to about
13 GiB through `ttm.pages_limit` and `ttm.page_pool_size`.

## Host Construction

`config.flake.lib.mkHost` accepts:

```nix
{
  hostname,
  hostModule,
  desktop ? true,
  withSops ? true,
  extraModules ? [ ],
}
```

It always includes `nixos.base`, conditionally adds `desktop` and `secrets`, then
appends `extraModules`. It merges `hostname` into `config.nix` as `myconf` and
passes it to NixOS and home-manager modules. Add shared personal values to
`config.nix`; consume them through a `{ myconf, ... }` module argument.

## Repository Conventions

- Link files under `data/` with `home.file`, `xdg.configFile`, or
  `xdg.dataFile`; do not evaluate them as Nix modules.
- Secrets live outside the repository at `~/nix-secret`. Home sops derives its
  age identity from `~/.ssh/id_ed25519`, stores it at
  `~/.config/sops/age/keys.txt`, and disables source-file validation.
- `modules/flake/packages.nix` exports local derivations from `packages/` plus
  `nix-index-database` from its flake input. Current local outputs are
  `crossover`, `droidcam`, `elyprismlauncher`, `freedownloadmanager`,
  `gtranslate`, `postman9`, `rbw`, `spread`, `steam-run`, and `whatsapp-web`.
