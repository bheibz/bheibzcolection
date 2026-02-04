#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIST_FILE="$ROOT_DIR/repos.md"
DEST_DIR="$ROOT_DIR/vendor"
RUN_COMMANDS=0
INSTALL_DEPS=0

deps_list=()
cmd_list=()
repo_list=()

for arg in "$@"; do
  case "$arg" in
    --run-commands) RUN_COMMANDS=1 ;;
    --install-deps) INSTALL_DEPS=1 ;;
    -h|--help)
      cat <<'USAGE'
Usage: ./install.sh [--run-commands] [--install-deps]

Reads repos.md and:
- clones GitHub repos
- optionally runs command lines prefixed with "cmd:"
- optionally installs deps listed with "deps:"
USAGE
      exit 0
      ;;
    *)
      echo "Argumen tidak dikenal: $arg" >&2
      exit 1
      ;;
  esac
done

if [[ ! -f "$LIST_FILE" ]]; then
  echo "File repos.md tidak ditemukan di $ROOT_DIR" >&2
  exit 1
fi

if ! command -v git >/dev/null 2>&1; then
  echo "git belum terpasang. Silakan install git terlebih dahulu." >&2
  exit 1
fi

# Baca repos.md: ambil URL GitHub dari setiap baris
while IFS= read -r line; do
  # trim spasi dan tab
  line="$(echo "$line" | sed -e 's/^[[:space:]]*//;s/[[:space:]]*$//')"

  # buang komentar inline (setelah #)
  line="${line%%#*}"
  line="$(echo "$line" | sed -e 's/^[[:space:]]*//;s/[[:space:]]*$//')"

  # lewati kosong, komentar, atau heading
  [[ -z "$line" ]] && continue
  [[ "$line" == \#* ]] && continue

  # jika pakai bullet "- ", buang prefix
  if [[ "$line" == -* ]]; then
    line="${line#-}"
    line="${line# }"
  fi

  # deps: paket1 paket2 ...
  if [[ "$line" == deps:* ]]; then
    deps="${line#deps:}"
    deps="$(echo "$deps" | sed -e 's/^[[:space:]]*//')"
    if [[ -n "$deps" ]]; then
      deps_list+=("$deps")
    fi
    continue
  fi

  # cmd: perintah shell
  if [[ "$line" == cmd:* ]]; then
    cmd="${line#cmd:}"
    cmd="$(echo "$cmd" | sed -e 's/^[[:space:]]*//')"
    if [[ -n "$cmd" ]]; then
      cmd_list+=("$cmd")
    fi
    continue
  fi

  # pastikan terlihat seperti URL github
  if [[ ! "$line" =~ ^https?://github\.com/[^/]+/[^/]+ ]]; then
    echo "Lewati baris (bukan URL GitHub / cmd / deps): $line" >&2
    continue
  fi

  repo_list+=("$line")
done < "$LIST_FILE"

mkdir -p "$DEST_DIR"

if [[ "$INSTALL_DEPS" -eq 1 ]]; then
  if ! command -v apt-get >/dev/null 2>&1; then
    echo "apt-get tidak ditemukan. Jalankan instal deps secara manual." >&2
    INSTALL_DEPS=0
  fi
fi

if [[ "${#deps_list[@]}" -gt 0 ]]; then
  if [[ "$INSTALL_DEPS" -eq 1 ]]; then
    echo "Install deps: ${deps_list[*]}"
    sudo apt-get update -y
    sudo apt-get install -y ${deps_list[*]}
  else
    echo "Deps terdeteksi (jalankan dengan --install-deps): ${deps_list[*]}"
  fi
fi

if [[ "${#repo_list[@]}" -gt 0 ]]; then
  for repo_url in "${repo_list[@]}"; do
    repo_name="$(basename "$repo_url" .git)"
    owner="$(basename "$(dirname "$repo_url")")"
    target_dir="$DEST_DIR/${owner}-${repo_name}"

    if [[ -d "$target_dir/.git" ]]; then
      echo "Sudah ada: $target_dir (skip)"
      continue
    fi

    echo "Cloning $repo_url -> $target_dir"
    git clone "$repo_url" "$target_dir"
  done
fi

if [[ "${#cmd_list[@]}" -gt 0 ]]; then
  if [[ "$RUN_COMMANDS" -eq 1 ]]; then
    for cmd in "${cmd_list[@]}"; do
      echo "Menjalankan: $cmd"
      bash -c "$cmd"
    done
  else
    for cmd in "${cmd_list[@]}"; do
      echo "Command terdeteksi (jalankan dengan --run-commands): $cmd"
    done
  fi
fi

echo "Selesai. Repo ada di $DEST_DIR"
