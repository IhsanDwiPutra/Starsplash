extends Node2D
## Level uji prototipe: spawn musuh bergantian, game over, kembali ke menu.

const DroneScene: PackedScene = preload("res://scenes/enemies/enemy_drone.tscn")
const SineScene: PackedScene = preload("res://scenes/enemies/enemy_sine.tscn")
const ShooterScene: PackedScene = preload("res://scenes/enemies/enemy_shooter.tscn")
const CarrierScene: PackedScene = preload("res://scenes/enemies/enemy_carrier.tscn")
const BossScene: PackedScene = preload("res://scenes/bosses/boss_glacier_gloop.tscn")
const MiniBossScene: PackedScene = preload("res://scenes/bosses/boss_narwhal.tscn")
const MENU_PATH: String = "res://scenes/ui/main_menu.tscn"
const STAGE_SELECT_PATH: String = "res://scenes/ui/stage_select.tscn"
const GAME_OVER_DELAY: float = 1.0

var _is_game_over: bool = false
var _is_cleared: bool = false
var _can_leave: bool = false

var _shake_intensity: float = 0.0
var _shake_duration: float = 0.0
var _shake_timer: float = 0.0

@onready var _enemies: Node2D = $Enemies
@onready var _player: Player = $Player
@onready var _hud: CanvasLayer = $HUD
@onready var _camera: Camera2D = $Camera2D
@onready var _level_runner: LevelRunner = $LevelRunner
@onready var _pause_menu: CanvasLayer = $PauseMenu


func _ready() -> void:
	_player.game_over.connect(_on_game_over)
	GameState.screen_shaken.connect(_on_screen_shaken)
	_hud.hide_game_over()

	# Setup timeline Level 1: Laut Beku
	_level_runner.banner_requested.connect(_on_banner_requested)
	_level_runner.progress_updated.connect(_on_progress_updated)
	_level_runner.checkpoint_reached.connect(_on_checkpoint_reached)
	_level_runner.boss_spawned.connect(_on_boss_spawned)
	_level_runner.level_completed.connect(_on_level_completed)

	var enemy_scenes: Dictionary = {
		"drone": DroneScene,
		"sine": SineScene,
		"shooter": ShooterScene,
		"carrier": CarrierScene,
		"boss": BossScene,
		"mini_boss": MiniBossScene
	}
	var timeline: Array[Dictionary] = Level1Data.get_timeline(enemy_scenes)
	_level_runner.setup(_enemies, timeline)
	AudioManager.play_music("level_1")


func _process(delta: float) -> void:
	_handle_screen_shake(delta)


func _handle_screen_shake(delta: float) -> void:
	if _shake_timer > 0.0:
		_shake_timer -= delta
		var damp: float = clampf(_shake_timer / maxf(_shake_duration, 0.001), 0.0, 1.0)
		_camera.offset = Vector2(
			randf_range(-_shake_intensity, _shake_intensity) * damp,
			randf_range(-_shake_intensity, _shake_intensity) * damp
		)
		if _shake_timer <= 0.0:
			_camera.offset = Vector2.ZERO
			_shake_intensity = 0.0
	else:
		_camera.offset = Vector2.ZERO


func _on_screen_shaken(intensity: float, duration: float) -> void:
	_shake_intensity = maxf(_shake_intensity, intensity)
	_shake_duration = maxf(_shake_duration, duration)
	_shake_timer = maxf(_shake_timer, duration)


func _on_banner_requested(text: String, duration: float) -> void:
	_hud.show_banner(text, duration)


func _on_progress_updated(ratio: float, current_time: float, total_time: float) -> void:
	_hud.update_progress(ratio, current_time, total_time)


func _on_checkpoint_reached(_checkpoint_id: int, _name: String) -> void:
	GameState.trigger_shake(4.0, 0.2)
	AudioManager.play_sfx("checkpoint")


func _on_boss_spawned(boss_node: Node2D, boss_name: String) -> void:
	if boss_node != null:
		if boss_node.has_signal("health_changed"):
			boss_node.connect("health_changed", _hud.update_boss_hp)
		if boss_node.has_signal("defeated"):
			boss_node.connect("defeated", _hud.hide_boss_bar)
		var max_hp: int = boss_node.get("MAX_HP") if "MAX_HP" in boss_node else 80
		_hud.show_boss_bar(boss_name, max_hp)


func _on_level_completed(stats: Dictionary) -> void:
	_is_cleared = true
	SaveManager.submit_score(stats["final_score"])
	SaveManager.unlock_next_stage(GameState.current_world, GameState.current_stage)
	_hud.show_level_clear(stats)
	GameState.trigger_shake(8.0, 0.3)
	AudioManager.play_sfx("level_clear")
	await get_tree().create_timer(GAME_OVER_DELAY).timeout
	_can_leave = true


func _on_game_over() -> void:
	_is_game_over = true
	_hud.reset_boss_bar()
	SaveManager.submit_score(GameState.score)
	_hud.show_game_over(_level_runner.last_checkpoint_id > 0, GameState.score)
	await get_tree().create_timer(GAME_OVER_DELAY).timeout
	_can_leave = true


func _unhandled_input(event: InputEvent) -> void:
	# Jika pause ditekan saat bermain aktif (bukan game over dan bukan level tamat)
	if event.is_action_pressed("pause") and not _is_game_over and not _is_cleared:
		if _pause_menu != null:
			_pause_menu.toggle_pause()
			get_viewport().set_input_as_handled()
		return

	if not _can_leave:
		return

	if event.is_action_pressed("pause"):
		SceneRouter.go_to(STAGE_SELECT_PATH)
		return

	if event.is_action_pressed("fire"):
		if _is_cleared:
			# Jika stage selesai: lanjut ke stage berikutnya atau kembali ke stage select jika sudah 1-6
			if GameState.current_stage < 6:
				GameState.start_stage(GameState.current_world, GameState.current_stage + 1)
				SceneRouter.go_to("res://scenes/levels/test_level.tscn")
			else:
				SceneRouter.go_to(STAGE_SELECT_PATH)
		elif _is_game_over:
			if _level_runner.last_checkpoint_id > 0:
				_restart_from_checkpoint()
			else:
				# Ulang dari awal stage ini
				GameState.start_stage(GameState.current_world, GameState.current_stage)
				SceneRouter.go_to("res://scenes/levels/test_level.tscn")


func _restart_from_checkpoint() -> void:
	_is_game_over = false
	_can_leave = false
	_hud.hide_game_over()
	_hud.reset_boss_bar()

	GameState.lives = GameState.START_LIVES[GameState.difficulty]
	GameState.lives_changed.emit(GameState.lives)
	
	# Selalu berikan amunisi rudal darurat saat respawn
	GameState.missile_ammo = GameState.START_MISSILES
	GameState.missiles_changed.emit(GameState.missile_ammo, GameState.MAX_MISSILES)

	# Jika respawn di Checkpoint Boss (id 2): langsung persenjatai Pip dengan Senjata Lv 2!
	if _level_runner.last_checkpoint_id >= 2:
		GameState.weapon_level = 2
		GameState.weapon_timer = GameState.WEAPON_DURATION
		GameState.weapon_changed.emit(2)
		GameState.weapon_timer_changed.emit(GameState.weapon_timer, GameState.WEAPON_DURATION)
	else:
		GameState.weapon_level = 1
		GameState.weapon_timer = 0.0
		GameState.weapon_changed.emit(1)
		GameState.weapon_timer_changed.emit(0.0, GameState.WEAPON_DURATION)

	_hud.hide_game_over()
	_player.respawn_at(Vector2(200, 540))
	_level_runner.restart_from_checkpoint()
