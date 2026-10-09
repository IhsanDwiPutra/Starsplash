# GDD — Starsplash (Game Shmup 2D)

> **Source of truth.** Semua keputusan desain ada di sini. AI agent WAJIB membaca dokumen ini sebelum mengerjakan fitur. Jika ada konflik antara permintaan dan dokumen ini, tanyakan dulu, lalu perbarui dokumen.
> Status: **v0.3** — 2026-10-09 | Root project: `PROJEK/Starsplash/`

## 1. Visi
Game shoot 'em up (shmup) 2D horizontal yang lucu, berwarna, dan seru, dengan referensi **Platypus** (PC): kapal kecil menembak gelombang musuh sambil melintasi dunia-dunia unik. Ringan, cepat dimainkan, mudah dipelajari.

**Pilar desain**
1. **Seru dalam 10 detik pertama.** Kontrol responsif, tembakan memuaskan.
2. **Game feel utama.** Ledakan, efek, dan suara memberi umpan balik jelas.
3. **Adil.** Kematian harus terasa salah pemain, bukan salah game.
4. **Scope kecil, selesai dulu.** Selesaikan MVP sebelum menambah konten.

## 2. Platform & Teknis
| Item | Keputusan |
|---|---|
| Engine | Godot **4.7.1** stable |
| Bahasa | GDScript (static typing) |
| Renderer | **Compatibility** (agar aman di PC, Android, Web) |
| Target | PC (utama) → Web → Android |
| Resolusi dasar | 1920x1080 (16:9), stretch mode `canvas_items`, aspect `keep` |
| Input PC | Keyboard + Gamepad |
| Input Mobile | Joystick virtual + tombol tembak/rudal di layar (fase Android) |
| Mode | **Single player** (co-op lokal ditunda, struktur kode jangan menutup kemungkinan ini) |
| MCP | Tidak digunakan dulu; AI memakai CLI Godot (`--headless`, `--export-*`) |

## 3. Struktur Game
- **Linear:** beberapa **dunia**, tiap dunia berisi 2–3 level + 1 boss, dimainkan berurutan tanpa world map.
- Setelah boss: layar hasil (skor, bonus), lanjut ke dunia berikutnya.
- **Rencana dunia:** (1) Laut & Es → (2) Gurun → (3) Luar Angkasa. *Hanya dunia 1 dalam MVP.*
- Alur layar: Splash → Menu Utama → Pilih Kesulitan → Level → Hasil → … → Game Over / Tamat.

## 4. Gameplay Inti
### 4.1 Scroll & Gerak
- Layar **scroll horizontal otomatis kiri ke kanan**, kapal pemain di sisi kiri.
- Kapal bergerak bebas **8 arah** (analog di gamepad) dalam batas layar.
- Parallax background 3–4 lapisan untuk kedalaman.

### 4.2 Senjata
- **Tembakan utama:** otomatis/tahan tombol, peluru lurus ke kanan.
- **Upgrade bertingkat (level 1–5):** dari power-up; jumlah/pola peluru bertambah. **Kena hit tanpa shield → turun 1 tingkat.**
- **Rudal:** amunisi terbatas, damage besar, isi ulang dari pickup.
- **Shield:** menyerap 1 hit, hilang setelah dipakai.

### 4.3b Mekanik Khas: Starsplash Combo
Identitas utama game ini (pembeda dari game referensi).
- Musuh yang hancur **melepas bintang kecil**; bintang tertarik ke kapal saat dekat.
- Bintang mengisi **Splash Meter**. Saat penuh, tombol `splash` melepas **ledakan gelombang bintang**: membersihkan peluru musuh di layar dan memberi damage ke musuh sekitar.
- Kill beruntun cepat menambah **combo** yang menaikkan jumlah bintang dan skor.
- Bintang yang terlewat hilang di tepi kiri layar (mendorong pemain agresif).
- Angka di `docs/BALANCE.md`.

### 4.3 Nyawa & Kesulitan
- Pemain mulai dengan **3 nyawa**; mati → respawn di **checkpoint** level dengan invulnerable singkat.
- **Easy / Normal / Hard** mengubah: jumlah nyawa awal, kecepatan peluru musuh, HP musuh, frekuensi drop.
- Game Over saat nyawa habis (opsi continue terbatas, ditentukan nanti).

### 4.4 Skor
- Skor per musuh, combo/bonus sederhana, bonus akhir level. High score disimpan lokal.

## 5. Konten MVP (Versi Pertama)
**Cakupan: 1 dunia (Laut & Es) = 2 level + 1 boss.**
- **Musuh (5–6):** drone terbang lurus, penembak diam, pola gelombang sinus, pengejar, penyerang dari bawah/atas, mini-turret terrain.
- **Boss:** 1, 2–3 fase serangan.
- **Power-up (3):** upgrade senjata, rudal, shield.
- **UI:** menu utama, pause, HUD (skor, nyawa, shield, rudal), layar hasil, game over.
- **Audio:** musik 1 level + SFX dasar (tembak, ledak, pickup, hit).
- **Di luar MVP:** co-op, dunia 2–3, world map, loadout, achievements.

