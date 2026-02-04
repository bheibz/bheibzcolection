<div align="center">
  <img src="https://readme-typing-svg.demolab.com?font=Fira+Code&size=22&duration=2400&pause=500&color=111111&center=true&vCenter=true&width=700&lines=Bheibz+Collection+Installer;Satu+Perintah%2C+Semua+Terpasang;Auto+Update+Setiap+Hari" alt="typing" />
  <br />
  <img src="https://img.shields.io/github/license/bheibz/bheibzcolection" alt="license" />
  <img src="https://img.shields.io/github/actions/workflow/status/bheibz/bheibzcolection/auto-update.yml" alt="actions" />
  <img src="https://img.shields.io/github/last-commit/bheibz/bheibzcolection" alt="last-commit" />
  <img src="https://img.shields.io/github/repo-size/bheibz/bheibzcolection" alt="repo-size" />
  <img src="https://img.shields.io/badge/WhatsApp-+62895%201313%202933-25D366?logo=whatsapp&logoColor=white" alt="whatsapp" />
  <img src="https://img.shields.io/badge/Donasi-Dana%20%7C%20OVO%20%7C%20GoPay-blue" alt="donasi" />
</div>

# Repo Installer

Repo ini menginstall daftar repo GitHub yang kamu tulis di `repos.md`.

Catatan penting: script ini **meng-clone repo** dan **menjalankan command** yang kamu tulis di `repos.md`.
Proses instalasi aplikasi tergantung pada masing-masing repo/command (misalnya `cmd:` untuk installer).

## Satu Perintah (PC Baru)

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/bheibz/bheibzcolection/main/bootstrap.sh)"
```

## Cara pakai

1. Tambahkan link repo di `repos.md` (satu per baris, bisa pakai bullet `- `).
2. Jika perlu menjalankan command atau install dependency, gunakan prefix:
   - `cmd: ...` untuk command
   - `deps: ...` untuk dependency
3. Jalankan installer:

```bash
./install.sh
./install.sh --run-commands
./install.sh --install-deps
./install.sh --no-update
```

## Catatan

- Script hanya akan `git clone` repo yang belum ada.
- Jika repo sudah ada, script akan `git pull` otomatis (gunakan `--no-update` untuk skip).
- Folder hasil clone akan dibuat di `./vendor`.
- Pastikan `git` sudah terpasang.

## Auto Update (GitHub Actions)

Repo ini punya workflow yang otomatis update setiap hari jam 06:00 WIB (UTC+7) dan commit perubahan `vendor/` ke repo ini.
Kamu juga bisa menjalankan manual lewat tab Actions di GitHub.

## Status Otomatisasi

<!-- status:start -->
Terakhir digenerate: (belum pernah)

Validasi `repos.md`: OK
<!-- status:end -->

## Fitur Aplikasi (Daftar di repos.md)

Daftar di bawah ini mengikuti isi `repos.md` saat ini:

<!-- repos:list:start -->
*(Auto-generated dari `repos.md`)*

- google-gemini/gemini-cli
- QwenLM/qwen-code
- cmd: curl -fsS https://dl.brave.com/install.sh | sh
- lencx/Noi
- cmd: curl -qL https://www.npmjs.com/install.sh | sh
- deps: wget curl python3
<!-- repos:list:end -->

## Info Kami

- Web: https://github.com/bheibz/the-power-of-berbagi
- GitHub: https://github.com/bheibz/bheibz
- Dikerjakan oleh bheibz digital meedia dan codex

## Donasi

Terima donasi uang dan barang elektronik komputer.
Untuk konfirmasi transfer atau donasi barang, hubungi WhatsApp: +62895 1313 2933.

Metode donasi:
- Dana/OVO/GoPay: +62895 1313 2933
- blu: konfirmasi via WhatsApp
- BRI: konfirmasi via WhatsApp

## Kontribusi

Panduan kontribusi ada di `CONTRIBUTING.md`.
Daftar repo rekomendasi ada di `RECOMMENDED_REPOS.md`.
