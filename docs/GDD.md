# GDD — Starsplash (Game Shmup 2D)

> **Source of truth.** Semua keputusan desain ada di sini. AI agent WAJIB membaca dokumen ini sebelum mengerjakan fitur. Jika ada konflik antara permintaan dan dokumen ini, tanyakan dulu, lalu perbarui dokumen.
> Status: **v0.4** — 2026-10-10 | Root project: `PROJEK/Starsplash/`

## 1. Visi
Game shoot 'em up (shmup) 2D horizontal petualangan arcade yang ceria, penuh warna, dan adiktif. Menggabungkan sensasi aksi tembak-menembak berkecepatan tinggi dengan sistem **Peta Tahapan (*World/Stage Map*) ala Feeding Frenzy** serta mekanik khas **Starsplash Combo**.

**Pilar desain**
1. **Seru dalam 10 detik pertama.** Kontrol responsif, tembakan memuaskan.
2. **Game feel utama.** Ledakan partikel, hit spark, screen shake, dan audio punchy memberi umpan balik jelas.
3. **Petualangan berbobot & adil.** Progresi stage demi stage di peta dunia; kematian terasa sebagai pelajaran pemain, bukan hukuman menyiksa.
4. **Koleksi Bintang (Replayability).** Sistem rating 1–3 Bintang di setiap stage memicu kepuasan penyelesaian penuh.

## 2. Platform & Teknis
| Item | Keputusan |
|---|---|
| Engine | Godot **4.7.1** stable |
| Bahasa | GDScript (static typing ketat) |
| Renderer | **Compatibility** (optimal untuk PC, Android, Web) |
| Target | PC (Windows/Linux) → Web HTML5 → Android |
| Resolusi dasar | 1920x1080 (16:9), stretch mode `canvas_items`, aspect `keep` |
| Input PC | Keyboard + Mouse + Gamepad |
| Input Mobile | Joystick virtual + tombol sentuh (Fase Android) |
| Mode | Single player (arsitektur modular untuk co-op masa depan) |
| CLI / Engine | Godot console headless untuk automated verification |

## 3. Struktur Game & Peta Tahapan (World Map)
Game dirancang sebagai petualangan panjang 4 Dunia dengan **Peta Rute Bertitik (*Dot-to-Dot Stage Map*)**:
- **Total Konten:** **4 Dunia $\times$ 6 Stage = 24 Stage Total** (~45–60 menit play-through pertama).
- **Rencana 4 Dunia:**
  1. **Dunia 1: Laut Beku (*The Frozen Sea*)** — Pegunungan es, riak laut malam, aurora, gelembung es.
  2. **Dunia 2: Gurun Kristal (*Crystal Dunes*)** — Pasir senja keemasan, badai pasir, cacing kristal mekanik.
  3. **Dunia 3: Hutan Neon Kunang-kunang (*Neon Canopy*)** — Lumut bercahaya, spora mengambang, serangga mekanik.
  4. **Dunia 4: Benteng Galaksi Raja Gloop (*Cosmic Citadel*)** — Pabrik gelap pencetak lendir, reaktor bintang utama.

- **Formula 6 Stage per Dunia:**
  - **Stage 1 & 2:** Pengenalan rintangan & formasi gelombang dasar (Line, V).
  - **Stage 3 (MINI-BOSS):** Duel melawan musuh elit sub-komandan (~40–50 HP) sebagai klimaks paruh pertama dunia.
  - **Stage 4 & 5:** Eskalasi rintangan ekstrim (badai, rintangan lingkungan, turret, penyerang vertikal).
  - **Stage 6 (MAJOR BOSS DUNIA):** Arena pertarungan bos utama multi-fase (3 Fase, Boss Bar HUD, ledakan pamungkas berantai).