## 6. Cerita & Tema
Ringan dan lucu. **Premis:** Bintang-bintang di galaksi mulai jatuh dan menghilang karena ulah **Raja Gloop**, makhluk usil pencuri bintang. **Pip**, bintang kecil yang menaiki kapal mungilnya, berangkat mengambil kembali bintang-bintang itu dari dunia ke dunia.
- **Pahlawan:** Pip (bintang kecil, ceria, nekat) + kapal mungil.
- **Antagonis:** Raja Gloop; boss tiap dunia adalah anak buahnya, boss akhir adalah Raja Gloop.
- **Dunia 1:** **Laut Beku** (musuh bertema gelembung & es usil). Dunia berikutnya (setelah MVP): Gurun Kaca, Langit Kunang-kunang.
- **Penyampaian:** teks intro singkat per dunia; **tanpa dialog panjang**.

## 7. Arah Visual & Audio
- **Fase 1:** placeholder 2D (bentuk sederhana / aset gratis berlisensi jelas). Fokus gameplay.
- **Fase akhir:** gaya **pastel flat dengan outline tebal**, ringan, bersih, cocok untuk Web/Android. Gambar `docs/reference/platypus.jpg` hanya inspirasi *rasa* (cerah, lucu); **jangan meniru** gaya claymation, karakter, atau desain musuhnya. Starsplash harus punya identitas sendiri.
- Palet cerah, kontras tinggi, peluru musuh mudah dibedakan dari background.
- Aset pihak ketiga: catat sumber dan lisensi di `docs/CREDITS.md`.

## 8. Struktur Proyek (usulan)
```
PROJEK/Starsplash/   <- root project Godot & repo Git
├─ docs/            GDD.md, ROADMAP.md, CREDITS.md
├─ project.godot
├─ scenes/          player/ enemies/ bosses/ levels/ ui/ pickups/ fx/
├─ scripts/         mirror scenes + autoload/ (GameState, Audio, Save)
├─ assets/          art/ audio/ fonts/
└─ export/          build output (di-.gitignore)
```

## 9. Konvensi Kode (untuk AI)
- GDScript **static typed**; nama file `snake_case`, class `PascalCase`.
- Satu skrip per scene, komunikasi antar-node pakai **signal**; hindari `get_node` jauh.
- Data balance (HP, speed, damage) di **Resource** (`.tres`) atau konstanta, bukan hardcode tersebar.
- Peluru & musuh pakai **object pooling** jika terasa berat (penting untuk Web/Android).
- Collision layer terdokumentasi: 1 Player, 2 Player Bullet, 3 Enemy, 4 Enemy Bullet, 5 Pickup, 6 Terrain.
- Input lewat **Input Map** (`move_*`, `fire`, `missile`, `pause`), jangan baca key langsung.
- Setelah perubahan, jalankan cek headless untuk memastikan tidak ada error parse.
- Satu fitur kecil per tugas, lalu commit Git.

## 10. Roadmap
| Fase | Isi | Selesai bila |
|---|---|---|
| 0 | Setup project, Git, input map, rules AI | Proyek terbuka tanpa error |
| 1 | Prototipe: kapal, tembak, 2 musuh, tabrakan, skor | Seru dimainkan 2 menit |
| 2 | Core loop: parallax, power-up, rudal, shield, nyawa, ledakan, audio dasar | Level 1 bisa ditamatkan |
| 3 | Level 2, musuh lengkap, boss, menu, pause, hasil | MVP lengkap di PC |
| 4 | Export Web, tes performa | Jalan di browser |
| 5 | Kontrol touch, export Android | Jalan di HP |
| 6 | Polish visual/audio, dunia berikutnya | — |

## 11. Risiko
- **Scope creep:** tahan konten baru sampai MVP selesai.
- **Performa Web/Android:** tes export sejak Fase 4, bukan di akhir.
- **Versi Godot baru (4.7.1):** AI mungkin memakai API lama; verifikasi dengan dokumentasi resmi.
- **Aset visual:** gaya claymation mahal; tunda ke fase poles.

## 12. Keputusan Terbuka
- Sistem continue / jumlah continue.
- Jenis lengkap musuh dan pola boss.
- Sumber musik/SFX.
- Kapan co-op dipertimbangkan (pasca-MVP).

## 13. Log Perubahan
- v0.1 (2026-10-09): draft awal berdasarkan keputusan diskusi.
- v0.2 (2026-10-09): judul final **Starsplash**; dokumen dipindah ke `PROJEK/Starsplash/docs/` (root project terpisah dari proyek lain).
- v0.3 (2026-10-09): tambah mekanik khas Starsplash Combo, premis cerita (Pip vs Raja Gloop), gaya visual pastel flat.
