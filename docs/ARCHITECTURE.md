# ARCHITECTURE — Starsplash

> Pelengkap GDD. Ubah dokumen ini jika struktur berubah, dan catat di DECISIONS.md.

## Pengaturan Project
- Renderer: **Compatibility**
- Viewport: 1920x1080, stretch mode `canvas_items`, aspect `keep`
- Physics: 2D, tanpa gravitasi
- Scene utama: `scenes/ui/main_menu.tscn`

## Struktur Folder
```
scenes/   player/ enemies/ bosses/ levels/ ui/ pickups/ fx/ projectiles/
scripts/  mirror scenes + autoload/ + resources/
assets/   art/ audio/ fonts/
```
Satu `.tscn` ↔ satu `.gd` dengan nama sama.

## Autoload (singleton)
| Nama | Tugas |
|---|---|
| `GameState` | nyawa, skor, kesulitan, level aktif, status pause |
| `AudioManager` | musik & SFX (bus Music / SFX) |
| `SaveManager` | high score & pengaturan (`user://`) |
| `SceneRouter` | pindah scene / transisi |

## Collision Layer
| Layer | Nama | Masks (mendeteksi) |
|---|---|---|
| 1 | player | enemy, enemy_bullet, pickup, terrain |
| 2 | player_bullet | enemy, terrain |
| 3 | enemy | player_bullet |
| 4 | enemy_bullet | player |
| 5 | pickup | player |
| 6 | terrain | player, player_bullet |

## Input Map
`move_left`, `move_right`, `move_up`, `move_down`, `fire`, `missile`, `splash`, `pause`
- Keyboard: WASD/Panah, `J`/Space = fire, `K` = missile, `L` = splash, Esc = pause
- Gamepad: stik kiri/D-pad, A = fire, X = missile, Y = splash, Start = pause
- Touch (fase Android): joystick virtual + tombol, mengirim action yang sama.

## Pola Penting
- **Level:** `LevelRunner` membaca timeline spawn (data) dan men-scroll dunia; musuh dibuat dari data, bukan ditaruh manual.
- **Musuh:** base `Enemy` (HP, skor, drop, signal `died`), varian mengganti pola gerak/tembak.
- **Peluru:** pooling bila performa menurun (Web/Android).
- **Signal utama:** `player_hit`, `player_died`, `enemy_died(score)`, `pickup_collected(type)`, `star_collected(amount)`, `splash_ready`, `splash_fired`, `level_completed`.
- **Starsplash Combo:** node `SplashMeter` (dimiliki player/HUD) menghitung bintang; `Star` adalah pickup (layer pickup) yang tertarik ke player dalam radius.
- **Data:** stat di Resource `.tres` (`EnemyData`, `WeaponLevelData`), nilai awal di `BALANCE.md`.
