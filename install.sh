#!/usr/bin/env bash
#
# Vymrland installer.
#
# A personal, reproducible customization layer on top of Omarchy. User layer
# only: everything lands in ~/.config and ~/.local. Nothing here ever writes to
# /usr/share/omarchy (package-owned, overwritten on update).
#
# Idempotent: safe to re-run at any time. Expensive/one-time steps are guarded
# with `omarchy-done` markers; the rest is declarative copy + install.
#
# Decisions baked in (see README.md):
#   - Omarchy default bindings stay ENABLED; Vymrland only unbinds collisions.
#   - HyprVim is pinned to a release tag, not tracking main.
#   - The cyan theme is copied and applied with `omarchy-theme-set`
#     (NOT `omarchy-theme-install`, which clones a git repo and strips
#     *.lua / terminal configs).
#   - Z13 hardware quirks are applied from the user layer via hooks and
#     ~/.config; anything needing root is documented, not run silently.

set -euo pipefail

REPO="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_SRC="$REPO/config"
PKG_DIR="$REPO/packages"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/vymrland"
BACKUP_ROOT="$STATE_DIR/backups"

DONE_NS="vymrland"
THEME_NAME="cyan"

# --no-packages skips official/AUR installs (useful when sudo is unavailable,
# e.g. non-interactive runs). Packages can be installed later by re-running
# without the flag.
SKIP_PACKAGES=0
while (($#)); do
  case "$1" in
    --no-packages) SKIP_PACKAGES=1 ;;
    -h|--help)
      echo "Usage: install.sh [--no-packages]"
      exit 0
      ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
  shift
done

HYPRVIM_REPO="https://github.com/uhs-robert/hyprvim"
HYPRVIM_TAG="v4.0.1"
HYPRVIM_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/hyprland/lua/plugins/hyprvim"

log()  { printf '\033[36m[vymrland]\033[0m %s\n' "$*"; }
warn() { printf '\033[33m[vymrland]\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[31m[vymrland]\033[0m %s\n' "$*" >&2; exit 1; }

done_check() { omarchy-done check "${DONE_NS}-$1"; }
done_mark()  { omarchy-done mark  "${DONE_NS}-$1"; }

# ---------------------------------------------------------------------------
# Preflight
# ---------------------------------------------------------------------------
preflight() {
  command -v omarchy >/dev/null 2>&1 || die "omarchy not found; is this an Omarchy system?"
  [[ -d /usr/share/omarchy ]] || die "Omarchy install not detected at /usr/share/omarchy"
  command -v pacman >/dev/null 2>&1 || die "pacman not found"
  command -v yay >/dev/null 2>&1 || die "yay not found; required for AUR packages"
  log "preflight ok (Omarchy $(omarchy version 2>/dev/null || echo '?'))"
}

# ---------------------------------------------------------------------------
# Backup: ~/.config/{hypr,omarchy} before the first deploy. Guarded so repeated
# runs do not fill the disk; re-backups can be taken manually or by uninstall.
# ---------------------------------------------------------------------------
backup() {
  if done_check backup; then
    log "backup already taken ($BACKUP_ROOT)"
    return 0
  fi
  local ts dir d
  ts="$(date +%Y%m%d%H%M%S)"
  dir="$BACKUP_ROOT/$ts"
  mkdir -p "$dir"
  for d in hypr omarchy; do
    if [[ -e "$HOME/.config/$d" ]]; then
      cp -a "$HOME/.config/$d" "$dir/$d"
      log "backed up ~/.config/$d -> $dir/$d"
    fi
  done
  printf '%s\n' "$dir" > "$STATE_DIR/last-backup"
  done_mark backup
}

