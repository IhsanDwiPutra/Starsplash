# ROADMAP Ã¢â‚¬â€ Starsplash

> Penghubung antar sesi/model AI. Centang saat selesai; isi Catatan Serah-Terima di bawah.

## Fase 0 Ã¢â‚¬â€ Setup
- [x] GDD v0.2
- [x] AGENTS.md, ARCHITECTURE, ROADMAP, DECISIONS, BALANCE, CREDITS
- [x] Git init + `.gitignore` + commit pertama
- [x] Repo GitHub (private) terhubung
- [x] `project.godot` (Compatibility, 1920x1080, input map, collision layer name)
- [x] Struktur folder + autoload kosong
- [x] Cek headless tanpa error

## Fase 1 Ã¢â‚¬â€ Prototipe
- [x] Kapal pemain bergerak 8 arah (batas layar)
- [x] Tembakan dasar
- [ ] Bintang dari musuh + Splash Meter + ledakan Splash (mekanik khas)
- [x] Musuh 1 (lurus) + HP + mati
- [x] Tabrakan pemain-musuh, nyawa
- [x] Skor + HUD dasar
- [x] Musuh 2 (sinus)
- [ ] Uji main 2 menit: seru?

## Fase 2 Ã¢â‚¬â€ Core Loop
- [ ] Parallax background (3Ã¢â‚¬â€œ4 lapis)
- [ ] LevelRunner (timeline spawn)
- [ ] Power-up senjata (level 1Ã¢â‚¬â€œ5, turun saat hit)
- [ ] Rudal + pickup
- [ ] Shield
- [ ] Respawn + checkpoint
- [ ] Ledakan/partikel + SFX dasar + musik
- [ ] Level 1 tamat

## Fase 3 Ã¢â‚¬â€ MVP Lengkap (PC)
- [ ] Level 2
- [ ] Musuh 3Ã¢â‚¬â€œ6
- [ ] Boss (2Ã¢â‚¬â€œ3 fase)
- [ ] Menu utama, pilih kesulitan, pause, hasil, game over
- [ ] High score tersimpan

## Fase 4 Ã¢â‚¬â€ Web
- [ ] Export Web, uji performa & audio

## Fase 5 Ã¢â‚¬â€ Android
- [ ] Kontrol touch
- [ ] Setup SDK + export APK, uji di HP

## Fase 6 Ã¢â‚¬â€ Polish & Konten
- [ ] Visual/audio final, dunia 2Ã¢â‚¬â€œ3

---
## Catatan Serah-Terima
<!-- Tambahkan entri BARU di atas. Format: tanggal | model | dikerjakan | file utama | masalah | langkah berikut -->
- 2026-10-09 | Claude | Fase 1 kode selesai (belum playtest manusia): player, peluru, 2 musuh, tabrakan+nyawa, skor/HUD, test_level, menu mulai, game over | scripts/player, enemies, projectiles, levels, ui; scenes/* | Splash Meter belum dibuat; HP musuh belum diskala kesulitan; tunggu playtest user | Playtest 2 menit, tuning, lalu mekanik Starsplash Combo
- 2026-10-09 | Claude | Fase 0 selesai: project.godot, input map (termasuk splash), collision layer, 4 autoload, main_menu placeholder, cek headless OK | project.godot, scripts/autoload/*, scenes/ui/main_menu.tscn | Belum ada gameplay | Fase 1: kapal pemain 8 arah + tembakan dasar
- 2026-10-09 | Claude | Dokumen dasar dibuat | docs/*, AGENTS.md | Git belum di-init | Setup Git lalu Fase 0

