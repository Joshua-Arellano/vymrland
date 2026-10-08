# Vymrland

A personal, reproducible customization layer on top of **Omarchy 4.0.4**
(Arch + Hyprland + Quickshell). Vymrland is **not** a distro or ISO: it is a git
repo plus an idempotent installer applied to an existing Omarchy install.

## Principles

- **User layer only.** Everything lives in `~/.config` and `~/.local`. Nothing
  ever writes to `/usr/share/omarchy` (package-owned; overwritten on update).
- **Copy, not symlink.** Configs are copied into `~/.config`, so Omarchy and its
  tools keep working normally. `vymrland update` re-applies after a `git pull`.
- **Idempotent.** `install.sh` is safe to re-run. One-time steps are guarded
  with `omarchy-done` markers (`check`/`mark`, never `ensure`).
- **Back up first.** The first install backs up `~/.config/{hypr,omarchy}` to
  `~/.local/state/vymrland/backups/<timestamp>/`.

## Decisions

| Topic | Decision |
|---|---|
| Omarchy default bindings | **Stay enabled.** Vymrland only unbinds the specific collisions it needs. |
| HyprVim | Installed from `uhs-robert/hyprvim` into `~/.local/share/hyprland/lua/plugins/hyprvim`, **pinned to `v4.0.1`** (not main). Self-updater set to `off`. |
| Theme | `cyan` is a hand-written user theme, deployed by copy then `omarchy-theme-set cyan`. **Not** `omarchy-theme-install` (that clones a git repo and strips `*.lua` / terminal configs). |
| Z13 hardware | Applied from the user layer via a `post-boot` hook + `~/.config` asusctl settings. Root-only steps are documented in `hardware/z13/`, never run silently. |
| AUR | Installed via `omarchy-pkg-aur-add` (yay). Personal pacman repo deferred. |

### Keybind conflict resolutions

Vymrland keeps Omarchy's defaults and unbinds only what it repurposes
(`hl.unbind` in `config/hypr/bindings.lua`).

| Key | Was (Omarchy) | Now (Vymrland) |
|---|---|---|
| `SUPER+W` | Close window | next window |
| `SUPER+L` | Toggle workspace layout | focus right |
| `SUPER+S` | Toggle scratchpad | split |
| `SUPER+F` | Full screen | float |
| `SUPER+V` | Universal paste | HyprVim NORMAL |
| `SUPER+J` | Toggle window split | focus down |
| `SUPER+K` | Keybindings | focus up |
| `SUPER+TAB` | Next workspace | last workspace |
| `SUPER+ESC` | System menu | HyprVim exit |
| `SUPER+SHIFT+SLASH` | Passwords | HyprVim which-key |
| `SUPER+SHIFT+F` | File manager | fullscreen |
| `SUPER+SHIFT+B` | Browser | previous window |
| `SUPER+SHIFT+P` | Google Photos | pseudo |
| `SUPER+SHIFT+G` | Signal | group |
| `SUPER+ALT+S` | Move to scratchpad | scratchpad toggle |
| `SUPER+CTRL+H/K/L` | Hardware menu / Herdr / lock | resize |
| `SUPER+CTRL+1..9` | Bar panel N | focus monitor N |

Added: `SUPER+Q` close, `SUPER+SHIFT+Q` quit, `SUPER+ALT+L` layout,
`SUPER+ALT+SHIFT+S` move-to-scratchpad, `SUPER+CTRL+ALT+L` lock,
`SUPER+CTRL+ALT+H` hardware menu, `SUPER+CTRL+ALT+K` Herdr keybindings,
`SUPER+b` browser, `SUPER+e` files, `SUPER+m` music, `SUPER+SHIFT+ESC` system
menu, `SUPER+]/[` workspace cycle, `SUPER+ALT+V` universal paste.

Keybind help moved off `SUPER+K` (now focus up); use the menu (Learn >
Keybindings) or `omarchy-menu-keybindings`.

`SUPER+y/p/x` copy/paste/cut live in **HyprVim NORMAL mode only** (not global);
Omarchy's `SUPER+C/V/X` universal clipboard is untouched. `SUPER+V` enters
HyprVim NORMAL and `SUPER+ESC` exits.

### Deviations from the original plan

- **Monitor scaling** stays on Omarchy's `SUPER+SLASH` / `SUPER+ALT+SLASH`.
  The plan's `SUPER+=/-` collides with Omarchy's window-resize binds; keeping
  Omarchy's avoids unbinding them.