# ---------------------------------------------------------------------------
# Hooks: source of truth is config/omarchy/hooks/<type>/<name>.sh. Each script
# is installed into ~/.config/omarchy/hooks/<type>.d/ via `omarchy hook install`.
# The pre-refresh-pacman hook must land before any package refresh.
# ---------------------------------------------------------------------------
install_hooks() {
  local type_dir type src installed=0
  shopt -s nullglob
  for type_dir in "$CONFIG_SRC"/omarchy/hooks/*/; do
    type="$(basename "$type_dir")"
    for src in "$type_dir"*.sh; do
      omarchy hook install "$type" "$src"
      installed=$((installed + 1))
    done
  done
  shopt -u nullglob
  log "installed $installed hook(s)"
}

# ---------------------------------------------------------------------------
# Packages: official via omarchy-pkg-add (pacman --needed), AUR via
# omarchy-pkg-aur-add (yay). Both are no-ops when already present.
# ---------------------------------------------------------------------------
install_packages() {
  if (( SKIP_PACKAGES )); then
    log "skipping package installs (--no-packages)"
    return 0
  fi

  local official aur
  official="$(grep -vE '^[[:space:]]*(#|$)' "$PKG_DIR/official.txt" || true)"
  aur="$(grep -vE '^[[:space:]]*(#|$)' "$PKG_DIR/aur.txt" || true)"

  if [[ -n "$official" ]]; then
    log "installing official packages: $(tr '\n' ' ' <<<"$official")"
    # shellcheck disable=SC2086  # intentional word splitting
    omarchy-pkg-add $official
  fi
  if [[ -n "$aur" ]]; then
    log "installing AUR packages: $(tr '\n' ' ' <<<"$aur")"
    # shellcheck disable=SC2086  # intentional word splitting
    omarchy-pkg-aur-add $aur
  fi
}

# ---------------------------------------------------------------------------
# Deploy configs: copy config/ into ~/.config/ (copy, not symlink). The hooks
# source directory is excluded here because install_hooks() owns it; copying it
# verbatim would leave stray ~/.config/omarchy/hooks/<type>/ directories.
# ---------------------------------------------------------------------------
deploy_configs() {
  [[ -d "$CONFIG_SRC" ]] || { log "no config/ to deploy"; return 0; }
  command -v rsync >/dev/null 2>&1 || die "rsync not found; required for config deployment"
  log "deploying configs -> ~/.config/ (excluding omarchy/hooks)"
  rsync -a --exclude 'omarchy/hooks/' "$CONFIG_SRC/" "$HOME/.config/"
}

# ---------------------------------------------------------------------------
# Deploy home/: a small set of dotfiles that must live in $HOME rather than
# ~/.config (currently only ~/.zshenv, which points ZDOTDIR at ~/.config/zsh).
# ---------------------------------------------------------------------------
deploy_home() {
  [[ -d "$REPO/home" ]] || return 0
  command -v rsync >/dev/null 2>&1 || die "rsync not found; required for home deployment"
  log "deploying home/ -> ~/"
  rsync -a "$REPO/home/" "$HOME/"
}

# ---------------------------------------------------------------------------
# Theme: copy the hand-written user theme, then apply it. This theme lives in
# the user layer, so it is unrestricted (unlike a theme cloned via
# `omarchy-theme-install`, which drops *.lua and terminal configs).
# ---------------------------------------------------------------------------
install_theme() {
  local theme_src="$CONFIG_SRC/omarchy/themes/$THEME_NAME"
  if [[ ! -d "$theme_src" ]]; then
    log "theme '$THEME_NAME' not present yet; skipping (Phase 4)"
    return 0
  fi
  mkdir -p "$HOME/.config/omarchy/themes/$THEME_NAME"
  cp -a "$theme_src/." "$HOME/.config/omarchy/themes/$THEME_NAME/"

  local current
  current="$(omarchy-theme-current 2>/dev/null || true)"
  if [[ "${current,,}" == "${THEME_NAME,,}" ]]; then
    log "theme already set: $THEME_NAME"
    return 0
  fi

  # `omarchy-theme-set` restarts running terminals, which would kill this script
  # (and the terminal it runs in). Detach it so the install can complete.
  log "applying theme: $THEME_NAME (detached)"
  setsid omarchy-theme-set "$THEME_NAME" >/dev/null 2>&1 </dev/null &
}

# ---------------------------------------------------------------------------
# HyprVim: install into the user data dir and pin to a release tag. Idempotent:
# if the checkout already sits exactly on the tag, nothing is fetched.
# The Lua plugin is loaded by ~/.config/hypr/hyprland.lua (Phase 2), and
# `updates.channel = "off"` is set there so HyprVim's self-updater stays quiet.
# ---------------------------------------------------------------------------
install_hyprvim() {
  if [[ ! -d "$HYPRVIM_DIR/.git" ]]; then
    log "cloning HyprVim -> $HYPRVIM_DIR"
    mkdir -p "$(dirname "$HYPRVIM_DIR")"
    git clone "$HYPRVIM_REPO" "$HYPRVIM_DIR"
  fi

  local current
  current="$(git -C "$HYPRVIM_DIR" describe --tags --exact-match 2>/dev/null || true)"
  if [[ "$current" == "$HYPRVIM_TAG" ]]; then
    log "HyprVim already pinned at $HYPRVIM_TAG"
    return 0
  fi

  log "pinning HyprVim to $HYPRVIM_TAG"
  git -C "$HYPRVIM_DIR" fetch --tags --quiet origin
  git -C "$HYPRVIM_DIR" checkout --quiet "$HYPRVIM_TAG"
}

# ---------------------------------------------------------------------------
# Hardware: Phase 5. Z13 quirks are applied from the user layer (post-boot hook
# + asusctl user config); root-only steps are documented in hardware/z13/.
# ---------------------------------------------------------------------------
apply_hardware() {
  [[ -d "$REPO/hardware/z13" ]] || return 0
  log "hardware/z13 present; apply via post-boot hook (Phase 5)"
}

main() {
  preflight
  backup
  install_hooks
  deploy_configs
  deploy_home
  install_theme
  install_hyprvim
  install_packages
  apply_hardware
  done_mark installed
  log "Vymrland applied. Re-run safely anytime."
  log "After an Omarchy update, run: vymrland update"
}

main
