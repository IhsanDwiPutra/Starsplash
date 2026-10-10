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
const HitSparkScene: PackedScene = preload("res://scenes/fx/hit_spark.tscn")
const ExplosionScene: PackedScene = preload("res://scenes/fx/explosion.tscn")

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
	
	# Efek bernapas/renang ubur-ubur es
	if has_node("Sprite2D"):
		var spr := get_node("Sprite2D") as Sprite2D
		if spr != null:
			spr.scale.y = 0.115 + sin(_time * 5.5) * 0.007
			spr.scale.x = 0.115 - sin(_time * 5.5) * 0.005

	_handle_fire(delta)
	if position.x < DESPAWN_X:
		queue_free()


func take_damage(amount: int, hit_pos: Vector2 = Vector2.INF) -> void:
	if _dead:
		return
	_hp -= amount
	_spawn_hit_spark(hit_pos)
	AudioManager.play_sfx("hit")
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
	AudioManager.play_sfx("enemy_shoot")


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
	_spawn_explosion()
	AudioManager.play_sfx("carrier_explosion" if is_carrier else "explosion")
	died.emit()
	queue_free()


func _spawn_hit_spark(hit_pos: Vector2) -> void:
	var spark := HitSparkScene.instantiate() as Node2D
	spark.global_position = global_position if hit_pos == Vector2.INF else hit_pos
	get_parent().add_child(spark)


func _spawn_explosion() -> void:
	var explosion := ExplosionScene.instantiate() as Explosion
	explosion.global_position = global_position
	if has_node("Sprite2D"):
		explosion.base_color = Color(0.35, 0.85, 1.0) # Es kristal cyan
	elif has_node("Visual"):
		var visual := get_node("Visual") as Polygon2D
		if visual != null:
			explosion.base_color = visual.color
	if is_carrier:
		explosion.blast_scale = 1.4
		explosion.shard_count = 14
		GameState.trigger_shake(6.0, 0.22)
	elif move_type == MoveType.HOLD:
		explosion.blast_scale = 1.2
		explosion.shard_count = 12
		GameState.trigger_shake(4.5, 0.18)
	else:
		explosion.blast_scale = 1.0
		explosion.shard_count = 9
		GameState.trigger_shake(3.0, 0.12)
	get_parent().add_child(explosion)


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

