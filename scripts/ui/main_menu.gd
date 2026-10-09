extends Control
## Menu utama sementara: tekan tembak untuk mulai.

const LEVEL_PATH: String = "res://scenes/levels/test_level.tscn"

@onready var _high_score: Label = $HighScore


func _ready() -> void:
	_high_score.text = "REKOR: %d" % SaveManager.high_score


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("fire"):
		GameState.new_game()
		SceneRouter.go_to(LEVEL_PATH)
