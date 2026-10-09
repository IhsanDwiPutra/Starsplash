extends Node
## Menyimpan high score & pengaturan di user://.

const SAVE_PATH: String = "user://save.cfg"

var high_score: int = 0


func _ready() -> void:
	load_data()


func load_data() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) == OK:
		high_score = int(cfg.get_value("progress", "high_score", 0))


func save_data() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("progress", "high_score", high_score)
	cfg.save(SAVE_PATH)


func submit_score(score: int) -> void:
	if score > high_score:
		high_score = score
		save_data()
