extends CanvasLayer
## HUD Modern Starsplash: Pip Player Card, Stage Journey Progress, Boss Health Bar, Splash Gauge, & Combo Banner.

const COLOR_CYAN: Color = Color(0.35, 0.85, 1.0)
const COLOR_GOLD: Color = Color(1.0, 0.88, 0.35)
const COLOR_ALERT: Color = Color(1.0, 0.45, 0.45)
const COLOR_GREEN: Color = Color(0.4, 1.0, 0.65)

# Player Card
@onready var _player_card: Control = $PlayerCard
@onready var _score_label: Label = $PlayerCard/HBox/InfoVBox/ScoreHBox/ScoreLabel
@onready var _lives_label: Label = $PlayerCard/HBox/InfoVBox/BadgesHBox/LivesBadge/LivesHBox/LivesLabel
@onready var _weapon_label: Label = $PlayerCard/HBox/InfoVBox/BadgesHBox/WeaponBadge/WeaponLabel
@onready var _missile_label: Label = $PlayerCard/HBox/InfoVBox/BadgesHBox/MissileBadge/MissileHBox/MissileLabel
@onready var _shield_badge: Control = $PlayerCard/HBox/InfoVBox/BadgesHBox/ShieldBadge

# Stage Journey Bar
@onready var _journey_container: Control = $JourneyContainer
@onready var _level_bar: ProgressBar = $JourneyContainer/HBox/BarVBox/LevelProgress
@onready var _level_label: Label = $JourneyContainer/HBox/BarVBox/LevelNameLabel

# Boss Bar
@onready var _boss_container: Control = $BossBarContainer
@onready var _boss_name_label: Label = $BossBarContainer/HBox/VBox/BossNameLabel
@onready var _boss_bar: ProgressBar = $BossBarContainer/HBox/VBox/BossHealthBar

# Combo Banner
@onready var _combo_container: Control = $ComboContainer
@onready var _combo_label: Label = $ComboContainer/ComboLabel

# Splash Gauge
@onready var _splash_container: Control = $SplashContainer
@onready var _splash_label: Label = $SplashContainer/HBox/VBox/SplashLabel
@onready var _splash_bar: ProgressBar = $SplashContainer/HBox/VBox/SplashBar
@onready var _splash_star_icon: TextureRect = $SplashContainer/HBox/SplashStarIcon

# Center Banner
@onready var _banner_container: Control = $BannerContainer
@onready var _banner_label: Label = $BannerContainer/BannerLabel

# Clear & Game Over
@onready var _clear_panel: Control = $LevelClearPanel
@onready var _clear_title: Label = $LevelClearPanel/VBox/TitleLabel
@onready var _clear_stats: Label = $LevelClearPanel/VBox/StatsLabel
@onready var _game_over_panel: Control = $GameOverPanel
@onready var _game_over_label: Label = $GameOverPanel/GameOverLabel

var _banner_tween: Tween
var _combo_tween: Tween
var _splash_tween: Tween
var _splash_is_full: bool = false


func _ready() -> void:
	GameState.score_changed.connect(_refresh_score.unbind(1))
	GameState.lives_changed.connect(_refresh_lives.unbind(1))
	GameState.weapon_changed.connect(_on_weapon_changed)
	GameState.weapon_timer_changed.connect(_on_weapon_timer_changed)
	GameState.missiles_changed.connect(_on_missiles_changed)
	GameState.shield_changed.connect(_on_shield_changed)
	GameState.splash_changed.connect(_on_splash_changed)
	GameState.combo_changed.connect(_on_combo_changed)

	if _banner_container:
		_banner_container.visible = false
	if _clear_panel:
		_clear_panel.visible = false
	if _boss_container:
		_boss_container.visible = false
	if _combo_container:
		_combo_container.visible = false
	if _game_over_panel:
		_game_over_panel.visible = false

	_refresh_score()
	_refresh_lives()
	_update_weapon_display(GameState.weapon_level, GameState.weapon_timer)
	_on_missiles_changed(GameState.missile_ammo, GameState.MAX_MISSILES)
	_on_shield_changed(GameState.has_shield)
	_on_splash_changed(GameState.splash_charge, GameState.SPLASH_MAX)
	_on_combo_changed(GameState.combo, GameState.get_multiplier())


