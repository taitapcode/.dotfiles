# Dotfiles — AI Agent Guidelines & Architecture Rules

Declarative NixOS configuration managed as a Nix flake with Home Manager, built and deployed via `nh`.

---

## 1. Safety & Execution Bounds (CRITICAL)

- **MANUAL ACTIVATION ONLY**: The user builds and activates system generations manually.
  - **NEVER** run `nh os build`, `nh os switch`, `nixos-rebuild`, `home-manager switch`, `systemctl`, `reboot`, or `poweroff`.
  - **NEVER** run any command that modifies system state or user environment directly.
- **Dry Verification Only**:
  - Verify changes safely before declaring tasks complete:
    - **Nix files modified** (`*.nix`, flake inputs, modules, host configs): Run pure evaluation:
      - Flake check: `nix flake check`
      - Or target host evaluation: `nix eval .#nixosConfigurations.asus-tuf.config.system.build.toplevel.drvPath`
    - **Non-Nix files modified** (raw configs under `config/`, assets, static text files): **Skip `nix eval`**. Run app-specific linters/validators if available (e.g., `niri validate`, `stylua`).
  - Rebuilding or switching is reserved exclusively for the user.
- **Working Tree Integrity**:
  - Never discard uncommitted changes (`git restore`, `git checkout --`) without explicit user permission. Always inspect `git status` and `git diff` first.

---

## 2. System Architecture & Target Environments

The repository defines two NixOS host configurations (`nixosConfigurations`):

### Primary Target: `asus-tuf` (Daily Driver / Active)
- **Model**: ASUS TUF Gaming A15 (FA506NC).
- **Architecture**: `x86_64-linux`, AMD CPU + NVIDIA GeForce RTX 3050.
- **Hardware Integration**:
  - Uses `nixos-hardware.nixosModules.asus-fa506nc`.
  - NVIDIA settings: `modesetting.enable = true`, `powerManagement.enable = true`, `nvidiaPersistenced = true`.
  - Power / Battery daemon: `services.asusd` (charge limit 80%, automated profiles on AC / battery).
- **Filesystems & Services**:
  - Storage: NTFS partition mounted at `/mnt/Storage` (`ntfs3`).
  - Network: Cloudflare WARP VPN service (`services.cloudflare-warp.enable = true`).
  - Desktop Environment: Niri (scrollable-tiling Wayland compositor) with Noctalia shell bar.
  - Audio: PipeWire with PulseAudio emulation.
  - Display Manager: SDDM.
  - Shell: Fish with vi keybindings, fzf, zoxide, yazi, and custom prompt.
  - Theme: Catppuccin Mocha (accent: `blue`) applied system-wide and in Home Manager.
- **All new modules, packages, and changes MUST target and be verified against `asus-tuf`.**

### Deprecated / Reference: `acer-aspire`
- **Status**: Legacy backup host, no longer actively used.
- **Guideline**: Do not build against or introduce breaking changes to this configuration, but ensure flake evaluation does not break (`nix flake check`).

---

## 3. Flake Design & Dependency Management

`flake.nix` is the central entrypoint (`system = "x86_64-linux"`).

### Flake Inputs
- `nixpkgs`: Pinned to `github:nixos/nixpkgs/nixos-unstable`.
- **Consistency Rule**: All flake inputs must follow `nixpkgs` (`inputs.nixpkgs.follows = "nixpkgs"`) to avoid duplicate package closures in the Nix store (e.g., `catppuccin`, `nixos-hardware`, `home-manager`, `zen-browser`, `helium-flake`, `nix-index-database`, `antigravity-nix`).
- **Zen Browser**: Flake input follows both `nixpkgs` and `home-manager`.
- **Noctalia Shell**: Packaged directly via `pkgs.noctalia` in Nixpkgs; configured through Home Manager's built-in `programs.noctalia` module (no standalone flake input required).

