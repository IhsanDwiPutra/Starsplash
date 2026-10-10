# DECISIONS — Starsplash

Keputusan yang **sudah final**. Jangan dibatalkan tanpa persetujuan user. Entri baru di bawah.

| # | Tanggal | Keputusan | Alasan |
|---|---|---|---|
| 1 | 2026-10-09 | Engine Godot 4.7.1, GDScript | Ringan, export PC/Web/Android |
| 2 | 2026-10-09 | Renderer Compatibility | Aman di Web & Android |
| 3 | 2026-10-09 | Tanpa MCP Godot; pakai CLI | Sederhana, cukup untuk kebutuhan awal |
| 4 | 2026-10-09 | Visual placeholder 2D dulu | Fokus gameplay, gaya claymation belakangan |
| 5 | 2026-10-09 | Single player dulu | Kurangi scope; co-op pasca-MVP |
| 6 | 2026-10-09 | Struktur linear, scroll horizontal, gerak 8 arah | Sesuai referensi Platypus |
| 7 | 2026-10-09 | Nama game: Starsplash | Fleksibel untuk semua dunia |
| 8 | 2026-10-09 | Root project & repo Git: `PROJEK/Starsplash/` | Terpisah dari project lain |
| 9 | 2026-10-09 | MVP: 1 dunia (Laut & Es), 2 level + boss | Cegah scope creep |
| 10 | 2026-10-09 | Repo GitHub private dulu | Publikasi nanti |
| 11 | 2026-10-09 | Mekanik khas: Starsplash Combo (bintang dari musuh, Splash Meter, ledakan Splash) | Pembeda dari game referensi |
| 12 | 2026-10-09 | Visual akhir: pastel flat outline tebal; tidak meniru claymation/karakter referensi | Identitas sendiri, ringan di Web/Android |
| 13 | 2026-10-09 | Premis: Pip (bintang kecil) vs Raja Gloop (pencuri bintang); Dunia 1 Laut Beku | Arah cerita ringan yang konsisten |
| 14 | 2026-10-09 | Splash Meter, kombo, dan multiplier disimpan di autoload GameState (bukan node terpisah) | Sederhana; HUD, Player, Enemy mengaksesnya satu tempat |
| 15 | 2026-10-09 | Senjata super (Lv 2-5) berdurasi 16 detik; drop [P] & Shield hanya dari musuh khusus/Carrier | Mencegah pemain terlalu overpowered; menjaga tensi dan tantangan |
| 16 | 2026-10-10 | Efek Ledakan Poligon Prosedural, Hit Spark & Camera Screen Shake | Game feel arcade instan tanpa ketergantungan aset tekstur eksternal, performa tinggi di semua target platform |
| 17 | 2026-10-10 | LevelRunner berbasis Timeline Data terpisah (Level1Data) dengan sistem formasi (Line, V, Wall, Swarm Sine) & Checkpoint 50% | Memisahkan logika eksekusi level dari data gelombang, mempermudah pembuatan level baru dan tuning kesulitan |
| 18 | 2026-10-10 | Arsitektur AudioManager Hibrida: Synthesizer Prosedural Otomatis + Slot Pemuatan File Audio Eksternal (.ogg/.wav) | Game langsung bersuara retro arcade tanpa file eksternal; fleksibel di-upgrade aset final kapan saja tanpa ubah kode |
| 19 | 2026-10-10 | Desain Boss Dunia 1: Glacier Gloop (HP 150, 3 fase transformasi, visual reaktif, Boss Health Bar HUD, 7 ledakan berantai saat mati) | Menghadirkan klimaks pertarungan boss arcade yang menantang namun adil, sesuai target scope GDD Dunia 1 Laut Beku |
| 20 | 2026-10-10 | Standarisasi Deteksi Damage Proyektil & Bom Splash berbasis `has_method("take_damage")` serta Hitbox Capsule Boss | Mendukung multi-entity (Enemy reguler, Boss, rintangan masa depan) secara seragam dan responsif tanpa terikat inheritance statis tunggal |
| 21 | 2026-10-10 | Mekanisme Suplai Boss Fight (Drop Hadiah Pecah Fase, Carrier Suplai Berkala, Checkpoint 2 Boss & Respawn Loadout) | Mengatasi jebakan recovery shmup sehingga pertarungan boss terasa menantang dan dinamis tanpa terasa alot atau menghukum pemain secara tidak adil |
| 22 | 2026-10-10 | Desain UI Lengkap: Menu Utama Beranimasi Parallax, Selector Kesulitan (Easy/Normal/Hard), Modal Slider Audio & Pause Menu In-Game | Memenuhi standar MVP shmup modern dengan opsi aksesibilitas pemain, kontrol audio persisten, dan pengalaman interaktif yang imersif |
| 23 | 2026-10-10 | Struktur Game Petualangan Penuh: 4 Dunia x 6 Stage = 24 Stage Total dengan Peta Rute (*World Map*) ala Feeding Frenzy | Menghadirkan rasa petualangan panjang, pencapaian geografis nyata, dan durasi bermain arcade yang berbobot (45-60 menit) |
| 24 | 2026-10-10 | Formula Bos Dinamis: Mini-Boss di Stage 3 & Major Boss Multi-Fase di Stage 6 | Memberikan irama pertempuran yang seimbang tanpa memicu kelelahan duel bos di setiap stage |
| 25 | 2026-10-10 | Sistem Rating Bintang (⭐ 1-3), Intro Komik 3 Panel, dan Retry Ramah Pemain di Peta | Mendorong replayability pengumpulan bintang, pengenalan cerita cepat tanpa dialog panjang, dan mencegah hukuman permadeath brutal |
| 26 | 2026-10-10 | Integrasi Sprite Asli Karakter Pip & Kapal Tempur Pip (`assets/art/player/`) | Menggantikan poligon placeholder dengan sprite berkualitas tinggi (Avatar Pip & Kapal Pip 2D Side-View Orthographic), menyelaraskan titik Muzzle moncong tembakan dan collision shape |
| 27 | 2026-10-10 | Sistem Partikel Pendorong Prosedural (Thruster Flame & Stardust Trail) pada Kapal Pip via CPUParticles2D | Memberikan efek semburan api roket dan jejak debu bintang yang hidup dan reaktif terhadap akselerasi maju-mundur kapal tanpa aset gambar eksternal, hemat memori dan 100% kompatibel di semua platform |
| 28 | 2026-10-10 | Fisika Inersia Halus & Kemiringan Aerodinamis (Smooth Momentum & Banking Tilt) pada Kapal Pip | Menghadirkan rasa kendali berbobot melalui akselerasi (2500 px/s²), deselerasi meluncur (1900 px/s²), pengereman balik arah (3600 px/s²), kemiringan badan saat naik-turun (±7.5°), dan semburan api proporsional |
| 29 | 2026-10-10 | Desain UI Gameplay Modern (HUD Glassmorphism & Icon Pack Shmup) di `scenes/ui/hud.tscn` | Mempercantik antarmuka in-game dengan kartu status Pip glassmorphism, avatar Pip resmi, aset ikon AI (Bintang, Rudal, Shield, Boss), Stage Journey progress bar, Splash gauge berdenyut, dan kartu hasil level/game-over yang terisolasi rapi |
| 30 | 2026-10-10 | Integrasi Layer Background Parallax Baru (Skybox Aurora & Pegunungan Es Jauh) di `assets/art/backgrounds/` | Mengganti placeholder langit dan gunung es prosedural dengan perpaduan tekstur seni 16:9 aurora kosmik dan pegunungan es transparan yang di-loop secara mulus di sistem BgLayer |
| 31 | 2026-10-10 | Integrasi Sprite Musuh Pertama: Frost Jelly (`assets/art/enemies/frost_jelly.png`) pada `enemy_drone.tscn` | Menggantikan drone kotak merah dengan sprite ubur-ubur es mekanik facing-left, lengkap dengan animasi berenang kubah melayang dan efek ledakan kristal cyan |
| 32 | 2026-10-10 | Desain & Implementasi Menu Pilihan Stage Dunia 1 (Stage 1-1 s/d 1-6) dengan Background Ilustrasi Es (`scenes/ui/stage_select.tscn`) | Menggantikan transisi langsung ke gameplay dengan menu pemilihan tahapan bebas (6 stage), memudahkan uji coba mandiri per stage tanpa harus maraton dari awal, dilengkapi kartu status glassmorphism, indikator Mini-Boss (1-3) & Major Boss (1-6), serta background seni 16:9 kepulauan laut beku |
| 33 | 2026-10-10 | Layar Pilihan Dunia (`scenes/ui/world_select.tscn`), Sistem Buka Kunci Bertahap (Lock/Unlock Stage), dan Perbaikan Respon Tombol Mainkan | Menambahkan layar World Select dengan kartu 4 Dunia (Dunia 1 terbuka, Dunia 2-4 segera hadir), mengunci stage 1-2 s/d 1-6 hingga stage sebelumnya ditamatkan, dan memperbaiki pencarian tombol BtnPlay serta mouse_filter overlay |
| 34 | 2026-10-10 | Layar Prolog Cerita 3 Panel (`scenes/ui/story_intro.tscn`) & 3 Ilustrasi Seni AI Resmi (`assets/art/story/`) | Menghadirkan pembuka cerita imersif saat memulai Stage 1-1 pertama kali (Panel 1: Kedamaian Bintang, Panel 2: Serbuan Es Glacier Gloop, Panel 3: Lepas Landas Kapal Bintang Pip), lengkap dengan transisi halus, narasi, tombol lewati [ESC], tombol tonton ulang di Menu Stage, dan persistensi SaveManager |
| 35 | 2026-10-10 | Desain Ulang Prolog Komik Menjadi Sinematik Fullscreen 1080p dengan Subtitle Plate Melayang, Typewriter Effect, Flash Petir & Screen Shake | Mengubah tampilan kotak kaku menjadi pengalaman visual novel/komik sinematik fullscreen penuh layar dengan efek Ken Burns slow zoom, plate subtitle frosted glass, efek ketik teks narasi, tombol navigasi sebelumnya/selanjutnya, serta guncangan layar dramatis saat invasi bos |






