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