### Flake Outputs
- `packages.${system}`:
  - Custom shell helpers wrapped via `pkgs.writeShellApplication`:
    - `packages.x86_64-linux.note`: Wraps `scripts/note.sh` (runtime inputs: `git`, `neovim`, `coreutils`).
    - `packages.x86_64-linux.rcc`: Wraps `scripts/rcc.sh` (runtime inputs: `gcc`).
- `nixosConfigurations`:
  - `asus-tuf` and `acer-aspire`, both passed `specialArgs = { inherit inputs self; }` and `home-manager.nixosModules.default`.

### Flake Operations
- **Lockfile updates**: Run `nix flake update` from the repository root.
- **Lockfile commits**: Never commit `flake.lock` in isolation. Bundle lock updates with the commit adding/updating the dependent package or module.

---

## 4. Repository Layout & File Wiring

```
.dotfiles/
├── flake.nix                # Root entrypoint declaring inputs, packages, and nixosConfigurations
├── flake.lock               # Pinned input hashes
├── assets/                  # Wallpapers, icons, images (referenced via `${self}/assets/...`)
├── config/                  # Raw application configuration files (mirrored or consumed by modules)
├── hosts/                   # Machine-specific configurations
│   ├── asus-tuf/            # Active machine (configuration.nix, hardware.nix, home.nix)
│   └── acer-aspire/         # Deprecated machine
├── modules/
│   ├── home-manager/        # User-level modules (app/, programs/, desktop/)
│   └── nixos/               # System-level modules (program/, service/)
└── scripts/                 # Standalone bash helpers wrapped into flake packages
```

### Path Resolution Rules
- **CRITICAL**: **NEVER hardcode absolute home paths (`/home/tai/...`) or local clone paths in Nix expressions.**
- Always reference assets and configs via `self`:
  - `${self}/config/<app>/...`
  - `self + "/config/<app>"`
  - `${self}/assets/wallpapers/3.png`

### Configuration Consumption Patterns (`config/` -> modules)
Different applications consume `config/` differently. Always check the existing module before editing or wiring configs:
1. **Directory Symlink** (e.g., Niri):
   - Whole directory symlinked via `xdg.configFile."niri".source = self + "/config/niri";`.
2. **File Inlining via `builtins.readFile`** (e.g., Neovim):
   - Lua configs (`helper/*.lua`, `config/*.lua`, `plugin/*.lua`) are read into Nix strings and injected into Neovim options/plugins.
   - External tooling configs (`stylua.toml`, `clang-format`, `asm-lsp.toml`, snippets) are selectively symlinked via `xdg.configFile`.
3. **Specific File Symlink** (e.g., Fcitx5):
   - Individual conf files linked directly to `xdg.configFile."fcitx5/..."`.

---

## 5. Module Development Patterns

### Module Auto-Discovery (Zero `default.nix`)
- **Automatic Loading**: All `.nix` files under `modules/nixos/` and `modules/home-manager/` are discovered automatically via `scanModules` in `flake.nix`.
- **NO `default.nix`**: Never create `default.nix` files inside `modules/`. Simply place any new `<name>.nix` file in the appropriate directory.
- **NO relative imports**: Never import `../../modules/...` in host configurations or module files. Host configurations declare option values; the modules are imported centrally by `flake.nix`.

### Home-Manager Modules (`modules/home-manager/`)
- **Location**: `modules/home-manager/<category>/<name>.nix`
  - Categories: `app/`, `programs/`, `desktop/` (and subdirectories like `desktop/shell/`).
- **Namespace**: `modules.home.<category>.<name>`.
- **Standard Template**:
  ```nix
  { config, lib, pkgs, self, ... }:
  let
    cfg = config.modules.home.<category>.<name>;
  in
  {
    options.modules.home.<category>.<name> = {
      enable = lib.mkEnableOption "Enable <name> configuration";
    };

    config = lib.mkIf cfg.enable {
      # Package definitions, xdg config files, program settings
    };
  }
  ```
