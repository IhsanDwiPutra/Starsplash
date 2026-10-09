# AGENTS.md — Starsplash

Game shmup 2D horizontal, Godot **4.7.1**, GDScript. Target: PC → Web → Android.
File ini berlaku untuk **semua model AI** (Claude, Gemini, dll). Ikuti persis.

## Wajib baca sebelum bekerja (urut)
1. `docs/GDD.md` — desain game (source of truth)
2. `docs/ARCHITECTURE.md` — struktur kode, layer, input map
3. `docs/ROADMAP.md` — status tugas & catatan serah-terima terakhir
4. `docs/DECISIONS.md` — keputusan teknis yang sudah final
5. `docs/BALANCE.md` — angka gameplay (jangan hardcode angka lain)

## Aturan kerja
1. **Satu tugas kecil per sesi.** Ambil tugas berikutnya yang belum dicentang di `ROADMAP.md`.
2. **Jangan menyimpang dari GDD.** Jika perlu mengubah desain, tanya user dulu, lalu update GDD + log versinya.
3. **Jangan refactor besar, ganti struktur folder, atau tambah plugin/dependensi** tanpa izin user.
4. **Jangan menambah konten di luar MVP** (lihat GDD bagian 5).
5. Jika tidak yakin API Godot 4.7.1, **cek dokumentasi resmi**, jangan menebak dari memori.
6. Angka balance hanya dari `docs/BALANCE.md` / Resource `.tres`.
7. Keputusan teknis baru yang penting → tambahkan ke `docs/DECISIONS.md`.
8. Aset pihak ketiga → catat di `docs/CREDITS.md` (sumber + lisensi).

## Standar kode
- GDScript **static typed**. File `snake_case`, class `PascalCase`.
- Satu skrip per scene; komunikasi lewat **signal**.
- Input hanya lewat Input Map (lihat ARCHITECTURE).
- Bahasa komentar kode & dokumen: **Indonesia** untuk dokumen, Inggris untuk identifier.
- Jangan hapus komentar/docstring yang tidak terkait perubahan.

## Verifikasi (wajib sebelum menyatakan selesai)
```powershell
# dari root Starsplash
..\Godot_v4.7.1-stable_win64_console.exe --headless --path . --quit
```
Tidak boleh ada error parse/script. Laporkan jika ada warning penting.

## Git
- Commit kecil per fitur, pesan: `feat:`, `fix:`, `docs:`, `chore:`, `refactor:`.
- Jangan commit `.godot/`, `export/`. Jangan `git push --force`.
- Jangan menyentuh kredensial Git/GitHub.

## Serah-terima (akhir setiap sesi)
Di `docs/ROADMAP.md`: centang tugas selesai, lalu tulis di "Catatan Serah-Terima": apa yang dikerjakan, file utama yang berubah, masalah terbuka, langkah berikutnya yang disarankan.
