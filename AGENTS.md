# Dotfiles — AI Agent Guidelines & Architecture Rules

Declarative NixOS configuration managed as a Nix flake with Home Manager, built and deployed via `nh`.

**Read this file before touching anything.** It encodes hard safety rules (section 1), the module conventions this repo depends on (section 5), and how to verify work without mutating the system (section 9).

---

## 1. Safety & Execution Bounds (CRITICAL)

### MANUAL ACTIVATION ONLY

The user builds and activates system generations manually. The agent **builds and verifies nothing onto the live system**.

**NEVER run** (non-exhaustive, spirit over letter):

- `nh os build` / `nh os switch` / `nh os boot` / `nh os test`
- `nixos-rebuild` (any subcommand: `switch`, `boot`, `test`, `dry-activate`)
- `home-manager switch` / `home-manager build`
- `systemctl` (any verb), `reboot`, `poweroff`, `shutdown`
- `nixos-activation`, `switch-to-configuration`
- `nix-store --delete`, `nix-collect-garbage`, `nh clean`

**Allowed and encouraged** (read-only / pure evaluation):

- `read_file`, `search_files`, `git status`, `git diff`, `git log`
- `nix flake check` (pure evaluation)
- `nix eval .#nixosConfigurations.<host>...drvPath`
- `nix flake metadata`, `nix flake show`
- `nix run` / `nix shell` for a **tool** (formatter, linter) — it does not touch the current generation
- App-level validators: `niri validate`, `stylua --check`

### Dry Verification Only

| What changed | Verification |
| :--- | :--- |
| Any `.nix` file, `flake.nix`, `flake.lock`, modules, host configs | `nix flake check` **or** `nix eval .#nixosConfigurations.asus-tuf.config.system.build.toplevel.drvPath` |
| Raw configs under `config/`, assets, static text | **Skip `nix eval`.** Run the app's own validator (`niri validate`, `stylua --check`, JSON/KDL parsers) if one exists |
| `scripts/*.sh` | `bash -n` syntax check; the package still needs `nix eval` of the flake if `scripts/default.nix` changed |

Rebuilding or switching is reserved exclusively for the user. If a task seems to require a rebuild, stop and hand the command to the user as text.

### Working Tree Integrity

- Never discard uncommitted changes (`git restore`, `git checkout --`, `git reset --hard`, `git stash drop`) without explicit user permission.
- Always inspect `git status` and `git diff` first — the tree may carry staged work in progress (e.g. a new flake input) that is not yet committed.
- Never commit, amend, or push unless the user asks.

---

## 2. System Architecture & Target Environments

The repository defines two NixOS host configurations (`nixosConfigurations`), both built from shared modules under `hosts/common/`.

### Primary Target: `asus-tuf` (Daily Driver / Active)

- **Model**: ASUS TUF Gaming A15 (FA506NC). `x86_64-linux`, AMD CPU + NVIDIA GeForce RTX 3050.
- **Hardware integration**:
  - `nixos-hardware.nixosModules.asus-fa506nc`.
  - NVIDIA: `modesetting.enable = true`, `powerManagement.enable = true`, `nvidiaPersistenced = true`.
  - `boot.kernelParams = [ "acpi_backlight=native" ]`.
  - Power / battery: `services.asusd` (charge limit **70%**, Quiet on battery / Performance on AC, `disable_nvidia_powerd_on_battery = true`). `powerManagement.powertop.enable = false` on purpose — do not re-enable.
- **Filesystems**: NTFS `/mnt/Storage` via `ntfs3` (`nofail`), mounted by UUID.
- **Network**: NetworkManager + Cloudflare WARP (`services.cloudflare-warp.enable = true`).
- **Desktop**: Niri compositor + Noctalia shell bar, **Noctalia Greeter (`greetd`) as display manager**, Catppuccin Mocha (accent `blue`), Banana cursor (`size = 28`), Colloid-Dark icons, SDDM module exists but is *not* enabled on this host.
- **Input**: `keyd` swaps `Caps Lock` ⇄ `Esc` at hardware level; `fcitx5` + `fcitx5-lotus` (Vietnamese, Wayland) with `waydroid` for Android apps.
- **Display profile**: `kanshi` pins the internal panel to `1920x1080@144Hz`.
- **All new modules, packages and changes MUST target and be verified against `asus-tuf`.**

### Deprecated / Reference: `acer-aspire`

- **Status**: Legacy backup host, no longer actively used.
- **Guideline**: Do not build against it or introduce breaking changes for it, but **never break flake evaluation** for it (`nix flake check` must stay green).

---

## 3. Flake Design & Dependency Management

