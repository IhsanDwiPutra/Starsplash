extends Node
## Status global: nyawa, skor, kesulitan, Splash Meter, dan kombo.
## Angka awal ada di docs/BALANCE.md.

enum Difficulty { EASY, NORMAL, HARD }

signal score_changed(new_score: int)
signal lives_changed(new_lives: int)
signal splash_changed(charge: int, max_charge: int)
signal splash_ready
signal splash_fired
signal combo_changed(combo: int, multiplier: float)

const START_LIVES: Dictionary = {
	Difficulty.EASY: 5,
	Difficulty.NORMAL: 3,
	Difficulty.HARD: 2,
}
const ENEMY_BULLET_SPEED: Dictionary = {
	Difficulty.EASY: 350.0,
	Difficulty.NORMAL: 450.0,
	Difficulty.HARD: 550.0,
}
const SPLASH_MAX: int = 30
const COMBO_WINDOW: float = 1.5
const COMBO_MAX_MULTIPLIER: float = 2.0
const COMBO_STEP: float = 0.1

var difficulty: Difficulty = Difficulty.NORMAL
var score: int = 0
var lives: int = 3
var splash_charge: int = 0
var combo: int = 0

var _last_kill_time: float = -100.0


func _process(_delta: float) -> void:
	if combo > 0 and _now() - _last_kill_time > COMBO_WINDOW:
		combo = 0
		combo_changed.emit(combo, get_multiplier())


func new_game(chosen: Difficulty = Difficulty.NORMAL) -> void:
	difficulty = chosen
	score = 0
	lives = START_LIVES[chosen]
	_reset_splash_and_combo()
	score_changed.emit(score)
	lives_changed.emit(lives)


func add_score(amount: int) -> void:
	score += amount
	score_changed.emit(score)


func lose_life() -> void:
	lives = maxi(lives - 1, 0)
	_reset_splash_and_combo()
	lives_changed.emit(lives)


func get_enemy_bullet_speed() -> float:
	return ENEMY_BULLET_SPEED[difficulty]


## Dipanggil saat musuh hancur. Memperbarui kombo.
func register_kill() -> void:
	var now: float = _now()
	if combo > 0 and now - _last_kill_time <= COMBO_WINDOW:
		combo += 1
	else:
		combo = 1
	_last_kill_time = now
	combo_changed.emit(combo, get_multiplier())


func get_multiplier() -> float:
	if combo <= 0:
		return 1.0
	return minf(1.0 + COMBO_STEP * float(combo - 1), COMBO_MAX_MULTIPLIER)


## Bonus 1 bintang setiap kelipatan 3 kombo.
func combo_bonus_stars() -> int:
	return 1 if combo >= 3 and combo % 3 == 0 else 0


func add_stars(amount: int) -> void:
	var was_full: bool = splash_charge >= SPLASH_MAX
	splash_charge = mini(splash_charge + amount, SPLASH_MAX)
	splash_changed.emit(splash_charge, SPLASH_MAX)
	if not was_full and splash_charge >= SPLASH_MAX:
		splash_ready.emit()


## Mengembalikan true jika meter penuh dan Splash berhasil dilepas.
func try_splash() -> bool:
	if splash_charge < SPLASH_MAX:
		return false
	splash_charge = 0
	splash_changed.emit(splash_charge, SPLASH_MAX)
	splash_fired.emit()
	return true


func _reset_splash_and_combo() -> void:
	splash_charge = 0
	combo = 0
	splash_changed.emit(splash_charge, SPLASH_MAX)
	combo_changed.emit(combo, 1.0)


func _now() -> float:
	return Time.get_ticks_msec() / 1000.0
