class_name Player
extends Area2D
## Kapal Pip: gerak 8 arah dalam batas layar, tembakan dasar, nyawa & invulnerable.
## Angka dari docs/BALANCE.md (Senjata level 1, kecepatan pemain).

signal game_over

const SPEED: float = 600.0
const FIRE_RATE: float = 6.0
const INVULN_TIME: float = 2.0
const SCREEN_MARGIN: Vector2 = Vector2(60.0, 40.0)
const BulletScene: PackedScene = preload("res://scenes/projectiles/player_bullet.tscn")
const SplashWaveScene: PackedScene = preload("res://scenes/fx/splash_wave.tscn")
const SPLASH_DAMAGE: int = 8
const SPLASH_OFFSCREEN_MARGIN: float = 50.0

var _cooldown: float = 0.0
var _invuln: float = 0.0
var _dead: bool = false

@onready var _muzzle: Marker2D = $Muzzle


func _ready() -> void:
	add_to_group("player")


func _physics_process(delta: float) -> void:
	if _dead:
		return
	_move(delta)
	_handle_fire(delta)
	if Input.is_action_just_pressed("splash"):
		_try_splash()
	_handle_damage(delta)


func _move(delta: float) -> void:
	var dir: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	position += dir * SPEED * delta
	var size: Vector2 = get_viewport_rect().size
	position.x = clampf(position.x, SCREEN_MARGIN.x, size.x - SCREEN_MARGIN.x)
	position.y = clampf(position.y, SCREEN_MARGIN.y, size.y - SCREEN_MARGIN.y)


func _handle_fire(delta: float) -> void:
	_cooldown -= delta
	if Input.is_action_pressed("fire") and _cooldown <= 0.0:
		_cooldown = 1.0 / FIRE_RATE
		var bullet: Node2D = BulletScene.instantiate()
		get_parent().add_child(bullet)
		bullet.global_position = _muzzle.global_position


func _try_splash() -> void:
	if not GameState.try_splash():
		return
	for bullet in get_tree().get_nodes_in_group("enemy_bullet"):
		bullet.queue_free()
	var limit_x: float = get_viewport_rect().size.x + SPLASH_OFFSCREEN_MARGIN
	for node in get_tree().get_nodes_in_group("enemy"):
		var enemy := node as Enemy
		if enemy != null and enemy.global_position.x < limit_x:
			enemy.take_damage(SPLASH_DAMAGE)
	var wave := SplashWaveScene.instantiate() as Node2D
	get_parent().add_child(wave)
	wave.global_position = global_position


func _handle_damage(delta: float) -> void:
	if _invuln > 0.0:
		_invuln -= delta
		visible = int(_invuln * 10.0) % 2 == 0
		if _invuln <= 0.0:
			visible = true
		return
	for area in get_overlapping_areas():
		if area.is_in_group("enemy") or area.is_in_group("enemy_bullet"):
			_take_hit()
			return


func _take_hit() -> void:
	GameState.lose_life()
	if GameState.lives <= 0:
		_dead = true
		visible = false
		game_over.emit()
	else:
		_invuln = INVULN_TIME
