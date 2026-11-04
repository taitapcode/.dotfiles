# My NixOS dotfiles

<div align="center">

![NixOS](https://img.shields.io/badge/NixOS-26.05-5277C3?style=for-the-badge&logo=nixos&logoColor=white)
![Flakes](https://img.shields.io/badge/Flakes-Enabled-blueviolet?style=for-the-badge&logo=nixos&logoColor=white)
![Compositor](https://img.shields.io/badge/Compositor-Niri-5B6078?style=for-the-badge)
![Shell Bar](https://img.shields.io/badge/Shell-Noctalia-89B4FA?style=for-the-badge)
![Theme](https://img.shields.io/badge/Theme-Catppuccin%20Mocha-CBA6F7?style=for-the-badge&logo=catppuccin&logoColor=white)
![Target](https://img.shields.io/badge/Host-ASUS%20TUF%20A15-FF6F00?style=for-the-badge&logo=asus&logoColor=white)

<br/>

![Desktop Screenshot](./assets/screenshot.png)

*A fully declarative, reproducible, and minimal Wayland desktop environment managed via Nix Flakes and Home Manager.*

</div>

---

## 📖 Overview

This repository contains my personal NixOS configuration. Built on **Nix Flakes** and **Home Manager**, it provides a cohesive, reproducible computing environment across system packages, kernel modules, hardware daemons, and granular userland configurations.

The desktop is centered around **[Niri](https://github.com/YaLTeR/niri)** — an infinitely scrollable-tiling Wayland compositor — unified by the **[Noctalia](https://github.com/noctalia-dev/noctalia)** desktop shell & greeter, and styled throughout with the **Catppuccin Mocha** palette.

---

## ✨ Key Highlights

- **📜 Scrollable Tiling Workflow**: Effortless horizontal workspace scaling with Niri, featuring fluid animations, dynamic column sizing, and zero window overlap clutter.
- **🎨 Unified Aesthetics**: System-wide Catppuccin Mocha (blue accent) theming applied across GTK, Qt, Ghostty, Neovim, Noctalia Shell, Banana cursor, and custom lockscreen visualizers.
- **⚡ Zero-Boilerplate Module Discovery**: Flake architecture automatically scans and imports all NixOS and Home Manager modules recursively (`scanModules`), eliminating repetitive `default.nix` import lists.
- **🎮 Isolated Gaming Specialisation**: High-performance Steam and Gamescope configuration isolated into a dedicated `gaming` boot specialisation to keep the primary profile lean.
- **⌨️ Keyboard & Input Comfort**:
  - Hardware-level `Caps Lock` ⇄ `Esc` swap managed by `keyd`.
  - Vietnamese input via `fcitx5` integrated seamlessly with Wayland and Neovim.
- **💻 Curated Developer Environment**:
  - **Ghostty** with native Wayland blur and fast GPU acceleration.
  - **Fish Shell** with vi mode, contextual git prompt, `fifc`, and fast CLI navigators (`fzf`, `zoxide`, `yazi`, `eza`, `bat`).
  - **Neovim** configured modularly in Lua (`blink-cmp`, `snacks.nvim`, Treesitter, LSPs, formatters, and snippets).
  - **Hermes Agent** CLI configured declaratively through its upstream Home Manager module (no `hermes config set` — see below).
- **🔐 Encrypted Secrets at Rest**: API keys and tokens managed with [sops-nix](https://github.com/Mic92/sops-nix) + **age**, committed only in ciphertext (`secrets/secrets.yaml`).

---

## 🖥️ Target Machines

| Host | Status | Target Hardware | Purpose |
| :--- | :---: | :--- | :--- |
| **`asus-tuf`** | **Active (Daily Driver)** | ASUS TUF Gaming A15 (FA506NC)<br/>• AMD Ryzen CPU<br/>• NVIDIA GeForce RTX 3050 <br/>• NTFS3 secondary storage (`/mnt/Storage`) | Primary workstation for development, daily productivity, and gaming. |
| **`acer-aspire`** | *Legacy / Backup* | Acer Aspire Laptop | Maintained for flake evaluation compatibility. |

---

## 📦 Software Stack

### Desktop & UI
- **Compositor**: [Niri](https://github.com/YaLTeR/niri) (Scrollable-tiling Wayland compositor)
- **Shell & Panel**: [Noctalia Shell](https://github.com/noctalia-dev/noctalia) (top bar, dock, control center, dynamic lockscreen widgets, wallpaper switcher)
- **Display Manager**: [Noctalia Greeter](https://github.com/noctalia-dev/noctalia) (`greetd`)
- **Theme**: Catppuccin Mocha (Accent: Blue)
- **Cursor**: Banana Cursor (`banana-cursor`)
- **Icons**: Colloid Dark (`colloid-icon-theme`)

### Terminal & Shell
- **Terminal Emulator**: [Ghostty](https://ghostty.org/)
- **Shell**: Fish (with Vi keybindings, custom dirty git prompt, `fifc` fzf completions)
- **CLI Utilities**: `eza` (modern ls), `bat` (cat with syntax highlighting), `yazi` (file manager), `zoxide` (smart cd), `fzf`, `ripgrep`, `lazygit`, `btop`, `nix-index`

### Applications & Productivity
- **Development**: Modular Neovim, Opencode, Hermes Agent CLI (declaratively managed)
- **Web Browsers**: [Zen Browser](https://zen-browser.app/) (Beta), [Helium Browser](https://github.com/oxcl/nix-flake-helium-browser)
- **Documents & Media**: Zathura (PDF/EPUB), Loupe (Images), MPV (Audio/Video), LibreOffice
- **Communication & Social**: Vesktop (Discord with Vencord plugins), LocalSend
- **Other Services**: Cloudflare WARP (`cloudflare-warp`), Waydroid, Anki, OBS Studio, qBittorrent

---

## ⌨️ Essential Keybindings

### System & Noctalia Menus
| Shortcut | Action |
| :--- | :--- |
| `Mod + D` | Open Noctalia Application Launcher |
| `Mod + S` | Toggle Noctalia Control Center |
| `Mod + P` | Open Session Menu (Power, Reboot, Logout) |
| `Mod + V` | Open Clipboard History |
| `Mod + ,` | Open Noctalia Settings |
| `Mod + Alt + L` / `Ctrl + Alt + L` | Lock Screen |
| `Mod + Shift + B` | Toggle Battery Limit (70% longevity ⇄ 100% oneshot) |
| `Fn + F10` (`XF86TouchpadToggle`) | Toggle Touchpad off / on (desktop notification) |
| `Mod + Shift + /` | Show Niri Hotkey Overlay |

### Applications
| Shortcut | Action |
| :--- | :--- |
| `Mod + Return` | Spawn Ghostty Terminal |
| `Mod + B` | Launch Zen Browser |
| `Mod + E` | Open Nautilus File Explorer |

### Niri Window Management
| Shortcut | Action |
| :--- | :--- |
| `Mod + H` / `Mod + L` | Focus column left / right |
| `Mod + J` / `Mod + K` | Focus window down / up within column |
| `Mod + Shift + H` / `L` | Move column left / right |
| `Mod + Shift + J` / `K` | Move window down / up |
| `Mod + R` | Cycle preset column widths (`50%`, `33.3%`, `66.7%`) |
| `Mod + F` | Maximize column |
| `Mod + Shift + F` | Fullscreen window |
| `Mod + Q` | Close focused window |

*(Note: `Caps Lock` and `Esc` are swapped at hardware level via `keyd` for ergonomic modal editing).*

---

## 🛠️ Custom CLI Utilities (`myScripts.*`)

Packaged as standalone flakes executables with strict runtime dependency sandboxing:

### 1. `battery` — ASUS Battery Health Manager
Manage ASUS battery charge thresholds via `asusctl` with desktop notifications:
```bash
battery status          # Show current charge limit and battery stats
battery 70              # Set limit to 70% (optimal for battery health on AC)
battery oneshot         # One-shot charge to 100% for travel
battery toggle          # Toggle between 70% and 100% oneshot
```

### 2. `note` — Git-Backed Markdown Notes
Effortless note management synced directly with a git repository:
```bash
note                    # Open today's note (YYYYMMDD.md) in Neovim
note <title>            # Open or create a specific note
note new <title>        # Create a new note with optional title
note folder             # Search notes interactively via Neovim Snacks picker
note pull               # Pull updates from remote repository
note push               # Stage all, commit with timestamp, and push
note clone <repo_url>   # Clone (or merge into existing non-empty dir) remote notes
```

### 3. `rcc` — Instant C/C++ Runner
Compile, execute with strict flags, and cleanly remove the generated binary in a single step:
```bash
rcc solution.cpp        # Compiles with g++ -std=c++17 -O2 -Wall -Wextra, runs, and cleans up
rcc main.c              # Compiles with gcc -std=c11 -O2 -Wall -Wextra, runs, and cleans up
```

### 4. `touchpad` — Touchpad Toggle
niri exposes no IPC for input devices, so the toggle rewrites the `off` flag of an included state file (`~/.local/state/niri/touchpad.kdl`) that niri watches and live-reloads, then reports the new state with a desktop notification. Bound to `Fn + F10` (`XF86TouchpadToggle`):
```bash
touchpad                # Toggle the touchpad off / on
touchpad off            # Disable the touchpad
touchpad on             # Re-enable the touchpad
touchpad status         # Print the current touchpad state
```

### 5. `appimg` — AppImage Installer / Uninstaller
AppImages installed outside the Nix store: `~/.local/bin/<name>` plus a `.desktop` entry carrying the app's own name and icons unpacked into the hicolor theme (on NixOS the file runs through binfmt → `appimage-run`, so the payload is unsquashed directly):
```bash
appimg install file.AppImage      # Copy to ~/.local/bin, write .desktop + icons
appimg install file.AppImage foo  # Same, command renamed to foo
appimg list                       # Installed AppImage apps, sizes, orphan caches
appimg remove -n deckcraft        # Dry run: show what would be deleted
appimg remove deckcraft           # Delete binary, entry, icons, extraction cache
```

---

## 📂 Repository Structure

```
.dotfiles/
├── flake.nix                # Flake entrypoint (inputs, overlays, outputs)
├── flake.lock               # Pinned input hashes
├── assets/                  # Wallpapers, icons, and screenshot
│   ├── icons/               # Battery and status icons
│   ├── wallpapers/          # Curated wallpapers
│   └── screenshot.png       # Desktop preview
├── config/                  # Standalone application configurations
├── hosts/                   # Machine profiles
├── modules/
│   ├── home-manager/        # User-level modules (auto-discovered)
│   │   ├── app/             # Desktop applications (Ghostty, Zen, etc.)
│   │   ├── desktop/         # Niri and Noctalia Shell / Greeter configuration
│   │   └── programs/        # CLI & user tools (Fish, Neovim, Bat, Eza, Git, Nh, Hermes, Sops)
│   └── nixos/               # System-level modules (auto-discovered)
│       ├── program/         # System programs (Steam, Fcitx5, Waydroid, LocalSend)
│       └── service/         # System services (Keyd, Noctalia Greeter, SDDM)
├── scripts/                 # Custom shell scripts wrapped as flake packages
└── secrets/                 # sops/age-encrypted secrets.yaml
```
