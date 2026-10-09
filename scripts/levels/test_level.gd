extends Node2D
## Level uji prototipe: spawn musuh bergantian, game over, kembali ke menu.

const DroneScene: PackedScene = preload("res://scenes/enemies/enemy_drone.tscn")
const SineScene: PackedScene = preload("res://scenes/enemies/enemy_sine.tscn")
const MENU_PATH: String = "res://scenes/ui/main_menu.tscn"
const SPAWN_INTERVAL: float = 0.9
const SPAWN_X: float = 2050.0
const GAME_OVER_DELAY: float = 1.0

var _spawn_timer: float = 0.0
var _spawn_count: int = 0
var _is_game_over: bool = false
var _can_leave: bool = false

@onready var _enemies: Node2D = $Enemies
@onready var _game_over_label: Label = $HUD/GameOverLabel


func _ready() -> void:
	$Player.game_over.connect(_on_game_over)
	_game_over_label.visible = false


func _process(delta: float) -> void:
	if _is_game_over:
		return
	_spawn_timer -= delta
	if _spawn_timer <= 0.0:
		_spawn_timer = SPAWN_INTERVAL
		_spawn_enemy()


func _spawn_enemy() -> void:
	_spawn_count += 1
	var use_sine: bool = _spawn_count % 3 == 0
	var enemy: Enemy = (SineScene if use_sine else DroneScene).instantiate()
	var y_min: float = 320.0 if use_sine else 120.0
	var y_max: float = 760.0 if use_sine else 960.0
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
