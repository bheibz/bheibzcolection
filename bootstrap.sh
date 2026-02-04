#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/bheibz/bheibzcolection"
DIR_NAME="${HOME}/bheibzcolection"

if ! command -v git >/dev/null 2>&1; then
  echo "git belum terpasang. Silakan install git terlebih dahulu." >&2
  exit 1
fi

if [[ -d "$DIR_NAME/.git" ]]; then
  echo "Folder $DIR_NAME sudah ada, masuk ke sana dan update."
  cd "$DIR_NAME"
  git pull --ff-only
else
  git clone "$REPO_URL" "$DIR_NAME"
  cd "$DIR_NAME"
fi

chmod +x install.sh
./install.sh --install-deps --run-commands