`flake.nix` is the single entrypoint. `system = "x86_64-linux"` is the reference platform; `supportedSystems` in the flake is `[ x86_64-linux aarch64-linux aarch64-darwin ]` for `packages`/`overlays` only.

### Inputs

| Input | URL | Notes |
| :--- | :--- | :--- |
| `nixpkgs` | `github:nixos/nixpkgs/nixos-unstable` | Root of the dependency graph |
| `catppuccin` | `github:catppuccin/nix` | follows `nixpkgs` |
| `nixos-hardware` | `github:nixos/nixos-hardware` | follows `nixpkgs` |
| `home-manager` | `github:nix-community/home-manager` | follows `nixpkgs` |
| `zen-browser` | `github:0xc000022070/zen-browser-flake` | follows `nixpkgs` **and** `home-manager` |
| `helium-flake` | `github:oxcl/nix-flake-helium-browser` | follows `nixpkgs` |
| `nix-index-database` | `github:nix-community/nix-index-database` | follows `nixpkgs` |
| `antigravity-nix` | `github:jacopone/antigravity-nix` | follows `nixpkgs` |
| `hermes-agent` | `github:NousResearch/hermes-agent` | follows `nixpkgs` **and** `home-manager` |

- **Consistency Rule (hard)**: every new input MUST declare `inputs.nixpkgs.follows = "nixpkgs"` (and `home-manager.follows = "home-manager"` if it consumes Home Manager) to avoid duplicate package closures in the Nix store.
- **Noctalia** is *not* a flake input: it comes from `pkgs.noctalia`, configured through the upstream NixOS/Home-Manager `noctalia` modules.

### Module wiring (zero-boilerplate)

```nix
scanModules = path:
  builtins.filter (p: baseNameOf p != "default.nix" && lib.hasSuffix ".nix" (toString p))
    (lib.filesystem.listFilesRecursive path);

nixosModulesList = scanModules ./modules/nixos;
homeModulesList  = scanModules ./modules/home-manager;
```

Both lists are appended to every `nixosConfigurations.<host>.modules`, and `homeModulesList` is additionally assigned to `home-manager.users.tai.imports`. `specialArgs = { inherit inputs self; }` (plus the same via `home-manager.extraSpecialArgs` in `hosts/common/core.nix`) — this is why every module can take `{ inputs, self, ... }` in its argument list.

### Outputs

- `packages.${system}` — `import ./scripts nixpkgs.legacyPackages.${system}` (see section 6).
- `overlays.default` — injects those scripts as `pkgs.myScripts.*`.
- `nixosConfigurations.asus-tuf`, `nixosConfigurations.acer-aspire` — both get `home-manager.nixosModules.default`; only `asus-tuf` adds `nixos-hardware.nixosModules.asus-fa506nc`.

### Lockfile

- Update with `nix flake update` from the repository root.
- **Never commit `flake.lock` in isolation.** Bundle a lock update with the commit that adds/updates the dependent package, module or input.

---

## 4. Repository Layout & File Wiring

```
.dotfiles/
├── flake.nix                # Entrypoint: inputs, scanModules, overlays, nixosConfigurations
├── flake.lock               # Pinned input hashes
├── assets/                  # icons/, wallpapers/, profile.jpg, screenshot.png
├── config/                  # Raw app configs consumed by modules (see table below)
│   ├── fcitx5/              # conf/*.conf + config + profile
│   ├── niri/config.kdl
│   ├── nvim/                # helper/ config/ plugin/ external/ snippets/
│   └── opencode/command/    # commit.md
├── hosts/
│   ├── common/core.nix      # Shared NixOS base (users, fonts, pipewire, catppuccin, home-manager)
│   ├── common/home.nix      # Shared HM base (cursor, gtk/qt, mimeApps, base packages)
│   ├── asus-tuf/            # configuration.nix + hardware.nix + home.nix  (ACTIVE)
│   └── acer-aspire/         # configuration.nix + hardware.nix + home.nix  (LEGACY)
├── modules/
│   ├── home-manager/
│   │   ├── app/             # anki, antigravity, ghostty, helium, hermes-desktop, mpv, obs, vesktop, zathura, zen-browser
│   │   ├── desktop/         # niri.nix
│   │   │   └── shell/       # noctalia.nix
│   │   └── programs/        # bat, eza, fcitx5, fish, fzf, git, kanshi, nh, nix-index, nvim, opencode, tmux, yazi, zoxide
│   └── nixos/
│       ├── program/         # fcitx5, localsend, steam, waydroid
│       └── service/         # keyd, noctalia-greeter, sddm
└── scripts/                 # default.nix + battery.sh, note.sh, rcc.sh
```

### Path Resolution Rules