- **Keybind help** stays on Omarchy's `SUPER+K`. The plan's `SUPER+/` collides
  with Omarchy's monitor-scaling key.
- **Previous window** uses `SUPER+SHIFT+b` as planned; this required unbinding
  Omarchy's alternate `SUPER+SHIFT+B` browser (browser remains on `SUPER+b`).
- **Scratchpad** toggle moved to `SUPER+ALT+s`; move-to-scratchpad to
  `SUPER+ALT+SHIFT+s`.

## Layout

```
vymrland/
├── install.sh                 # automated, idempotent, backs up first
├── uninstall.sh
├── packages/{official,aur}.txt
├── config/                    # → copied into ~/.config
│   ├── hypr/                  # hyprland/bindings/hyprvim.lua + keymaps/ (done)
│   ├── omarchy/
│   │   ├── extensions/omarchy-menu.jsonc   # setup.vymrland + ROG (done)
│   │   ├── hooks/             # <type>/<name>.sh -> <type>.d/ (done)
│   │   └── themes/cyan/       # colors.toml + neovim.lua (done)
│   ├── zellij/config.kdl     # Neovim-style modal (done)
│   ├── nvim/lua/config/keymaps.lua   # LazyVim reverts (done)
│   ├── ghostty/config        # (done)
│   └── zsh/.zshrc            # (done)
├── home/                      # → copied into ~/ (.zshenv, .local/bin/vymrland*)
├── hardware/z13/              # (Phase 5)
└── README.md
```

User binaries (`vymrland`, `vymrland-window-close-others`) live in
`~/.local/bin` because `~/.config/omarchy/bin` is **not** on Omarchy's PATH.

## Usage

```bash
./install.sh              # apply / re-apply (idempotent)
./uninstall.sh            # restore last backup, remove hooks/markers
./uninstall.sh --purge-packages --purge-hyprvim
```

After an Omarchy update, either the `post-update` hook re-applies Vymrland
automatically, or run `vymrland update` (git pull + re-apply).

## Manual steps (need root / interactive)

`install.sh --no-packages` skips these; run them yourself:

```bash
# Packages (needs sudo). install.sh without --no-packages does this for you.
omarchy-pkg-add $(grep -vE '^\s*(#|$)' packages/official.txt)
omarchy-pkg-aur-add $(grep -vE '^\s*(#|$)' packages/aur.txt)

# zsh: Ghostty launches zsh interactively (command = /usr/bin/zsh); the login
# shell stays bash. Open a new terminal to pick it up.
# To make zsh the login shell too: chsh -s /usr/bin/zsh   (needs your password)
```

zsh config is already in place (`~/.config/zsh/.zshrc`, `~/.zshenv` sets
`ZDOTDIR`); it activates once zsh is installed and used.

## Gotchas

- **`omarchy-theme-set` restarts running terminals** (`omarchy-restart-terminal`).
  Calling it synchronously from `install.sh` kills the script. `install_theme`
  therefore skips when the theme is already current and otherwise applies it
  detached via `setsid`.
- **`~/.config/omarchy/bin` is not on PATH.** User binaries go in `~/.local/bin`
  (`home/.local/bin/` in this repo).
- **`omarchy-done ensure` returns non-zero when a marker exists** (noclobber
  under `set -e`); use `check`/`mark`, never `ensure`.

## Launcher menu (Super+Space)

`Setup > Vymrland` adds:

- **Configs** — open the repo files in the editor: Keybindings
  (`hyprland.lua`, `bindings.lua`, `keymaps/global.lua`, `submaps/ctrlw.lua`),
  Zellij, Neovim, Shell, and the whole repo.
- **Set cyan theme**
- **TUI apps** — btop, yazi, gitui, cmus, neomutt, zellij, termusic
- **Update** (git pull + apply) / **Reinstall** (re-apply)
- **ROG Z13** — asusctl profiles, battery limit, keyboard backlight (top-level
  `rog` submenu)

## Phases

1. **Repo skeleton + package lists + install.sh scaffold** ← done
2. **Hyprland configs: keymaps/submaps/bindings + HyprVim pin** ← done
3. **Zellij + nvim (LazyVim revert) + zsh + app configs** ← done
4. **Menu extensions + hooks + cyan theme** ← done
5. Hardware quirks
6. Test on fresh Omarchy → iterate
