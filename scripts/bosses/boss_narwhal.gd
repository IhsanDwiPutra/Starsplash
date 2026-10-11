class_name BossNarwhal
extends Area2D
## Mini-Boss Stage 1-3: Mecha Narwhal (Penjaga Benteng Es).
## Memiliki tanduk bor es raksasa, serangan tabrakan es (Drill Charge), dan semburan kristal es.

signal health_changed(current: int, maximum: int)
signal defeated

const MAX_HP: int = 75
const SCORE_VALUE: int = 2500
const STAR_DROP_COUNT: int = 10
const RESTING_X: float = 1520.0
const ENTRANCE_SPEED: float = 340.0

const EnemyBulletScene: PackedScene = preload("res://scenes/projectiles/enemy_bullet.tscn")
const StarScene: PackedScene = preload("res://scenes/pickups/star.tscn")
const HitSparkScene: PackedScene = preload("res://scenes/fx/hit_spark.tscn")
const ExplosionScene: PackedScene = preload("res://scenes/fx/explosion.tscn")
const CarrierScene: PackedScene = preload("res://scenes/enemies/enemy_carrier.tscn")
const PickupScene: PackedScene = preload("res://scenes/pickups/pickup.tscn")

var current_hp: int = MAX_HP
var is_active: bool = false
var is_entering: bool = true
var is_dead: bool = false
var is_charging: bool = false

var _time: float = 0.0
var _attack_timer: float = 2.5
var _charge_cooldown: float = 6.0
var _base_y: float = 540.0
var _charge_target_x: float = 0.0

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _collision: CollisionShape2D = $CollisionShape2D
@onready var _muzzle: Marker2D = $Muzzle


func _ready() -> void:
	add_to_group("enemy")
	add_to_group("boss")
	current_hp = MAX_HP
	_base_y = position.y
	health_changed.emit(current_hp, MAX_HP)


func _physics_process(delta: float) -> void:
	if is_dead:
		return

	_time += delta

	# Entrance state: meluncur masuk dari kanan
	if is_entering:
		position.x -= ENTRANCE_SPEED * delta
		if position.x <= RESTING_X:
			position.x = RESTING_X
			is_entering = false
			is_active = true
		return

	if not is_active:
		return

	# Idle bobbing & renang
	if not is_charging:
		position.y = _base_y + sin(_time * 2.0) * 110.0
		# Halus bergerak kembali ke RESTING_X jika sempat maju
		position.x = move_toward(position.x, RESTING_X, 150.0 * delta)
		if _sprite != null:
			_sprite.scale.y = 0.22 * (1.0 + sin(_time * 4.5) * 0.03)
			_sprite.scale.x = 0.22 * (1.0 - sin(_time * 4.5) * 0.02)
	else:
		_process_charge(delta)

	_handle_attacks(delta)


func _handle_attacks(delta: float) -> void:
	if is_charging:
		return

	_attack_timer -= delta
	if _attack_timer <= 0.0:
		_attack_timer = randf_range(2.0, 3.2)
		_shoot_crystal_spread()

	_charge_cooldown -= delta
	if _charge_cooldown <= 0.0:
		_charge_cooldown = randf_range(7.0, 9.5)
		_start_drill_charge()


func _shoot_crystal_spread() -> void:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	var base_dir := Vector2.LEFT
	if player != null:
		base_dir = (player.global_position - global_position).normalized()

	AudioManager.play_sfx("enemy_shoot")
	var spread_angles := [-0.22, 0.0, 0.22]
	for ang in spread_angles:
		var dir := base_dir.rotated(ang)
		var b := EnemyBulletScene.instantiate() as EnemyBullet
		b.direction = dir
		b.speed = 420.0
		get_parent().add_child(b)
		b.global_position = _muzzle.global_position if _muzzle != null else global_position


func _start_drill_charge() -> void:
	is_charging = true
	# Telegraph peringatan: kedipan putih & mundur sedikit
	modulate = Color(2.0, 1.2, 0.6)
	var tween: Tween = create_tween()
	tween.tween_property(self, "position:x", RESTING_X + 90.0, 0.5).set_trans(Tween.TRANS_SINE)
	await tween.finished
	if is_dead:
		return

	modulate = Color.WHITE
	AudioManager.play_sfx("missile")
	# Terjang maju kencang dengan bor es
	var charge_tween: Tween = create_tween()
	charge_tween.tween_property(self, "position:x", 320.0, 0.75).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await charge_tween.finished
	if is_dead:
		return

	# Mundur kembali pelan-pelan ke posisi asal
	await get_tree().create_timer(0.35).timeout
	var return_tween: Tween = create_tween()
	return_tween.tween_property(self, "position:x", RESTING_X, 1.2).set_trans(Tween.TRANS_SINE)
	await return_tween.finished
	is_charging = false


func _process_charge(_delta: float) -> void:
	# Getar bor saat charge
	if _sprite != null:
		_sprite.position = Vector2(randf_range(-3, 3), randf_range(-3, 3))


func take_damage(amount: int, hit_pos: Vector2 = Vector2.INF) -> void:
	if is_dead or is_entering:
		return

	current_hp -= amount
	health_changed.emit(maxi(current_hp, 0), MAX_HP)
	_spawn_hit_spark(hit_pos)
	AudioManager.play_sfx("hit")

	if current_hp <= 0:
		_die()
	else:
		_flash()


func _flash() -> void:
	modulate = Color(2.2, 2.2, 2.2)
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.08)


func _spawn_hit_spark(hit_pos: Vector2) -> void:
	var spark := HitSparkScene.instantiate() as Node2D
	spark.global_position = global_position if hit_pos == Vector2.INF else hit_pos
	get_parent().add_child(spark)


func _die() -> void:
	is_dead = true
	is_active = false
	GameState.register_kill()
	GameState.add_score(roundi(SCORE_VALUE * GameState.get_multiplier()))
	_drop_rewards()
	defeated.emit()
	_play_death_sequence()


func _drop_rewards() -> void:
	# Drop 10 bintang
	for i in range(STAR_DROP_COUNT):
		var star := StarScene.instantiate() as Node2D
		star.position = global_position + Vector2(randf_range(-60, 60), randf_range(-40, 40))
		get_parent().call_deferred("add_child", star)

	# Hadiah amunisi & senjata
	var pickup := PickupScene.instantiate() as Pickup
	pickup.type = Pickup.Type.WEAPON
	pickup.position = global_position
	get_parent().call_deferred("add_child", pickup)


func _play_death_sequence() -> void:
	GameState.trigger_shake(12.0, 0.6)
	AudioManager.play_sfx("carrier_explosion")

	# Rangkaian ledakan berturut-turut
	for i in range(5):
		var exp := ExplosionScene.instantiate() as Explosion
		exp.global_position = global_position + Vector2(randf_range(-80, 80), randf_range(-50, 50))
		exp.base_color = Color(0.4, 0.8, 1.0)
		exp.blast_scale = 1.6
		get_parent().add_child(exp)
		await get_tree().create_timer(0.12).timeout

	queue_free()