- **CRITICAL**: NEVER hardcode absolute home paths (`/home/tai/...`) or local clone paths in Nix expressions.
- Reference everything through `self`:
  - `${self}/config/<app>/...`
  - `self + "/config/<app>"`
  - `${self}/assets/wallpapers/3.png`
  - `${self}/assets/icons/battery-full.svg` (used in `xdg.desktopEntries` icons)

### Configuration Consumption Patterns (`config/` → modules)

Check the existing module before wiring a new config. The repo uses three patterns deliberately:

1. **Directory symlink** — whole `config/<app>` tree linked as one unit.
   ```nix
   # modules/home-manager/desktop/niri.nix
   xdg.configFile."niri".source = self + "/config/niri";
   ```
2. **Inline via `builtins.readFile`** — Neovim Lua (`helper/*.lua`, `config/*.lua`, `plugin/*.lua`) is read into Nix strings and injected into Neovim options/plugin specs. Bespoke tooling files (`external/stylua.toml`, `external/clang-format`, `external/asm-lsp.toml`, `snippets/*.json`) are symlinked individually via `xdg.configFile`.
3. **Individual file symlink** — e.g. Fcitx5 links each conf file to `xdg.configFile."fcitx5/..."` rather than the whole directory.

Never convert one pattern into another opportunistically; each exists because the app behaves differently (e.g. Neovim needs `readFile` so Lua can be interpolated).

---

## 5. Module Development Patterns

### Auto-Discovery — no `default.nix`, no relative imports

- Every `.nix` file under `modules/nixos/` and `modules/home-manager/` is imported automatically by `scanModules`.
- **Never create a `default.nix`** inside `modules/` (it is filtered out and would be dead code).
- **Never** write `import ../../modules/...` in host configs or modules. Hosts only *declare option values*; `flake.nix` owns the wiring.

### Naming convention (hard)

The option path mirrors the file path, and **the file's basename is the last option segment**:

| File | Option namespace |
| :--- | :--- |
| `modules/home-manager/app/ghostty.nix` | `modules.home.app.ghostty` |
| `modules/home-manager/desktop/shell/noctalia.nix` | `modules.home.desktop.shell.noctalia` |
| `modules/nixos/program/steam.nix` | `modules.nixos.program.steam` |
| `modules/nixos/service/keyd.nix` | `modules.nixos.service.keyd` |

Categories in use: `home-manager` → `app/`, `programs/`, `desktop/` (and `desktop/shell/`); `nixos` → `program/`, `service/`. Stay inside an existing category unless there is a real reason not to.

### Standard template

```nix
{ config, lib, pkgs, ... }:
let
  cfg = config.modules.home.<category>.<name>;
in
{
  options.modules.home.<category>.<name> = {
    enable = lib.mkEnableOption "Enable <name> configuration";
  };

  config = lib.mkIf cfg.enable {
    # home.packages, xdg.configFile, programs.*, services.*
  };
}
```

Add `self` / `inputs` to the argument list only when the module actually uses them (e.g. `{ config, lib, pkgs, self, ... }`).

### Options beyond a bare `enable`

Modules may expose extra typed options next to `enable` — follow the existing style:

```nix
# modules/nixos/program/fcitx5.nix
users = lib.mkOption {
  type = lib.types.listOf lib.types.str;
  default = [ ];
  example = [ "tai" ];
  description = "…";
};
```

```nix
# modules/nixos/program/localsend.nix
openFirewall = lib.mkOption { type = lib.types.bool; default = true; };
```

### Specialisation pattern

Heavy / optional profiles are isolated behind a `useSpecialisation` boolean and `lib.mkMerge`, not enabled unconditionally (see `modules/nixos/program/steam.nix`):

```nix
config = lib.mkIf cfg.enable (
  lib.mkMerge [
    (lib.mkIf (!cfg.useSpecialisation) steamConfig)
    (lib.mkIf cfg.useSpecialisation { specialisation.gaming.configuration = steamConfig; })
  ]
);
```

### Auto-chains (do not duplicate work)

- `modules.home.programs.fish.enable` ⇒ also enables `fzf`, `zoxide`, `yazi`, `nix-index`.
- `modules.home.desktop.niri.enable` ⇒ also enables `modules.home.desktop.shell.noctalia` and sets the Wayland session variables.

### Where to enable a new module

Both host `home.nix` (Home Manager modules) and `configuration.nix` (NixOS modules) declare values in a single `modules = { ... }` block. `asus-tuf` is the host that must be updated; touch `acer-aspire` only if the change is genuinely shared.

---

## 6. Helper Scripts (`scripts/`)

