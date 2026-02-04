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
