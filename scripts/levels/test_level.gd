extends Node2D
## Level uji prototipe: spawn musuh bergantian, game over, kembali ke menu.

const DroneScene: PackedScene = preload("res://scenes/enemies/enemy_drone.tscn")
const SineScene: PackedScene = preload("res://scenes/enemies/enemy_sine.tscn")
const ShooterScene: PackedScene = preload("res://scenes/enemies/enemy_shooter.tscn")
const CarrierScene: PackedScene = preload("res://scenes/enemies/enemy_carrier.tscn")
const MENU_PATH: String = "res://scenes/ui/main_menu.tscn"
const SPAWN_INTERVAL: float = 0.9
const SPAWN_X: float = 2050.0
const GAME_OVER_DELAY: float = 1.0

var _spawn_timer: float = 0.0
var _spawn_count: int = 0
var _is_game_over: bool = false
var _can_leave: bool = false

var _shake_intensity: float = 0.0
var _shake_duration: float = 0.0
var _shake_timer: float = 0.0

@onready var _enemies: Node2D = $Enemies
@onready var _game_over_label: Label = $HUD/GameOverLabel
@onready var _camera: Camera2D = $Camera2D


func _ready() -> void:
	$Player.game_over.connect(_on_game_over)
	GameState.screen_shaken.connect(_on_screen_shaken)
	_game_over_label.visible = false


func _process(delta: float) -> void:
	_handle_screen_shake(delta)
	if _is_game_over:
		return
	_spawn_timer -= delta
	if _spawn_timer <= 0.0:
		_spawn_timer = SPAWN_INTERVAL
		_spawn_enemy()


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


func _spawn_enemy() -> void:
	_spawn_count += 1
	var scene: PackedScene = DroneScene
	var y_min: float = 120.0
	var y_max: float = 960.0
	if _spawn_count % 11 == 0:
		scene = CarrierScene
		y_min = 200.0
		y_max = 700.0
	elif _spawn_count % 5 == 0:
		scene = ShooterScene
		y_min = 250.0
		y_max = 830.0
	elif _spawn_count % 3 == 0:
		scene = SineScene
		y_min = 320.0
		y_max = 760.0
	var enemy: Enemy = scene.instantiate()
	enemy.position = Vector2(SPAWN_X, randf_range(y_min, y_max))
	_enemies.add_child(enemy)


func _on_game_over() -> void:
	_is_game_over = true
	SaveManager.submit_score(GameState.score)
	_game_over_label.text = "GAME OVER\nSkor: %d\nTekan tembak untuk kembali" % GameState.score
	_game_over_label.visible = true
	await get_tree().create_timer(GAME_OVER_DELAY).timeout
	_can_leave = true


func _unhandled_input(event: InputEvent) -> void:
	if _can_leave and event.is_action_pressed("fire"):
		SceneRouter.go_to(MENU_PATH)
