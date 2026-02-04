#!/usr/bin/env bash
set -euo pipefail

APP_DIR="${HOME}/Applications"
BIN_DIR="${HOME}/.local/bin"

mkdir -p "$APP_DIR" "$BIN_DIR"

api_url="https://api.github.com/repos/lencx/noi/releases/latest"

asset_url="$(curl -fsSL "$api_url" | python3 - <<'PY'
import json, sys, re
try:
    data = json.load(sys.stdin)
    assets = data.get("assets", [])
    for a in assets:
        name = a.get("name", "")
        if re.match(r"Noi_linux_.*\.AppImage$", name):
            print(a.get("browser_download_url", ""))
            sys.exit(0)
except Exception:
    pass
print("")
PY
)"

if [[ -z "$asset_url" ]]; then
  echo "Gagal menemukan AppImage Noi di GitHub Releases." >&2
  exit 1
fi

app_path="$APP_DIR/Noi.AppImage"

echo "Download Noi: $asset_url"
curl -fsSL "$asset_url" -o "$app_path"
chmod +x "$app_path"

ln -sf "$app_path" "$BIN_DIR/noi"

echo "Noi terpasang di: $app_path"
echo "Jalankan dengan: $BIN_DIR/noi"
