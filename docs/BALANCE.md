# BALANCE — Starsplash

> **Nilai awal (tebakan terukur)**, akan dituning lewat playtest. Hanya user yang menyetujui perubahan besar. Satuan: piksel pada 1920x1080, detik.

## Pemain
| Parameter | Nilai |
|---|---|
| Kecepatan gerak | 600 px/s |
| Nyawa awal | Easy 5 / Normal 3 / Hard 2 |
| Invulnerable setelah respawn | 2.0 s |
| Hitbox | lebih kecil dari sprite (~60%) |

## Senjata Utama (level 1–5)
| Level | Fire rate (tembakan/s) | Pola | Damage/peluru |
|---|---|---|---|
| 1 | 6 | 1 lurus | 1 |
| 2 | 7 | 2 paralel | 1 |
| 3 | 8 | 3 (tengah + 2 miring kecil) | 1 |
| 4 | 9 | 3 + damage naik | 2 |
| 5 | 10 | 5 spread | 2 |

Kecepatan peluru: 1400 px/s.
Durasi Senjata Super (Level 2–5): 16 detik per pickup [P]. Jika timer habis, kembali ke Level 1. Kena hit tanpa shield → turun 1 level (minimum 1).

## Rudal & Shield
| Item | Nilai |
|---|---|
| Rudal: damage | 10 (area kecil) |
| Rudal: amunisi awal / maks | 3 / 9 |
| Rudal: cooldown | 0.6 s |
| Shield | menyerap 1 hit, lalu 1.0 s invulnerable |

## Musuh (nilai awal)
| Musuh | HP | Kecepatan | Skor | Perilaku |
|---|---|---|---|---|
| Drone (lurus) | 1 | 300 | 100 | terbang lurus ke kiri |
| Penembak diam | 3 | 200 | 200 | berhenti, tembak ke pemain tiap 2 s |
| Sinus | 2 | 280 | 150 | gelombang sinus vertikal |
| Carrier (pembawa item) | 2 | 240 | 150 | terbang melintas emas, jaminan drop [P]/[S] |
| Pengejar | 3 | 350 | 250 | mengarah ke pemain, tikungan terbatas |
| Penyerang vertikal | 2 | 320 | 150 | masuk dari atas/bawah |
| Turret terrain | 4 | 0 | 200 | menempel terrain, tembak berkala |

Kecepatan peluru musuh: Easy 350 / Normal 450 / Hard 550.
HP musuh: Easy ×0.8 / Normal ×1.0 / Hard ×1.3.

## Drop Power-up
- Musuh biasa (Drone, Sine): 100% Bintang, drop Rudal [M] 6%.
- Musuh Penembak (Shooter): 100% Bintang (3), 30% drop Shield [S] atau Rudal [M].
- Carrier Drone: 100% drop Power-up Senjata [P] atau Shield [S].

## Boss (Dunia 1)
- HP total: 150, 3 fase (100% / 66% / 33%), tiap fase pola tembak baru.
- Skor: 5000.

## Level
- Durasi target: Level 1 ≈ 3 menit, Level 2 ≈ 4 menit, lalu boss.
- Checkpoint: kira-kira di 50% level.

## Skor
- Bonus akhir level: nyawa tersisa × 1000.
- Combo (opsional): +10% per kill beruntun <1.5 s, maks ×2.

## Starsplash Combo (nilai awal)
| Parameter | Nilai |
|---|---|
| Bintang dari musuh biasa | 1 (elite 3, boss 15) |
| Radius tarik bintang ke kapal | 220 px |
| Bintang untuk Splash Meter penuh | 30 |
| Splash | menghapus semua peluru musuh di layar, damage 8 ke musuh |
| Combo | kill <1.5 s berturut: +1 bintang tiap 3 kombo, skor maks x2 |
| Bintang hilang | di tepi kiri layar |
| Meter saat mati | direset ke 0 |
