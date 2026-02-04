#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
README="$ROOT_DIR/README.md"
REPOS="$ROOT_DIR/repos.md"

START_MARK="<!-- repos:list:start -->"
END_MARK="<!-- repos:list:end -->"
STATUS_START="<!-- status:start -->"
STATUS_END="<!-- status:end -->"

if [[ ! -f "$README" || ! -f "$REPOS" ]]; then
  echo "README.md atau repos.md tidak ditemukan" >&2
  exit 1
fi

list_lines=()
invalid_lines=()

github_desc() {
  local owner_repo="$1"
  local api_url="https://api.github.com/repos/$owner_repo"
  local auth=()
  if [[ -n "${GITHUB_TOKEN:-}" ]]; then
    auth=(-H "Authorization: Bearer ${GITHUB_TOKEN}")
  fi
  curl -fsSL "${auth[@]}" "$api_url" | python3 - <<'PY'
import json, sys
try:
    data = json.load(sys.stdin)
    desc = (data.get("description") or "").strip()
    print(desc)
except Exception:
    print("")
PY
}

# Build list from repos.md
while IFS= read -r line; do
  line="$(echo "$line" | sed -e 's/^[[:space:]]*//;s/[[:space:]]*$//')"
  comment=""
  if [[ "$line" == *#* ]]; then
    comment="${line#*#}"
    comment="$(echo "$comment" | sed -e 's/^[[:space:]]*//')"
  fi
  line="${line%%#*}"
  line="$(echo "$line" | sed -e 's/^[[:space:]]*//;s/[[:space:]]*$//')"
  [[ -z "$line" ]] && continue
  [[ "$line" == \#* ]] && continue
  if [[ "$line" == -* ]]; then
    line="${line#-}"
    line="${line# }"
  fi

  if [[ "$line" == deps:* ]]; then
    deps="${line#deps:}"
    deps="$(echo "$deps" | sed -e 's/^[[:space:]]*//')"
    if [[ -n "$deps" ]]; then
      item="- deps: $deps"
      [[ -n "$comment" ]] && item="$item (${comment})"
      list_lines+=("$item")
    else
      invalid_lines+=("$line")
    fi
    continue
  fi

  if [[ "$line" == cmd:* ]]; then
    cmd="${line#cmd:}"
    cmd="$(echo "$cmd" | sed -e 's/^[[:space:]]*//')"
    if [[ -n "$cmd" ]]; then
      item="- cmd: $cmd"
      [[ -n "$comment" ]] && item="$item (${comment})"
      list_lines+=("$item")
    else
      invalid_lines+=("$line")
    fi
    continue
  fi

  if [[ "$line" =~ ^https?://github\.com/[^/]+/[^/]+ ]]; then
    owner_repo="$(echo "$line" | sed -E 's#https?://github\.com/([^/]+/[^/]+).*#\1#')"
    desc="$(github_desc "$owner_repo")"
    item="- $owner_repo"
    [[ -n "$desc" ]] && item="$item — $desc"
    [[ -n "$comment" ]] && item="$item (${comment})"
    list_lines+=("$item")
  else
    invalid_lines+=("$line")
  fi

done < "$REPOS"

if [[ "${#list_lines[@]}" -eq 0 ]]; then
  list_lines=("- (kosong)")
fi

# Prepare replacement blocks
block="$START_MARK\n"
block+="*(Auto-generated dari `repos.md`)*\n\n"
for item in "${list_lines[@]}"; do
  block+="$item\n"
done
block+="$END_MARK"

# Status block
ts_utc="$(date -u +"%Y-%m-%d %H:%M UTC")"
ts_wib="$(TZ=Asia/Jakarta date +"%Y-%m-%d %H:%M WIB")"
status="$STATUS_START\n"
status+="Terakhir digenerate: $ts_wib ($ts_utc)\n\n"
if [[ "${#invalid_lines[@]}" -gt 0 ]]; then
  status+="Peringatan: ada baris tidak valid di `repos.md`:\n"
  for bad in "${invalid_lines[@]}"; do
    status+="- $bad\n"
  done
else
  status+="Validasi `repos.md`: OK\n"
fi
status+="$STATUS_END"

# Replace between markers
if ! grep -q "$START_MARK" "$README"; then
  echo "Marker start tidak ditemukan di README.md" >&2
  exit 1
fi
if ! grep -q "$END_MARK" "$README"; then
  echo "Marker end tidak ditemukan di README.md" >&2
  exit 1
fi
if ! grep -q "$STATUS_START" "$README"; then
  echo "Marker status start tidak ditemukan di README.md" >&2
  exit 1
fi
if ! grep -q "$STATUS_END" "$README"; then
  echo "Marker status end tidak ditemukan di README.md" >&2
  exit 1
fi

perl -0777 -i -pe "s#\Q$START_MARK\E.*?\Q$END_MARK\E#$block#s" "$README"
perl -0777 -i -pe "s#\Q$STATUS_START\E.*?\Q$STATUS_END\E#$status#s" "$README"

if [[ "${#invalid_lines[@]}" -gt 0 ]]; then
  echo "repos.md punya baris tidak valid" >&2
  exit 2
fi