- Shell source: `scripts/<name>.sh`.
- Packaging: `scripts/default.nix`, a `pkgs: { ... }` function using `pkgs.writeShellApplication` with **explicit `runtimeInputs`** and `text = builtins.readFile ./<name>.sh;`.

Registered scripts:

| Script | `runtimeInputs` | Exposed as |
| :--- | :--- | :--- |
| `note.sh` | `git`, `neovim`, `coreutils` | `pkgs.myScripts.note` |
| `rcc.sh` | `gcc` | `pkgs.myScripts.rcc` |
| `battery.sh` | `libnotify`, `coreutils`, `gnugrep` + `asusctl` (Linux only) | `pkgs.myScripts.battery` |

### Adding a new script

1. Add `scripts/<name>.sh` with `#!/usr/bin/env bash` and strict handling.
2. Register it in `scripts/default.nix`:
   ```nix
   <name> = pkgs.writeShellApplication {
     name = "<name>";
     runtimeInputs = with pkgs; [ <deps> ];
     text = builtins.readFile ./<name>.sh;
   };
   ```
   Use `pkgs.lib.optionals pkgs.stdenv.hostPlatform.isLinux [ ... ]` for Linux-only deps — packages are built for `aarch64-darwin` too.
3. **`flake.nix` does NOT need modification** — `import ./scripts <pkgs>` and `overlays.default` pick it up.
4. Consume it as `pkgs.myScripts.<name>` (`myScripts.<name>` inside a `with pkgs;` list, as in `hosts/asus-tuf/configuration.nix`).

---

## 7. Code Formatting & Tooling Guidelines

Adhere to the repo's formatters. `nixfmt`, `stylua`, `statix` and `deadnix` are **not on `PATH`** — invoke them through `nix run` / `nix shell` (do not assume a global binary):

| Language | Formatter / linter | Command |
| :--- | :--- | :--- |
| Nix | `nixfmt` (RFC style) | `nix run nixpkgs#nixfmt -- <files>` |
| Lua | `stylua` (2-space indent, single quotes, `config/nvim/external/stylua.toml`) | `nix run nixpkgs#stylua -- --check <files>` |
| Python | `black --line-length 120` | — |
| C / C++ | `clang-format` (settings in `config/nvim/external/clang-format`) | — |
| Shell | bash, `set -euo pipefail` where applicable; `shellcheck` via `writeShellApplication` | — |
| KDL (Niri) | `niri validate` (installed at `/run/current-system/sw/bin/niri`) | — |

Style expectations: modules modular, concise, single-purpose; keep lists alphabetically sorted where the surrounding file already is; two-space Nix indentation as produced by `nixfmt`.

---

## 8. Git & Commit Guidelines

- **Convention**: [Conventional Commits](https://www.conventionalcommits.org/). Types in use: `feat:`, `fix:`, `chore:`, `refactor:`, `docs:`, `style:`.
- **Format**: `<type>: <short lowercase imperative description>` — one logical change per commit.
- Examples from history:
  - `feat: add antigravity ide integration`
  - `fix: update fcitx5 trigger key and wayland support`
  - `refactor: move qbittorrent from home-manager to system packages`
  - `chore: update flake inputs`
- **Identity**: `taitapcode` / `hoangductai2007@gmail.com`, branch `main`.
- **Security & cleanliness**: never commit credentials, SSH keys, VPN secrets or private tokens; do not add ad-hoc ignore rules to a global `.gitignore` unless truly project-wide.
- Stage only the files the change touches; this repo frequently carries unrelated staged work.

---

## 9. Verification Checklist Before Completing Any Task

1. [ ] **Naming & placement**: new module file sits under `modules/{nixos,home-manager}/<category>/`, basename equals the final option segment, no `default.nix`, no relative imports.
2. [ ] **Enable wiring**: the option is actually enabled from the relevant host config (`hosts/asus-tuf/...`) — an unreferenced module silently does nothing.
3. [ ] **Syntax & evaluation**: if any `.nix`, flake input or lock entry changed — `nix flake check` or `nix eval .#nixosConfigurations.asus-tuf.config.system.build.toplevel.drvPath`. If only non-Nix files under `config/` changed — skip Nix evaluation and run the app validator instead.
4. [ ] **Path references**: no hardcoded `/home/tai/...`; only `self`-relative references.
5. [ ] **No system mutations**: confirm no `nh os switch`, `nixos-rebuild`, `systemctl`, or `reboot` was executed.
6. [ ] **Formatting**: touched `.nix` formatted with `nixfmt`, Lua with `stylua`; scripts keep bash strictness.
7. [ ] **Working tree**: `git status` reviewed; no uncommitted user work discarded; nothing committed or pushed unless asked.
