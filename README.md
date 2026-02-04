# Repo Installer

Repo ini menginstall daftar repo GitHub yang kamu tulis di `repos.md`.

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

## Fitur Aplikasi (Daftar di repos.md)

Daftar di bawah ini mengikuti isi `repos.md` saat ini:
- `google-gemini/gemini-cli`: CLI untuk menggunakan Gemini.
- `QwenLM/qwen-code`: CLI/alat terkait Qwen Code.
- `lencx/Noi`: Aplikasi desktop (butuh Node.js 20+).
- `cmd: curl -fsS https://dl.brave.com/install.sh | sh`: Install Brave Browser.
- `cmd: curl -qL https://www.npmjs.com/install.sh | sh`: Install Node.js via script npmjs.
- `deps: wget curl python3`: Dependency dasar untuk beberapa installer.