func _refresh_score() -> void:
	if _score_label != null:
		_score_label.text = "%07d" % GameState.score


func _refresh_lives() -> void:
	if _lives_label != null:
		_lives_label.text = "x %d" % GameState.lives


func _on_weapon_changed(level: int) -> void:
	_update_weapon_display(level, GameState.weapon_timer)


func _on_weapon_timer_changed(time_left: float, _max_time: float) -> void:
	_update_weapon_display(GameState.weapon_level, time_left)


func _update_weapon_display(level: int, time_left: float) -> void:
	if _weapon_label == null:
		return
	if level >= GameState.MAX_WEAPON_LEVEL:
		_weapon_label.text = "⚡ LV %d (%.1fs)" % [level, time_left]
		_weapon_label.modulate = COLOR_GOLD
	elif level > 1:
		_weapon_label.text = "⚡ LV %d (%.1fs)" % [level, time_left]
		_weapon_label.modulate = COLOR_GREEN if time_left > 5.0 else COLOR_ALERT
	else:
		_weapon_label.text = "LV 1"
		_weapon_label.modulate = Color(0.8, 0.9, 1.0)


func _on_missiles_changed(ammo: int, max_ammo: int) -> void:
	if _missile_label == null:
		return
	_missile_label.text = "%d/%d" % [ammo, max_ammo]
	_missile_label.modulate = COLOR_ALERT if ammo <= 0 else Color(1.0, 0.9, 0.8)


func _on_shield_changed(active: bool) -> void:
	if _shield_badge != null:
		_shield_badge.visible = active


func _on_splash_changed(charge: int, max_charge: int) -> void:
	if _splash_bar == null or _splash_label == null:
		return
	_splash_bar.max_value = max_charge
	_splash_bar.value = charge
	var full: bool = charge >= max_charge

	if full:
		_splash_label.text = "★ SPLASH SIAP! [L] ★"
		_splash_label.modulate = COLOR_GOLD
		_splash_bar.modulate = COLOR_GOLD
		if not _splash_is_full:
			_splash_is_full = true
			_pulse_splash_icon()
	else:
		_splash_is_full = false
		_splash_label.text = "SPLASH %d/%d" % [charge, max_charge]
		_splash_label.modulate = COLOR_CYAN
		_splash_bar.modulate = COLOR_CYAN


func _pulse_splash_icon() -> void:
	if _splash_star_icon == null:
		return
	if _splash_tween and _splash_tween.is_valid():
		_splash_tween.kill()
	_splash_tween = create_tween().set_loops(4)
	_splash_tween.tween_property(_splash_star_icon, "scale", Vector2(1.25, 1.25), 0.18)
	_splash_tween.tween_property(_splash_star_icon, "scale", Vector2(1.0, 1.0), 0.18)


func _on_combo_changed(combo: int, multiplier: float) -> void:
	if _combo_container == null or _combo_label == null:
		return
	var active: bool = combo >= 2
	_combo_container.visible = active
	if active:
		_combo_label.text = "🔥 KOMBO x%d (x%.1f)" % [combo, multiplier]
		if _combo_tween and _combo_tween.is_valid():
			_combo_tween.kill()
		_combo_container.scale = Vector2(1.15, 1.15)
		_combo_tween = create_tween()
		_combo_tween.tween_property(_combo_container, "scale", Vector2(1.0, 1.0), 0.15)


func show_banner(text: String, duration: float = 2.5) -> void:
	if _banner_container == null or _banner_label == null:
		return
	if _banner_tween and _banner_tween.is_valid():
		_banner_tween.kill()

	_banner_label.text = text
	_banner_container.visible = true
	_banner_container.modulate = Color(1.0, 1.0, 1.0, 0.0)
	_banner_container.scale = Vector2(0.85, 0.85)

	_banner_tween = create_tween()
	_banner_tween.set_parallel(true)
	_banner_tween.tween_property(_banner_container, "modulate:a", 1.0, 0.22)
	_banner_tween.tween_property(_banner_container, "scale", Vector2(1.0, 1.0), 0.22)
	_banner_tween.chain().tween_interval(maxf(0.5, duration - 0.5))
	_banner_tween.chain().tween_property(_banner_container, "modulate:a", 0.0, 0.3)
	_banner_tween.chain().tween_callback(func() -> void: _banner_container.visible = false)