- **Auto-Chains**:
  - `modules.home.programs.fish.enable` automatically enables `fzf`, `zoxide`, `yazi`, and `nix-index`.
  - `modules.home.desktop.niri.enable` automatically enables `desktop.shell.noctalia`.

### NixOS Modules (`modules/nixos/`)
- **Location**: `modules/nixos/<category>/<name>.nix`
  - Categories: `program/`, `service/`.
- **Namespace**: `modules.nixos.<category>.<name>`.
- **Specialisation Pattern**:
  - For heavy or optional hardware/software profiles (e.g. Steam gaming), use the NixOS specialisation pattern:
    ```nix
    options.modules.nixos.program.steam.useSpecialisation = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Isolate into a separate boot entry via specialisation.";
    };
    ```

---

## 6. Helper Scripts (`scripts/`)

- Helper scripts reside in `scripts/<name>.sh`.
- Package definitions reside in `scripts/default.nix` (`pkgs: { ... }`).
- **Multi-Architecture Support**:
  - `flake.nix` automatically builds packages for all supported architectures (`x86_64-linux`, `aarch64-linux`, and `aarch64-darwin` for Apple Silicon Mac) via `forAllSystems`.
  - `self.overlays.default` injects all scripts cleanly into `pkgs.myScripts.*` to avoid namespace collisions with upstream Nixpkgs packages.
- **Adding a new script**:
  1. Add `scripts/<name>.sh`.
  2. Add entry in `scripts/default.nix` using `pkgs.writeShellApplication` with explicit `runtimeInputs`.
  3. `flake.nix` does NOT need modification!
  4. In host packages, reference as `myScripts.<name>` from `pkgs` (e.g., `myScripts.note`, `myScripts.rcc`).

---

## 7. Code Formatting & Tooling Guidelines

Always adhere to the repo's established linters and formatters:
- **Nix**: Format using `nixfmt`. Keep modules modular, concise, and single-purpose.
- **Lua**: Format using `stylua` (2 spaces indentation, single quotes).
- **Python**: Format using `black` (`--line-length 120`).
- **C / C++**: Format using `clang-format` (settings in `config/nvim/external/clang-format`).
- **Shell**: Bash with strict error handling (`set -euo pipefail` where applicable).

---

## 8. Git & Commit Guidelines

- **Convention**: Conventional Commits specification.
  - Types: `feat:`, `fix:`, `chore:`, `refactor:`, `docs:`, `style:`.
  - Format: `<type>: <short lowercase imperative description>`
  - Examples from repository history:
    - `feat: add antigravity ide integration`
    - `fix: update fcitx5 trigger key and wayland support`
    - `refactor: move qbittorrent from home-manager to system packages`
    - `chore: update flake inputs`
- **Identity**:
  - Name: `taitapcode`
  - Email: `hoangductai2007@gmail.com`
  - Branch: `main`
- **Security & Cleanliness**:
  - Never commit credentials, SSH keys, VPN secrets, or private tokens.
  - Do not add ad-hoc ignore rules to global `.gitignore` unless truly project-wide.

---

## 9. Verification Checklist Before Completing Any Task

1. [ ] **Syntax & Evaluation**: If any `.nix` files or flake inputs were modified, verify with `nix flake check` or `nix eval .#nixosConfigurations.asus-tuf.config.system.build.toplevel.drvPath`. For non-Nix config changes under `config/`, skip Nix evaluation and use app-specific linters/validators if applicable.
2. [ ] **Module Discovery**: Ensure any newly created module is a `.nix` file placed under `modules/home-manager/` or `modules/nixos/` (automatically scanned, no `default.nix` needed).
3. [ ] **Path References**: Verify no hardcoded local paths (`/home/tai/...`) exist in Nix files; only `self` references used.
4. [ ] **No System Mutations**: Confirm no `nh os switch` or `nixos-rebuild` commands were executed.
5. [ ] **Formatting**: Ensure files are formatted with `nixfmt`, `stylua`, or relevant formatters.
