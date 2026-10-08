#!/bin/bash
# Vymrland: re-apply after Omarchy updates.
#
# Runs from ~/.config/omarchy/hooks/post-update.d/ during `omarchy update`,
# after system packages and migrations. Re-applies configs, hooks, theme, and
# the HyprVim pin; skips packages (the update just handled them).
set -euo pipefail

REPO="${VYMLAND_DIR:-$HOME/Projects/vymrland}"
[[ -x "$REPO/install.sh" ]] || exit 0

"$REPO/install.sh" --no-packages
notify-send -a Vymrland "Vymrland" "Re-applied after Omarchy update" 2>/dev/null || true