func update_progress(ratio: float, _current_time: float, _total_time: float) -> void:
	if _level_bar != null:
		_level_bar.value = ratio * 100.0
	if _level_label != null:
		_level_label.text = "STAGE 1-%d: %s (%d%%)" % [
			GameState.current_stage,
			Level1Data.get_stage_name(GameState.current_stage).to_upper(),
			int(ratio * 100.0)
		]


func show_level_clear(stats: Dictionary) -> void:
	update_progress(1.0, 1.0, 1.0)
	if _clear_panel == null:
		return
	_clear_panel.visible = true
	_clear_panel.modulate = Color(1.0, 1.0, 1.0, 0.0)
	var tween: Tween = create_tween()
	tween.tween_property(_clear_panel, "modulate:a", 1.0, 0.4)

	var base_score: int = stats.get("base_score", 0)
	var lives: int = stats.get("lives_remaining", 0)
	var bonus: int = stats.get("life_bonus", 0)
	var final_score: int = stats.get("final_score", base_score + bonus)

	var next_hint: String = "Tekan [TEMBAK] untuk Stage Berikutnya" if GameState.current_stage < 6 else "Tekan [TEMBAK] untuk Selesai"
	_clear_stats.text = "STAGE 1-%d: %s SELESAI!\n\nSKOR PERJALANAN: %d\nBONUS NYAWA (%d x 1000): +%d\n-------------------------\nTOTAL SKOR AKHIR: %d\n\n%s\nTekan [ESC] untuk Pilih Stage" % [
		GameState.current_stage,
		Level1Data.get_stage_name(GameState.current_stage).to_upper(),
		base_score, lives, bonus, final_score,
		next_hint
	]


func show_game_over(has_checkpoint: bool, score: int) -> void:
	if _game_over_panel == null or _game_over_label == null:
		return
	if has_checkpoint:
		_game_over_label.text = "GAME OVER\nSkor: %d\n\nTekan [TEMBAK] untuk Lanjut dari Checkpoint\nTekan [ESC] untuk Pilih Stage" % score
	else:
		_game_over_label.text = "GAME OVER\nSkor: %d\n\nTekan [TEMBAK] untuk Coba Lagi\nTekan [ESC] untuk Pilih Stage" % score
	_game_over_panel.visible = true
	_game_over_panel.modulate = Color(1.0, 1.0, 1.0, 0.0)
	var t: Tween = create_tween()
	t.tween_property(_game_over_panel, "modulate:a", 1.0, 0.35)


func hide_game_over() -> void:
	if _game_over_panel != null:
		_game_over_panel.visible = false



func show_boss_bar(boss_name: String, max_hp: int) -> void:
	if _boss_container == null:
		return
	if _journey_container != null:
		_journey_container.visible = false
	_boss_name_label.text = boss_name
	_boss_bar.max_value = max_hp
	_boss_bar.value = max_hp
	_boss_container.visible = true
	_boss_container.modulate = Color(1.0, 1.0, 1.0, 0.0)
	var t: Tween = create_tween()
	t.tween_property(_boss_container, "modulate:a", 1.0, 0.35)


func update_boss_hp(current_hp: int, max_hp: int) -> void:
	if _boss_bar != null:
		_boss_bar.max_value = max_hp
		_boss_bar.value = current_hp


func hide_boss_bar() -> void:
	if _boss_container == null:
		return
	var t: Tween = create_tween()
	t.tween_property(_boss_container, "modulate:a", 0.0, 0.35)
	t.tween_callback(func() -> void:
		_boss_container.visible = false
		if _journey_container != null:
			_journey_container.visible = true
	)


func reset_boss_bar() -> void:
	if _boss_container != null:
		_boss_container.visible = false
		_boss_container.modulate = Color(1.0, 1.0, 1.0, 1.0)
	if _journey_container != null:
		_journey_container.visible = true