- **Alur Layar:**
  `Menu Utama` $\rightarrow$ `Intro Komik 3 Panel` (pertama kali / opsi putar ulang) $\rightarrow$ `Peta Dunia (*World Map*)` $\rightarrow$ Pilih Stage Terbuka $\rightarrow$ `Gameplay Shmup` $\rightarrow$ `Layar Hasil (Rating Bintang & Skor)` $\rightarrow$ Kembali ke Peta (Stage berikutnya terbuka).

## 4. Gameplay Inti
### 4.1 Scroll & Gerak
- Layar scroll horizontal otomatis kiri ke kanan, kapal Pip di sisi kiri.
- Kapal bergerak bebas 8 arah (analog gamepad / WASD / Panah) dalam batas layar.
- Parallax background multi-layer (6 lapis prosedural Laut Beku).

### 4.2 Senjata & Tempur
- **Tembakan Utama:** Tahan tombol tembak untuk tembakan beruntun.
- **Tingkat Senjata (Lv 1–5):** Durasi 16 detik per upgrade. Kena hit tanpa shield $\rightarrow$ turun 1 level.
- **Rudal:** Amunisi terbatas, ledakan area 10 damage, diisi ulang dari pickup [M].
- **Shield:** Menyerap 1 kali benturan musuh/peluru, melindungi nyawa dan level senjata.
- **Mekanik Khas: Starsplash Combo:**
  - Musuh hancur melepaskan bintang; bintang mengisi Splash Meter (30).
  - Saat penuh, tombol `splash` melepas gelombang pembersih peluru musuh di seluruh layar dan memberi 8 damage instan.

### 4.3 Nyawa, Kesulitan & Sistem Retry Peta
- **Tingkat Kesulitan (Dapat Dipilih di Menu):**
  - **Mudah:** 5 Nyawa awal, peluru musuh santai (350 px/s).
  - **Normal:** 3 Nyawa awal, kecepatan standar (450 px/s).
  - **Sulit:** 2 Nyawa awal, peluru musuh cepat & agresif (550 px/s).
- **Game Over Ramah Pemain (Sistem Stage Map):**
  - Jika nyawa habis di tengah stage: Layar Game Over menawarkan **[Coba Lagi]** di stage tersebut atau **[Kembali ke Peta]**.
  - **Tidak ada permadeath ke Stage 1-1.** Stage yang sudah dibuka di peta tetap tersimpan permanen.

### 4.4 Sistem Rating Bintang (⭐ 1–3 per Stage)
- **⭐ Bintang 1 (Clear):** Menyelesaikan stage sampai garis akhir.
- **⭐ Bintang 2 (Kolektor Bintang):** Mengumpulkan target minimal bintang di stage tersebut.
- **⭐ Bintang 3 (Penguasaan):** Selesai tanpa kehilangan nyawa ATAU mengaktifkan Splash Bomb minimal 2 kali.
- Bintang tersimpan di profil pemain untuk membuka dunia berikutnya.

## 5. Konten MVP vs Rilis Penuh
- **Fokus MVP Saat Ini:** Dunia 1: Laut Beku (Stage 1-1 s/d 1-6 lengkap + World Map Laut Beku + Mini-Boss Stage 1-3 + Major Boss Glacier Gloop 1-6).
- **Rilis Penuh:** Melengkapi Dunia 2, 3, dan 4 secara modular.

## 6. Cerita & Narasi
- **Premis:** Bintang-bintang galaksi dicuri dan disedot oleh **Raja Gloop** untuk memberi daya pada armada lendir antargalaksinya. **Pip**, bintang kecil pemberani bertopi pilot, meluncur dengan kapal mungilnya untuk membebaskan saudara-saudaranya.
- **Penyampaian Narasi: Komik Visual 3 Panel (Tanpa Dialog Panjang):**
  - Panel 1: Langit malam galaksi damai penuh bintang tersenyum.
  - Panel 2: Pesawat balon lendir Raja Gloop menyedot bintang-bintang ke dalam toples kosmik raksasa.
  - Panel 3: Pip mengenakan kacamata pilot, menaiki kapalnya dengan tekad bulat: *"Aku akan bebaskan semua bintang!"*

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
