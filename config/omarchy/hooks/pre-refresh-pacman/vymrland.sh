#!/bin/bash
# Vymrland: runs before `omarchy refresh pacman` re-syncs packages.
#
# The personal pacman repository is deferred (see the .sample in this
# directory). For now this hook only verifies the AUR helper is present; when
# the repo exists, add it here before the refresh.
set -euo pipefail

if ! command -v yay >/dev/null 2>&1; then
  echo "vymrland: yay not found; AUR packages cannot be installed" >&2
fi

exit 0
