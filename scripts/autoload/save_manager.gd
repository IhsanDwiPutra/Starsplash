extends Node
## Menyimpan high score & pengaturan di user://.

const SAVE_PATH: String = "user://save.cfg"

var high_score: int = 0
var music_volume: float = 0.8
var sfx_volume: float = 1.0
var selected_difficulty: int = 1 # 0: EASY, 1: NORMAL, 2: HARD


func _ready() -> void:
	load_data()


func load_data() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) == OK:
		high_score = int(cfg.get_value("progress", "high_score", 0))
		music_volume = float(cfg.get_value("settings", "music_volume", 0.8))
		sfx_volume = float(cfg.get_value("settings", "sfx_volume", 1.0))
		selected_difficulty = int(cfg.get_value("settings", "difficulty", 1))
	
	AudioManager.set_music_volume(music_volume)
	AudioManager.set_sfx_volume(sfx_volume)
	GameState.difficulty = selected_difficulty as GameState.Difficulty


func save_data() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("progress", "high_score", high_score)
	cfg.set_value("settings", "music_volume", music_volume)
	cfg.set_value("settings", "sfx_volume", sfx_volume)
	cfg.set_value("settings", "difficulty", selected_difficulty)
	cfg.save(SAVE_PATH)


func save_settings(music_val: float, sfx_val: float, diff: int = -1) -> void:
	music_volume = clampf(music_val, 0.0, 1.0)
	sfx_volume = clampf(sfx_val, 0.0, 1.0)
	if diff >= 0:
		selected_difficulty = diff
		GameState.difficulty = selected_difficulty as GameState.Difficulty
	AudioManager.set_music_volume(music_volume)
	AudioManager.set_sfx_volume(sfx_volume)
	save_data()


func submit_score(score: int) -> void:
	if score > high_score:
		high_score = score
		save_data()
