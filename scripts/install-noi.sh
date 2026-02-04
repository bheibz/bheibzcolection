#!/usr/bin/env bash
set -euo pipefail

APP_DIR="${HOME}/Applications"
BIN_DIR="${HOME}/.local/bin"
TMP_DIR="${HOME}/Downloads"

mkdir -p "$APP_DIR" "$BIN_DIR" "$TMP_DIR"

api_url="https://api.github.com/repos/lencx/noi/releases/latest"

os_id=""
if [[ -f /etc/os-release ]]; then
  os_id="$(. /etc/os-release && echo "${ID:-}")"
fi

want_deb=0
if [[ "$os_id" == "debian" || "$os_id" == "ubuntu" ]]; then
  want_deb=1
fi

asset_url="$(curl -fsSL "$api_url" | python3 - <<'PY'
import json, sys, re
try:
    data = json.load(sys.stdin)
    assets = data.get("assets", [])
    want_deb = (sys.argv[1] == "1")
    if want_deb:
        for a in assets:
            name = a.get("name", "")
            if re.match(r"Noi_linux_.*\.deb$", name):
                print(a.get("browser_download_url", ""))
                sys.exit(0)
    for a in assets:
        name = a.get("name", "")
        if re.match(r"Noi_linux_.*\.AppImage$", name):
            print(a.get("browser_download_url", ""))
            sys.exit(0)
except Exception:
    pass
print("")
PY
 "$want_deb")"

if [[ -z "$asset_url" ]]; then
  echo "Gagal menemukan rilis Noi (deb/AppImage) di GitHub Releases." >&2
  exit 1
fi

if [[ "$asset_url" == *.deb ]]; then
  deb_path="$TMP_DIR/Noi.deb"
  echo "Download Noi (deb): $asset_url"
  curl -fsSL "$asset_url" -o "$deb_path"
  echo "Install paket deb..."
  sudo dpkg -i "$deb_path" || sudo apt-get -f install -y
  echo "Noi terpasang (deb)."
  exit 0
fi

app_path="$APP_DIR/Noi.AppImage"

echo "Download Noi: $asset_url"
curl -fsSL "$asset_url" -o "$app_path"
chmod +x "$app_path"

ln -sf "$app_path" "$BIN_DIR/noi"

echo "Noi terpasang di: $app_path"
echo "Jalankan dengan: $BIN_DIR/noi"
