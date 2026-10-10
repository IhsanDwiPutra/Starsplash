# Audio Assets Guide — Starsplash

AudioManager mendukung pemuatan file audio kustom secara otomatis dari folder ini.
Format yang didukung oleh Godot: `.ogg` (sangat disarankan untuk musik & sfx panjang), `.wav` (sangat bagus untuk sfx pendek), atau `.mp3`.

Jika file di bawah ini diletakkan di foldernya, `AudioManager` akan **otomatis memprioritaskan file tersebut**.
Jika slot file belum diisi / belum ada, game akan **otomatis menggunakan audio sintetis prosedural bawaan**.

---

## Slot Efek Suara (`assets/audio/sfx/`)

| Nama Slot | Nama File yang Dicari | Deskripsi Suara |
|---|---|---|
| `shoot` | `laser.ogg` / `laser.wav` | Tembakan peluru utama Pip |
| `missile` | `missile.ogg` / `missile.wav` | Peluncuran rudal sekunder |
| `enemy_shoot` | `enemy_laser.ogg` / `enemy_laser.wav` | Peluru musuh shooter |
| `hit` | `hit.ogg` / `hit.wav` | Peluru mengenai badan musuh / Pip |
| `explosion` | `explosion.ogg` / `explosion.wav` | Ledakan musuh biasa |
| `carrier_explosion`| `big_explosion.ogg` / `big_explosion.wav`| Ledakan besar Carrier Drone / rudal |
| `star` | `star.ogg` / `star.wav` | Suara mengambil bintang |
| `pickup` | `pickup.ogg` / `pickup.wav` | Suara mengambil item [P], [M], [S] |
| `shield_break` | `shield_break.ogg` / `shield_break.wav` | Shield menyerap tembakan & pecah |
| `splash` | `splash.ogg` / `splash.wav` | Pelepasan bom Starsplash |
| `checkpoint` | `checkpoint.ogg` / `checkpoint.wav` | Peringatan mencapai Checkpoint |
| `level_clear` | `level_clear.ogg` / `level_clear.wav` | Jingle kemenangan tamat level |
| `game_over` | `game_over.ogg` / `game_over.wav` | Suara kapal hancur / Game Over |

---

## Slot Musik Latar (`assets/audio/music/`)

| Nama Slot | Nama File yang Dicari | Deskripsi Musik |
|---|---|---|
| `level_1` | `bgm_level_1.ogg` / `bgm_level_1.wav` | BGM Dunia 1: Laut Beku (Loop) |
| `menu` | `bgm_menu.ogg` / `bgm_menu.wav` | BGM Menu Utama (Loop) |
