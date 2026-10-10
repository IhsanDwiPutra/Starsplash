# ROADMAP - Starsplash

> Penghubung antar sesi/model AI. Centang saat selesai; isi Catatan Serah-Terima di bawah.

## Fase 0 - Setup
- [x] GDD v0.2
- [x] AGENTS.md, ARCHITECTURE, ROADMAP, DECISIONS, BALANCE, CREDITS
- [x] Git init + `.gitignore` + commit pertama
- [x] Repo GitHub (private) terhubung
- [x] `project.godot` (Compatibility, 1920x1080, input map, collision layer name)
- [x] Struktur folder + autoload kosong
- [x] Cek headless tanpa error

## Fase 1 - Prototipe
- [x] Kapal pemain bergerak 8 arah (batas layar)
- [x] Tembakan dasar (keyboard, gamepad, mouse kiri)
- [x] Bintang dari musuh + Splash Meter + ledakan Splash (mekanik khas)
- [x] Musuh 1 (lurus) + HP + mati
- [x] Tabrakan pemain-musuh, nyawa
- [x] Skor + HUD dasar
- [x] Musuh 2 (sinus)
- [x] Uji main 2 menit: seru? (Dikonfirmasi user: gameplay memuaskan & seru!)

## Fase 2 - Core Loop
- [x] Parallax background (prosedural, 6 lapis Laut Beku)
- [x] Kontras visual musuh vs background
- [x] Power-up senjata (level 1-5, turun saat hit)
- [x] Rudal (K / klik kanan) + ammo + pickup
- [x] Shield (pelindung) + pickup
- [x] Efek Partikel Ledakan, Hit Spark & Camera Screen Shake (Game Feel)
- [x] LevelRunner (timeline spawn musuh terstruktur & formasi)
- [x] Respawn + checkpoint (di 50% level)
- [x] Level 1 tamat (layar kemenangan, bonus skor nyawa, alur kembali ke menu)
- [x] SFX dasar + musik (prosedural synth + slot file audio eksternal)

## Fase 3 - MVP Lengkap (PC)
- [x] Boss Dunia 1 (3 fase: Glacier Gloop)
- [ ] Level 2
- [ ] Musuh 3-6 (pengejar, penyerang vertikal, turret)
- [ ] Menu utama, pilih kesulitan, pause, hasil, game over
- [ ] High score tersimpan

## Fase 4 - Web
- [ ] Export Web, uji performa & audio

## Fase 5 - Android
- [ ] Kontrol touch (joystick virtual & tombol aksi)
- [ ] Setup SDK + export APK, uji di HP

## Fase 6 - Polish & Konten
- [ ] Visual/audio final, dunia 2-3

