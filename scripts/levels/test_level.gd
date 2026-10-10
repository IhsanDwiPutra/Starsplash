extends Node2D
## Level uji prototipe: spawn musuh bergantian, game over, kembali ke menu.

const DroneScene: PackedScene = preload("res://scenes/enemies/enemy_drone.tscn")
const SineScene: PackedScene = preload("res://scenes/enemies/enemy_sine.tscn")
const ShooterScene: PackedScene = preload("res://scenes/enemies/enemy_shooter.tscn")
const CarrierScene: PackedScene = preload("res://scenes/enemies/enemy_carrier.tscn")
const MENU_PATH: String = "res://scenes/ui/main_menu.tscn"
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
@onready var _game_over_label: Label = $HUD/GameOverLabel
@onready var _camera: Camera2D = $Camera2D
@onready var _level_runner: LevelRunner = $LevelRunner


func _ready() -> void:
	_player.game_over.connect(_on_game_over)
	GameState.screen_shaken.connect(_on_screen_shaken)
	_game_over_label.visible = false

	# Setup timeline Level 1: Laut Beku
	_level_runner.banner_requested.connect(_on_banner_requested)
	_level_runner.progress_updated.connect(_on_progress_updated)
	_level_runner.checkpoint_reached.connect(_on_checkpoint_reached)
	_level_runner.level_completed.connect(_on_level_completed)

	var enemy_scenes: Dictionary = {
		"drone": DroneScene,
		"sine": SineScene,
		"shooter": ShooterScene,
		"carrier": CarrierScene
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


func _on_level_completed(stats: Dictionary) -> void:
	_is_cleared = true
	SaveManager.submit_score(stats["final_score"])
	_hud.show_level_clear(stats)
	GameState.trigger_shake(8.0, 0.3)
	AudioManager.play_sfx("level_clear")
	await get_tree().create_timer(GAME_OVER_DELAY).timeout
	_can_leave = true


func _on_game_over() -> void:
	_is_game_over = true
	SaveManager.submit_score(GameState.score)
	if _level_runner.last_checkpoint_id > 0:
		_game_over_label.text = "GAME OVER\nSkor: %d\n\nTekan [TEMBAK] untuk Lanjut dari Checkpoint\nTekan [ESC] untuk Menu Utama" % GameState.score
	else:
		_game_over_label.text = "GAME OVER\nSkor: %d\n\nTekan [TEMBAK] untuk Coba Lagi\nTekan [ESC] untuk Menu Utama" % GameState.score
	_game_over_label.visible = true
	await get_tree().create_timer(GAME_OVER_DELAY).timeout
	_can_leave = true


func _unhandled_input(event: InputEvent) -> void:
	if not _can_leave:
		return

	if event.is_action_pressed("pause"):
		SceneRouter.go_to(MENU_PATH)
		return

	if event.is_action_pressed("fire"):
		if _is_cleared:
			# Tamat level 1: kembali ke menu atau restart
			SceneRouter.go_to(MENU_PATH)
		elif _is_game_over:
			if _level_runner.last_checkpoint_id > 0:
				_restart_from_checkpoint()
			else:
				# Ulang dari awal level
				GameState.new_game(GameState.difficulty)
				SceneRouter.go_to("res://scenes/levels/test_level.tscn")


func _restart_from_checkpoint() -> void:
	_is_game_over = false
	_can_leave = false
	_game_over_label.visible = false
	GameState.lives = GameState.START_LIVES[GameState.difficulty]
	GameState.lives_changed.emit(GameState.lives)
	GameState.weapon_level = 1
	GameState.weapon_changed.emit(1)
	_player._dead = false
	_player.visible = true
	_player.position = Vector2(200, 540)
	_player._invuln = 2.5
	_level_runner.restart_from_checkpoint()
