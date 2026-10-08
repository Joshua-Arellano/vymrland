#!/usr/bin/env bash
#
# Vymrland uninstaller.
#
# Restores the most recent Vymrland backup of ~/.config/{hypr,omarchy} and
# removes the Vymrland-managed hooks and done markers. Packages are left in
# place by default (pass --purge-packages to remove them too).
#
# This does NOT touch /usr/share/omarchy.

set -euo pipefail

REPO="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_SRC="$REPO/config"
PKG_DIR="$REPO/packages"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/vymrland"
BACKUP_ROOT="$STATE_DIR/backups"
DONE_NS="vymrland"
HYPRVIM_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/hyprland/lua/plugins/hyprvim"

PURGE_PACKAGES=0
PURGE_HYPRVIM=0

usage() {
  cat <<USAGE
Usage: uninstall.sh [--purge-packages] [--purge-hyprvim]

  --purge-packages   Also remove the packages listed in packages/*.txt.
  --purge-hyprvim    Also remove the pinned HyprVim checkout.
USAGE
}

while (($#)); do
  case "$1" in
    --purge-packages) PURGE_PACKAGES=1 ;;
    --purge-hyprvim)  PURGE_HYPRVIM=1 ;;
    -h|--help)        usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 1 ;;
  esac
  shift
done

log()  { printf '\033[36m[vymrland]\033[0m %s\n' "$*"; }
warn() { printf '\033[33m[vymrland]\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[31m[vymrland]\033[0m %s\n' "$*" >&2; exit 1; }

restore_backup() {
  local latest
  if [[ -f "$STATE_DIR/last-backup" ]]; then
    latest="$(cat "$STATE_DIR/last-backup")"
  else
    latest="$(find "$BACKUP_ROOT" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort | tail -1 || true)"
  fi

  if [[ -z "${latest:-}" || ! -d "$latest" ]]; then
    warn "no Vymrland backup found; leaving ~/.config as-is"
    return 0
  fi

  local d
  for d in hypr omarchy; do
    if [[ -d "$latest/$d" ]]; then
      rm -rf "${HOME:?}/.config/$d"
      cp -a "$latest/$d" "$HOME/.config/$d"
      log "restored ~/.config/$d from $latest/$d"
    fi
  done
}

remove_hooks() {
  local type_dir type src name target
  shopt -s nullglob
  for type_dir in "$CONFIG_SRC"/omarchy/hooks/*/; do
    type="$(basename "$type_dir")"
    for src in "$type_dir"*.sh; do
      name="$(basename "$src")"
      target="$HOME/.config/omarchy/hooks/$type.d/$name"
      if [[ -f "$target" ]]; then
        rm -f "$target"
        log "removed hook: $target"
      fi
    done
  done
  shopt -u nullglob
}

purge_packages() {
  local pkgs
  pkgs="$(grep -hE -v '^[[:space:]]*(#|$)' "$PKG_DIR"/*.txt 2>/dev/null || true)"
  [[ -n "$pkgs" ]] || return 0
  log "removing packages (yay/pacman)"
  # shellcheck disable=SC2086
  yay -Rns --noconfirm $pkgs || warn "some packages could not be removed"
}

purge_hyprvim() {
  if [[ -d "$HYPRVIM_DIR" ]]; then
    rm -rf "$HYPRVIM_DIR"
    log "removed HyprVim checkout: $HYPRVIM_DIR"
  fi
}

clear_markers() {
  local m
  shopt -s nullglob
  for m in "$HOME/.local/state/omarchy/done/${DONE_NS}-"*; do
    rm -f "$m"
    log "cleared marker: $(basename "$m")"
  done
  shopt -u nullglob
}

main() {
  restore_backup
  remove_hooks
  clear_markers
  (( PURGE_HYPRVIM ))  && purge_hyprvim
  (( PURGE_PACKAGES )) && purge_packages
  log "Vymrland uninstalled. Log out / restart Hyprland to fully apply."
}

main "$@"