---
## Catatan Serah-Terima
<!-- Tambahkan entri BARU di atas. Format: tanggal | model | dikerjakan | file utama | masalah | langkah berikut -->
- 2026-10-10 | Gemini | Boss Dunia 1 (Glacier Gloop - Pengawal Laut Beku) selesai: HP 150, 3 fase serangan adaptif (Fase 1: triple spread + drone, Fase 2: 5-fan radial + dual fast shot, Fase 3: enrage spiral stream + sine swarm), transisi visual mata & core reaktif, Boss Health Bar di HUD, urutan kematian 7 ledakan berantai + 15 bintang drop & 5000 skor | scenes/bosses/*, scripts/bosses/*, scripts/levels/level_runner.gd, scripts/levels/level_1_data.gd, scripts/ui/hud.gd, scenes/levels/test_level.tscn, docs/DECISIONS.md, docs/ROADMAP.md | - | Menu utama lengkap (pilih kesulitan Easy/Normal/Hard) & Level 2
- 2026-10-10 | Gemini | Sistem AudioManager lengkap: pool pemutar SFX (12 channel), slot file audio (.ogg/.wav) siap hunting, fallback synthesizer prosedural bawaan (tembakan Pip, rudal, ledakan musuh/carrier, hit, bintang, pickup, shield break, splash bomb, checkpoint, victory jingle, ambient loop Laut Beku), integrasi gameplay penuh. Fase 2 Tuntas 100%! | scripts/autoload/audio_manager.gd, scripts/player/player.gd, scripts/enemies/enemy.gd, scripts/pickups/*, scripts/levels/test_level.gd, assets/audio/*, docs/DECISIONS.md, docs/ROADMAP.md | - | Masuk Fase 3: Pilihan kesulitan di menu utama & Boss Dunia 1 (3 fase)
- 2026-10-10 | Gemini | LevelRunner timeline spawn terstruktur (Level 1: Laut Beku ~140s), sistem formasi (LINE, V, WALL, SWARM_SINE), notifikasi banner visual, progress bar level di HUD, Checkpoint di 50% dengan respawn flow, dan layar kemenangan Level Clear | scripts/levels/level_runner.gd, scripts/levels/level_1_data.gd, scripts/levels/test_level.gd, scripts/ui/hud.gd, scenes/levels/test_level.tscn, docs/DECISIONS.md, docs/ROADMAP.md | - | SFX dasar + musik (AudioManager), persiapan transisi ke Fase 3
- 2026-10-10 | Gemini | Efek partikel ledakan poligon prosedural (flash inti, shockwave arc, pecahan berputar adaptif warna), hit spark peluru, camera screen shake responsif (dihubungkan ke Camera2D test_level, ledakan musuh berbobot, rudal, splash wave, dan damage pemain) | scenes/fx/*, scripts/fx/*, scripts/enemies/enemy.gd, scripts/projectiles/*, scripts/player/player.gd, scripts/levels/test_level.gd, docs/DECISIONS.md | - | LevelRunner (timeline spawn musuh), checkpoint & tamat Level 1, SFX dasar + musik
- 2026-10-09 | Gemini | Penyeimbang senjata: durasi senjata super (16s timer revert ke Lv 1), Carrier Drone emas khusus (100% drop [P]/[S]), aturan drop ketat (musuh biasa hanya drop Bintang & rudal), HUD timer senjata | scripts/autoload/game_state.gd, scripts/enemies/*, scripts/ui/hud.gd, scenes/enemies/enemy_carrier.tscn, docs/BALANCE.md, docs/DECISIONS.md | - | LevelRunner (timeline spawn terstruktur), ledakan partikel / SFX, checkpoint & tamat Level 1
- 2026-10-09 | Gemini | Fase 2: Power-up senjata (Lv 1-5, spread shot & turun saat hit), Rudal area damage (K / Klik Kanan), Shield aura pelindung, item pickup (P, M, S drop dari musuh), kontras outline musuh, update HUD | scripts/player/player.gd, scripts/projectiles/*, scripts/pickups/pickup.*, scenes/enemies/*, scripts/ui/hud.gd | - | LevelRunner (timeline spawn terstruktur), ledakan partikel / SFX, checkpoint & tamat Level 1
- 2026-10-09 | Gemini | Perbaikan encoding ROADMAP.md & ARCHITECTURE.md, update status Fase 1 lulus uji main | docs/ROADMAP.md, docs/ARCHITECTURE.md | - | Eksekusi Senjata 1-5, Rudal, Shield, Pickups & Kontras musuh
- 2026-10-09 | Claude | Parallax background prosedural Laut Beku (langit gradasi, bulan, bintang, awan, 2 lapis gunung es, riak, bongkahan es) tanpa aset gambar | scripts/fx/bg_layer.gd, scripts/fx/parallax_background.gd, scenes/levels/test_level.tscn | Masih placeholder; ganti sprite saat fase poles | Power-up senjata bertingkat, rudal, shield (atau tuning Splash dulu)
- 2026-10-09 | Claude | Starsplash Combo: bintang drop, Splash Meter (30), ledakan Splash (hapus peluru + damage 8), kombo (multiplier + bonus bintang), musuh penembak (HOLD), peluru musuh, HUD meter/kombo; klik kiri mouse = fire | scripts/autoload/game_state.gd, scripts/pickups/star.gd, scripts/enemies/enemy.gd, scripts/player/player.gd, scripts/ui/hud.gd | Belum playtest manusia; belum ada pilihan kesulitan di menu; HP musuh belum diskala | Playtest & tuning Splash, lalu parallax, power-up senjata, rudal, shield
- 2026-10-09 | Claude | Fase 1 kode selesai (belum playtest manusia): player, peluru, 2 musuh, tabrakan+nyawa, skor/HUD, test_level, menu mulai, game over | scripts/player, enemies, projectiles, levels, ui; scenes/* | Splash Meter belum dibuat; HP musuh belum diskala kesulitan; tunggu playtest user | Playtest 2 menit, tuning, lalu mekanik Starsplash Combo
- 2026-10-09 | Claude | Fase 0 selesai: project.godot, input map (termasuk splash), collision layer, 4 autoload, main_menu placeholder, cek headless OK | project.godot, scripts/autoload/*, scenes/ui/main_menu.tscn | Belum ada gameplay | Fase 1: kapal pemain 8 arah + tembakan dasar
- 2026-10-09 | Claude | Dokumen dasar dibuat | docs/*, AGENTS.md | Git belum di-init | Setup Git lalu Fase 0
