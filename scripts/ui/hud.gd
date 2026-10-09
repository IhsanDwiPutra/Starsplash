extends CanvasLayer
## HUD dasar: skor dan nyawa.

@onready var _label: Label = $ScoreLabel


func _ready() -> void:
	GameState.score_changed.connect(_refresh.unbind(1))
	GameState.lives_changed.connect(_refresh.unbind(1))
	_refresh()


func _refresh() -> void:
	_label.text = "SKOR %07d     NYAWA %d" % [GameState.score, GameState.lives]
