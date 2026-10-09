extends CanvasLayer
## HUD: skor, nyawa, status senjata & durasi timer, rudal, shield, Splash Meter, dan kombo.

const COLOR_CHARGING: Color = Color(0.7, 0.9, 1.0)
const COLOR_READY: Color = Color(1.0, 0.9, 0.3)
const COLOR_SHIELD: Color = Color(0.3, 0.9, 1.0)

@onready var _label: Label = $ScoreLabel
@onready var _weapon_label: Label = $WeaponLabel
@onready var _missile_label: Label = $MissileLabel
@onready var _shield_label: Label = $ShieldLabel
@onready var _bar: ProgressBar = $SplashBar
@onready var _splash_label: Label = $SplashLabel
@onready var _combo_label: Label = $ComboLabel


func _ready() -> void:
	GameState.score_changed.connect(_refresh.unbind(1))
	GameState.lives_changed.connect(_refresh.unbind(1))
	GameState.weapon_changed.connect(_on_weapon_changed)
	GameState.weapon_timer_changed.connect(_on_weapon_timer_changed)
	GameState.missiles_changed.connect(_on_missiles_changed)
	GameState.shield_changed.connect(_on_shield_changed)
	GameState.splash_changed.connect(_on_splash_changed)
	GameState.combo_changed.connect(_on_combo_changed)

	_refresh()
	_update_weapon_display(GameState.weapon_level, GameState.weapon_timer)
	_on_missiles_changed(GameState.missile_ammo, GameState.MAX_MISSILES)
	_on_shield_changed(GameState.has_shield)
	_on_splash_changed(GameState.splash_charge, GameState.SPLASH_MAX)
	_on_combo_changed(GameState.combo, GameState.get_multiplier())


func _refresh() -> void:
	_label.text = "SKOR %07d     NYAWA %d" % [GameState.score, GameState.lives]


func _on_weapon_changed(level: int) -> void:
	_update_weapon_display(level, GameState.weapon_timer)


func _on_weapon_timer_changed(time_left: float, _max_time: float) -> void:
	_update_weapon_display(GameState.weapon_level, time_left)


func _update_weapon_display(level: int, time_left: float) -> void:
	if level >= GameState.MAX_WEAPON_LEVEL:
		_weapon_label.text = "SENJATA: LV %d [MAX] (%.1fs)" % [level, time_left]
		_weapon_label.modulate = Color(1.0, 0.85, 0.2)
	elif level > 1:
		_weapon_label.text = "SENJATA: LV %d (%.1fs)" % [level, time_left]
		_weapon_label.modulate = Color(0.4, 1.0, 0.6) if time_left > 5.0 else Color(1.0, 0.45, 0.4)
	else:
		_weapon_label.text = "SENJATA: LV 1"
		_weapon_label.modulate = Color(1.0, 1.0, 1.0)


func _on_missiles_changed(ammo: int, max_ammo: int) -> void:
	_missile_label.text = "RUDAL: %d/%d [K / Klik Kanan]" % [ammo, max_ammo]
	_missile_label.modulate = Color(1.0, 0.5, 0.5) if ammo <= 0 else Color(1.0, 0.9, 0.8)


func _on_shield_changed(active: bool) -> void:
	_shield_label.visible = active
	_shield_label.text = "SHIELD: AKTIF"
	_shield_label.modulate = COLOR_SHIELD


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
