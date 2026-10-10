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

@onready var _level_bar: ProgressBar = $LevelProgress
@onready var _level_label: Label = $LevelProgress/LevelNameLabel
@onready var _banner_label: Label = $BannerLabel
@onready var _clear_panel: Control = $LevelClearPanel
@onready var _clear_title: Label = $LevelClearPanel/TitleLabel
@onready var _clear_stats: Label = $LevelClearPanel/StatsLabel

@onready var _boss_container: Control = $BossBarContainer
@onready var _boss_name_label: Label = $BossBarContainer/BossNameLabel
@onready var _boss_bar: ProgressBar = $BossBarContainer/BossHealthBar

var _banner_tween: Tween


func _ready() -> void:
	GameState.score_changed.connect(_refresh.unbind(1))
	GameState.lives_changed.connect(_refresh.unbind(1))
	GameState.weapon_changed.connect(_on_weapon_changed)
	GameState.weapon_timer_changed.connect(_on_weapon_timer_changed)
	GameState.missiles_changed.connect(_on_missiles_changed)
	GameState.shield_changed.connect(_on_shield_changed)
	GameState.splash_changed.connect(_on_splash_changed)
	GameState.combo_changed.connect(_on_combo_changed)

	if _banner_label:
		_banner_label.visible = false
	if _clear_panel:
		_clear_panel.visible = false
	if _boss_container:
		_boss_container.visible = false

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


func show_banner(text: String, duration: float = 2.5) -> void:
	if _banner_label == null:
		return
	if _banner_tween and _banner_tween.is_valid():
		_banner_tween.kill()
	
	_banner_label.text = text
	_banner_label.visible = true
	_banner_label.modulate = Color(1.0, 1.0, 1.0, 0.0)
	_banner_label.scale = Vector2(0.85, 0.85)
	_banner_label.pivot_offset = _banner_label.size * 0.5
	
	_banner_tween = create_tween()
	_banner_tween.set_parallel(true)
	_banner_tween.tween_property(_banner_label, "modulate:a", 1.0, 0.25)
	_banner_tween.tween_property(_banner_label, "scale", Vector2(1.0, 1.0), 0.25)
	_banner_tween.chain().tween_interval(maxf(0.5, duration - 0.5))
	_banner_tween.chain().tween_property(_banner_label, "modulate:a", 0.0, 0.35)
	_banner_tween.chain().tween_callback(func() -> void: _banner_label.visible = false)


func update_progress(ratio: float, current_time: float, total_time: float) -> void:
	if _level_bar != null:
		_level_bar.value = ratio * 100.0
	if _level_label != null:
		_level_label.text = "LAUT BEKU: %d%%" % int(ratio * 100.0)


func show_level_clear(stats: Dictionary) -> void:
	update_progress(1.0, 1.0, 1.0)
	if _clear_panel == null:
		return
	_clear_panel.visible = true
	_clear_panel.modulate = Color(1.0, 1.0, 1.0, 0.0)
	var tween: Tween = create_tween()
	tween.tween_property(_clear_panel, "modulate:a", 1.0, 0.5)

	var base_score: int = stats.get("base_score", 0)
	var lives: int = stats.get("lives_remaining", 0)
	var bonus: int = stats.get("life_bonus", 0)
	var final_score: int = stats.get("final_score", base_score + bonus)

	_clear_stats.text = "SKOR PERJALANAN: %d\nBONUS NYAWA (%d x 1000): +%d\n-------------------------\nTOTAL SKOR AKHIR: %d\n\nTekan [TEMBAK] untuk Main Lagi\nTekan [ESC] untuk Menu Utama" % [
		base_score, lives, bonus, final_score
	]


func show_boss_bar(boss_name: String, max_hp: int) -> void:
	if _boss_container == null:
		return
	if _level_bar != null:
		_level_bar.visible = false
	_boss_name_label.text = boss_name
	_boss_bar.max_value = max_hp
	_boss_bar.value = max_hp
	_boss_container.visible = true
	_boss_container.modulate = Color(1.0, 1.0, 1.0, 0.0)
	var t: Tween = create_tween()
	t.tween_property(_boss_container, "modulate:a", 1.0, 0.4)


func update_boss_hp(current_hp: int, max_hp: int) -> void:
	if _boss_bar != null:
		_boss_bar.max_value = max_hp
		_boss_bar.value = current_hp


func hide_boss_bar() -> void:
	if _boss_container == null:
		return
	var t: Tween = create_tween()
	t.tween_property(_boss_container, "modulate:a", 0.0, 0.4)
	t.tween_callback(func() -> void:
		_boss_container.visible = false
		if _level_bar != null:
			_level_bar.visible = true
	)


func reset_boss_bar() -> void:
	if _boss_container != null:
		_boss_container.visible = false
		_boss_container.modulate = Color(1.0, 1.0, 1.0, 1.0)
	if _level_bar != null:
		_level_bar.visible = true


