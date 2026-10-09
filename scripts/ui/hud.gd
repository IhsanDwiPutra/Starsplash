extends CanvasLayer
## HUD: skor, nyawa, Splash Meter, dan kombo.

const COLOR_CHARGING: Color = Color(0.7, 0.9, 1.0)
const COLOR_READY: Color = Color(1.0, 0.9, 0.3)

@onready var _label: Label = $ScoreLabel
@onready var _bar: ProgressBar = $SplashBar
@onready var _splash_label: Label = $SplashLabel
@onready var _combo_label: Label = $ComboLabel


func _ready() -> void:
	GameState.score_changed.connect(_refresh.unbind(1))
	GameState.lives_changed.connect(_refresh.unbind(1))
	GameState.splash_changed.connect(_on_splash_changed)
	GameState.combo_changed.connect(_on_combo_changed)
	_refresh()
	_on_splash_changed(GameState.splash_charge, GameState.SPLASH_MAX)
	_on_combo_changed(GameState.combo, GameState.get_multiplier())


func _refresh() -> void:
	_label.text = "SKOR %07d     NYAWA %d" % [GameState.score, GameState.lives]


func _on_splash_changed(charge: int, max_charge: int) -> void:
	_bar.max_value = max_charge
	_bar.value = charge
	var full: bool = charge >= max_charge
	_bar.modulate = COLOR_READY if full else COLOR_CHARGING
	_splash_label.modulate = COLOR_READY if full else COLOR_CHARGING
	_splash_label.text = "SPLASH SIAP!  [L / Y]" if full else "SPLASH  %d/%d" % [charge, max_charge]


func _on_combo_changed(combo: int, multiplier: float) -> void:
	_combo_label.visible = combo >= 2
	_combo_label.text = "KOMBO x%d   (skor x%.1f)" % [combo, multiplier]
