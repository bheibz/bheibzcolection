#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
README="$ROOT_DIR/README.md"
REPOS="$ROOT_DIR/repos.md"

START_MARK="<!-- repos:list:start -->"
END_MARK="<!-- repos:list:end -->"

if [[ ! -f "$README" || ! -f "$REPOS" ]]; then
  echo "README.md atau repos.md tidak ditemukan" >&2
  exit 1
fi

# Build list from repos.md
list_lines=()
while IFS= read -r line; do
  line="$(echo "$line" | sed -e 's/^[[:space:]]*//;s/[[:space:]]*$//')"
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
    [[ -n "$deps" ]] && list_lines+=("- deps: $deps")
    continue
  fi

  if [[ "$line" == cmd:* ]]; then
    cmd="${line#cmd:}"
    cmd="$(echo "$cmd" | sed -e 's/^[[:space:]]*//')"
    [[ -n "$cmd" ]] && list_lines+=("- cmd: $cmd")
    continue
  fi

  if [[ "$line" =~ ^https?://github\.com/[^/]+/[^/]+ ]]; then
    owner_repo="$(echo "$line" | sed -E 's#https?://github\.com/([^/]+/[^/]+).*#\1#')"
    list_lines+=("- $owner_repo")
  fi

done < "$REPOS"

if [[ "${#list_lines[@]}" -eq 0 ]]; then
  list_lines=("- (kosong)")
fi

# Prepare replacement block
block="$START_MARK\n"
block+="*(Auto-generated dari `repos.md`)*\n\n"
for item in "${list_lines[@]}"; do
  block+="$item\n"
done
block+="$END_MARK"

# Replace between markers
if ! grep -q "$START_MARK" "$README"; then
  echo "Marker start tidak ditemukan di README.md" >&2
  exit 1
fi
if ! grep -q "$END_MARK" "$README"; then
  echo "Marker end tidak ditemukan di README.md" >&2
  exit 1
fi

perl -0777 -i -pe "s#\Q$START_MARK\E.*?\Q$END_MARK\E#$block#s" "$README"

