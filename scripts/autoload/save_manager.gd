extends Node
## Menyimpan high score & pengaturan di user://.

const SAVE_PATH: String = "user://save.cfg"

var high_score: int = 0
var music_volume: float = 0.8
var sfx_volume: float = 1.0
var selected_difficulty: int = 1 # 0: EASY, 1: NORMAL, 2: HARD
var unlocked_world: int = 1
var unlocked_stage: int = 1
var has_seen_intro: bool = false
var stage_stars: Dictionary = {} # format: {"1_1": 3, "1_2": 2, ...}


func _ready() -> void:
	load_data()


func load_data() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) == OK:
		high_score = int(cfg.get_value("progress", "high_score", 0))
		unlocked_world = int(cfg.get_value("progress", "unlocked_world", 1))
		unlocked_stage = int(cfg.get_value("progress", "unlocked_stage", 1))
		has_seen_intro = bool(cfg.get_value("progress", "has_seen_intro", false))
		music_volume = float(cfg.get_value("settings", "music_volume", 0.8))
		sfx_volume = float(cfg.get_value("settings", "sfx_volume", 1.0))
		selected_difficulty = int(cfg.get_value("settings", "difficulty", 1))

		stage_stars.clear()
		if cfg.has_section("stars"):
			for key in cfg.get_section_keys("stars"):
				stage_stars[key] = int(cfg.get_value("stars", key, 0))
	
	AudioManager.set_music_volume(music_volume)
	AudioManager.set_sfx_volume(sfx_volume)
	GameState.difficulty = selected_difficulty as GameState.Difficulty


func save_data() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("progress", "high_score", high_score)
	cfg.set_value("progress", "unlocked_world", unlocked_world)
	cfg.set_value("progress", "unlocked_stage", unlocked_stage)
	cfg.set_value("progress", "has_seen_intro", has_seen_intro)
	cfg.set_value("settings", "music_volume", music_volume)
	cfg.set_value("settings", "sfx_volume", sfx_volume)
	cfg.set_value("settings", "difficulty", selected_difficulty)

	for key in stage_stars:
		cfg.set_value("stars", key, stage_stars[key])

	cfg.save(SAVE_PATH)


func mark_intro_seen() -> void:
	has_seen_intro = true
	save_data()


func reset_intro() -> void:
	has_seen_intro = false
	save_data()


func reset_progress() -> void:
	unlocked_world = 1
	unlocked_stage = 1
	has_seen_intro = false
	high_score = 0
	stage_stars.clear()
	save_data()


func is_stage_unlocked(world_id: int, stage_id: int) -> bool:
	if world_id < unlocked_world:
		return true
	if world_id == unlocked_world:
		return stage_id <= unlocked_stage
	return false


func unlock_next_stage(world_id: int, completed_stage: int) -> void:
	if world_id == unlocked_world and completed_stage >= unlocked_stage:
		unlocked_stage = mini(completed_stage + 1, 6)
		save_data()


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


func get_stage_stars(world_id: int, stage_id: int) -> int:
	var key: String = "%d_%d" % [world_id, stage_id]
	return stage_stars.get(key, 0)


func save_stage_stars(world_id: int, stage_id: int, stars: int) -> bool:
	var key: String = "%d_%d" % [world_id, stage_id]
	var current: int = stage_stars.get(key, 0)
	if stars > current:
		stage_stars[key] = clampi(stars, 0, 3)
		save_data()
		return true
	return false


func get_total_stars(world_id: int) -> int:
	var total: int = 0
	for stage_num in range(1, 7):
		total += get_stage_stars(world_id, stage_num)
	return total
