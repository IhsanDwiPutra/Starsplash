class_name Enemy
extends Area2D
## Musuh dasar. Varian dibuat lewat scene dengan nilai export berbeda.
## Nilai awal dari docs/BALANCE.md.

signal died

enum MoveType { STRAIGHT, SINE, HOLD }

@export var max_hp: int = 1
@export var speed: float = 300.0
@export var score_value: int = 100
@export var star_value: int = 1
@export var move_type: MoveType = MoveType.STRAIGHT
@export var sine_amplitude: float = 150.0
@export var sine_frequency: float = 2.0
## HOLD: berhenti di x ini lalu menembak, pergi lagi setelah hold_duration.
@export var hold_x: float = 1500.0
@export var hold_duration: float = 6.0
## Selang tembak (detik). 0 = tidak menembak.
@export var fire_interval: float = 0.0
## Carrier: drone khusus pembawa hadiah (100% drop [P] atau Shield)
@export var is_carrier: bool = false

const DESPAWN_X: float = -150.0
const ON_SCREEN_X: float = 1880.0
const StarScene: PackedScene = preload("res://scenes/pickups/star.tscn")
const EnemyBulletScene: PackedScene = preload("res://scenes/projectiles/enemy_bullet.tscn")
const PickupScene: PackedScene = preload("res://scenes/pickups/pickup.tscn")

static var _kills_without_drop: int = 0

var _hp: int
var _time: float = 0.0
var _base_y: float
var _dead: bool = false
var _fire_timer: float = 0.0
var _hold_left: float = 0.0


func _ready() -> void:
	add_to_group("enemy")
	_hp = max_hp
	_base_y = position.y
	_hold_left = hold_duration
	_fire_timer = fire_interval


func _physics_process(delta: float) -> void:
	_time += delta
	match move_type:
		MoveType.STRAIGHT:
			position.x -= speed * delta
		MoveType.SINE:
			position.x -= speed * delta
			position.y = _base_y + sin(_time * sine_frequency) * sine_amplitude
		MoveType.HOLD:
			_move_hold(delta)
	_handle_fire(delta)
	if position.x < DESPAWN_X:
		queue_free()


func take_damage(amount: int) -> void:
	if _dead:
		return
	_hp -= amount
	if _hp <= 0:
		_die()
	else:
		_flash()


func _move_hold(delta: float) -> void:
	if position.x > hold_x:
		position.x -= speed * delta
	elif _hold_left > 0.0:
		_hold_left -= delta
		position.y = _base_y + sin(_time * 1.5) * 30.0
	else:
		position.x -= speed * delta


func _handle_fire(delta: float) -> void:
	if fire_interval <= 0.0 or position.x > ON_SCREEN_X:
		return
	_fire_timer -= delta
	if _fire_timer <= 0.0:
		_fire_timer = fire_interval
		_shoot()


func _shoot() -> void:
	var dir: Vector2 = Vector2.LEFT
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player != null:
		dir = (player.global_position - global_position).normalized()
	var bullet := EnemyBulletScene.instantiate() as EnemyBullet
	bullet.direction = dir
	get_parent().add_child(bullet)
	bullet.global_position = global_position + dir * 40.0


func _flash() -> void:
	modulate = Color(2.5, 2.5, 2.5)
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)


func _die() -> void:
	_dead = true
	GameState.register_kill()
	GameState.add_score(roundi(score_value * GameState.get_multiplier()))
	_drop_stars(star_value + GameState.combo_bonus_stars())
	_maybe_drop_pickup()
	died.emit()
	queue_free()


func _drop_stars(count: int) -> void:
	var parent: Node = get_parent()
	for i in count:
		var star: Node2D = StarScene.instantiate()
		star.position = position
		parent.add_child.call_deferred(star)


func _maybe_drop_pickup() -> void:
	if is_carrier:
		# Carrier drone selalu menjatuhkan Power-Up atau Shield!
		var pickup := PickupScene.instantiate() as Pickup
		pickup.position = position
		if not GameState.has_shield and randf() < 0.4:
			pickup.type = Pickup.Type.SHIELD
		else:
			pickup.type = Pickup.Type.WEAPON
		get_parent().add_child.call_deferred(pickup)
		return

	if move_type == MoveType.HOLD:
		# Shooter enemy punya peluang 35% menjatuhkan Shield atau Rudal
		if randf() < 0.35:
			var pickup := PickupScene.instantiate() as Pickup
			pickup.position = position
			pickup.type = Pickup.Type.SHIELD if (not GameState.has_shield and randf() < 0.5) else Pickup.Type.MISSILE
			get_parent().add_child.call_deferred(pickup)
		return

	# Musuh biasa (Drone, Sine): peluang kecil menjatuhkan amunisi Rudal (6%)
	if randf() < 0.06:
		var pickup := PickupScene.instantiate() as Pickup
		pickup.position = position
		pickup.type = Pickup.Type.MISSILE
		get_parent().add_child.call_deferred(pickup)

