#!/bin/bash
# Vymrland: runs after `omarchy theme set <slug>` (slug in $1).
#
# Theme changes regenerate Omarchy's themed files (ghostty, neovim colors) but
# do not touch Vymrland's editor keymap reverts, so re-apply them here to keep
# the two layers in sync.
set -euo pipefail

REPO="${VYMLAND_DIR:-$HOME/Projects/vymrland}"
[[ -d "$REPO/config/nvim" ]] || exit 0

rsync -a "$REPO/config/nvim/" "$HOME/.config/nvim/"
