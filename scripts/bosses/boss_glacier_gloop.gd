class_name BossGlacierGloop
extends Area2D
## Boss Dunia 1: Glacier Gloop (Pengawal Laut Beku).
## HP 150, 3 Fase serangan (100% / 66% / 33%), drop 15 bintang, skor 5000.
## Nilai acuan dari docs/BALANCE.md.

signal health_changed(current: int, maximum: int)
signal phase_changed(phase: int)
signal defeated

const MAX_HP: int = 150
const SCORE_VALUE: int = 5000
const STAR_DROP_COUNT: int = 15
const RESTING_X: float = 1560.0
const ENTRANCE_SPEED: float = 380.0

const EnemyBulletScene: PackedScene = preload("res://scenes/projectiles/enemy_bullet.tscn")
const StarScene: PackedScene = preload("res://scenes/pickups/star.tscn")
const DroneScene: PackedScene = preload("res://scenes/enemies/enemy_drone.tscn")
const SineScene: PackedScene = preload("res://scenes/enemies/enemy_sine.tscn")
const HitSparkScene: PackedScene = preload("res://scenes/fx/hit_spark.tscn")
const ExplosionScene: PackedScene = preload("res://scenes/fx/explosion.tscn")
const CarrierScene: PackedScene = preload("res://scenes/enemies/enemy_carrier.tscn")
const PickupScene: PackedScene = preload("res://scenes/pickups/pickup.tscn")

var current_hp: int = MAX_HP
var current_phase: int = 1
var is_active: bool = false
var is_entering: bool = true
var is_dead: bool = false

var _time: float = 0.0
var _fire_timer: float = 1.5
var _special_timer: float = 5.0
var _carrier_timer: float = 12.0
var _center_y: float = 540.0
var _pulse_timer: float = 0.0

const BASE_SPRITE_SCALE: Vector2 = Vector2(0.32, 0.32)

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _upper_muzzle: Marker2D = $UpperMuzzle
@onready var _lower_muzzle: Marker2D = $LowerMuzzle
@onready var _collision: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	add_to_group("enemy")
	add_to_group("boss")
	current_hp = MAX_HP
	current_phase = 1
	_center_y = position.y
	health_changed.emit(current_hp, MAX_HP)
	_update_phase_visuals()


func _physics_process(delta: float) -> void:
	if is_dead:
		return

	_time += delta

	# 1. Alur Masuk (Entrance Fly-in)
	if is_entering:
		position.x -= ENTRANCE_SPEED * delta
		if position.x <= RESTING_X:
			position.x = RESTING_X
			is_entering = false
			is_active = true
			AudioManager.play_sfx("checkpoint")
			GameState.trigger_shake(6.0, 0.3)
		return

	if not is_active:
		return

	# 2. Manuver Bergerak Sesuai Fase
	_handle_movement(delta)

	# 3. Logika Tembakan Sesuai Fase
	_handle_combat(delta)

	# 4. Denyut Visual Core Reaktor
	_update_core_pulse(delta)


func _handle_movement(delta: float) -> void:
	match current_phase:
		1:
			# Ayunan vertikal halus
			position.y = _center_y + sin(_time * 1.4) * 220.0
			position.x = RESTING_X
		2:
			# Ayunan vertikal lebih cepat + sesekali maju-mundur
			position.y = _center_y + sin(_time * 2.0) * 280.0
			position.x = RESTING_X + sin(_time * 0.8) * 120.0
		3:
			# Gerakan enrage tidak teratur + tremor getaran es
			position.y = _center_y + sin(_time * 2.8) * 320.0 + randf_range(-4.0, 4.0)
			position.x = RESTING_X + sin(_time * 1.5) * 160.0 + randf_range(-3.0, 3.0)


func _handle_combat(delta: float) -> void:
	_fire_timer -= delta
	_special_timer -= delta
	_carrier_timer -= delta

	# Suplai Carrier Drone melintas berkala membawa [P] / [S]
	if _carrier_timer <= 0.0:
		_carrier_timer = 15.0
		_spawn_support_carrier()

	match current_phase:
		1:
			if _fire_timer <= 0.0:
				_fire_timer = 1.6
				_shoot_spread(3, 0.22)

			if _special_timer <= 0.0:
				_special_timer = 5.5
				_spawn_escort_drone()

		2:
			if _fire_timer <= 0.0:
				_fire_timer = 1.3
				_shoot_spread(5, 0.36)

			if _special_timer <= 0.0:
				_special_timer = 4.2
				_shoot_dual_fast()
				if randf() < 0.5:
					_spawn_escort_drone()

		3:
			if _fire_timer <= 0.0:
				_fire_timer = 0.85
				_shoot_barrage_stream()

			if _special_timer <= 0.0:
				_special_timer = 4.8
				_spawn_escort_sine()


func _shoot_spread(bullet_count: int, spread_angle: float) -> void:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	var base_dir: Vector2 = Vector2.LEFT
	if player != null and player.visible:
		base_dir = (player.global_position - global_position).normalized()

	var start_angle: float = base_dir.angle() - spread_angle * 0.5
	var step: float = spread_angle / float(maxi(bullet_count - 1, 1))

	for i in bullet_count:
		var angle: float = start_angle + float(i) * step
		_spawn_bullet(global_position + Vector2(-60, 0), Vector2.from_angle(angle))
	
	AudioManager.play_sfx("enemy_shoot", 0.04)


func _shoot_dual_fast() -> void:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	var dir: Vector2 = Vector2.LEFT
	if player != null and player.visible:
		dir = (player.global_position - global_position).normalized()

	_spawn_bullet(_upper_muzzle.global_position, dir, 520.0)
	_spawn_bullet(_lower_muzzle.global_position, dir, 520.0)
	AudioManager.play_sfx("enemy_shoot", 0.08)


func _shoot_barrage_stream() -> void:
	var use_upper: bool = int(_time * 10.0) % 2 == 0
	var muzzle_pos: Vector2 = _upper_muzzle.global_position if use_upper else _lower_muzzle.global_position
	
	var player := get_tree().get_first_node_in_group("player") as Node2D
	var dir: Vector2 = Vector2.LEFT
	if player != null and player.visible:
		dir = (player.global_position - muzzle_pos).normalized()
	
	_spawn_bullet(muzzle_pos, dir.rotated(randf_range(-0.12, 0.12)), 480.0)
	AudioManager.play_sfx("enemy_shoot", 0.1)


func _spawn_bullet(spawn_pos: Vector2, dir: Vector2, custom_speed: float = -1.0) -> void:
	var bullet := EnemyBulletScene.instantiate() as EnemyBullet
	bullet.direction = dir
	bullet.global_position = spawn_pos
	if custom_speed > 0.0:
		bullet.speed = custom_speed
	get_parent().add_child(bullet)


func _spawn_escort_drone() -> void:
	var drone := DroneScene.instantiate() as Enemy
	drone.position = Vector2(global_position.x - 40.0, global_position.y - 120.0)
	get_parent().add_child(drone)


func _spawn_escort_sine() -> void:
	var sine := SineScene.instantiate() as Enemy
	sine.position = Vector2(global_position.x - 40.0, global_position.y + 100.0)
	get_parent().add_child(sine)


func _spawn_support_carrier() -> void:
	var parent: Node = get_parent()
	if parent == null or is_dead:
		return
	var carrier := CarrierScene.instantiate() as Enemy
	var y_pos: float = 260.0 if randf() < 0.5 else 820.0
	carrier.position = Vector2(2050.0, y_pos)
	parent.add_child(carrier)


func _update_core_pulse(delta: float) -> void:
	if _sprite == null:
		return
	var speed_mult: float = float(current_phase) * 2.8
	_pulse_timer += delta * speed_mult
	var s: float = 1.0 + sin(_pulse_timer) * 0.035
	_sprite.scale = Vector2(BASE_SPRITE_SCALE.x * (2.0 - s), BASE_SPRITE_SCALE.y * s)


func take_damage(amount: int, hit_pos: Vector2 = Vector2.INF) -> void:
	if is_dead or is_entering:
		return

	current_hp = maxi(current_hp - amount, 0)
	health_changed.emit(current_hp, MAX_HP)

	# FX Hit & Spark
	_spawn_hit_spark(hit_pos)
	AudioManager.play_sfx("hit")
	_flash()

	# Cek transisi fase
	_check_phase_transition()

	if current_hp <= 0:
		_die()


func _check_phase_transition() -> void:
	if current_phase == 1 and current_hp <= 100:
		current_phase = 2
		phase_changed.emit(2)
		_on_phase_changed(2)
	elif current_phase == 2 and current_hp <= 50:
		current_phase = 3
		phase_changed.emit(3)
		_on_phase_changed(3)


func _on_phase_changed(new_phase: int) -> void:
	_update_phase_visuals()
	GameState.trigger_shake(8.0, 0.35)
	AudioManager.play_sfx("shield_break")

	# Flash efek transisi
	modulate = Color(2.5, 2.0, 1.2)
	var t: Tween = create_tween()
	t.tween_property(self, "modulate", Color.WHITE, 0.3)

	# Hadiah pecah fase: lepaskan Power-Up Senjata [P], Rudal [M], & Shield [S]
	_drop_phase_pickups(new_phase)


func _update_phase_visuals() -> void:
	if _sprite == null:
		return
	match current_phase:
		1:
			_sprite.modulate = Color(1.0, 1.0, 1.0)
		2:
			_sprite.modulate = Color(1.15, 0.95, 0.75)
		3:
			_sprite.modulate = Color(1.35, 0.7, 0.7)


func _drop_phase_pickups(phase: int) -> void:
	var parent: Node = get_parent()
	if parent == null or is_dead:
		return

	# Hadiah Pecah Fase: 1x Weapon Upgrade [P]
	var p_weapon := PickupScene.instantiate() as Pickup
	p_weapon.type = Pickup.Type.WEAPON
	p_weapon.position = global_position + Vector2(-60.0, -35.0)
	parent.add_child.call_deferred(p_weapon)

	# Hadiah Pecah Fase: 1x Amunisi Rudal [M] (+3 amunisi)
	var p_missile := PickupScene.instantiate() as Pickup
	p_missile.type = Pickup.Type.MISSILE
	p_missile.position = global_position + Vector2(-60.0, 35.0)
	parent.add_child.call_deferred(p_missile)

	# Jika masuk Fase 3 (Enrage mode): Berikan Shield [S] pelindung darurat!
	if phase == 3:
		var p_shield := PickupScene.instantiate() as Pickup
		p_shield.type = Pickup.Type.SHIELD
		p_shield.position = global_position + Vector2(-110.0, 0.0)
		parent.add_child.call_deferred(p_shield)


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
	_collision.set_deferred("disabled", true)

	# Alur ledakan berantai spektakuler
	_play_death_sequence()


func _play_death_sequence() -> void:
	# 1. Rangkaian 7 ledakan berurutan di titik acak tubuh boss
	for i in 7:
		var offset: Vector2 = Vector2(randf_range(-90, 80), randf_range(-70, 70))
		var mini_exp := ExplosionScene.instantiate() as Explosion
		mini_exp.global_position = global_position + offset
		mini_exp.base_color = Color(0.4, 0.85, 1.0)
		mini_exp.blast_scale = 1.2
		get_parent().add_child(mini_exp)
		AudioManager.play_sfx("explosion", 0.1)
		GameState.trigger_shake(5.0, 0.15)
		await get_tree().create_timer(0.22).timeout

	# 2. Ledakan Pamungkas Raksasa
	var final_exp := ExplosionScene.instantiate() as Explosion
	final_exp.global_position = global_position
	final_exp.base_color = Color(1.0, 0.8, 0.3)
	final_exp.blast_scale = 2.6
	final_exp.shard_count = 24
	get_parent().add_child(final_exp)
	
	AudioManager.play_sfx("carrier_explosion")
	GameState.trigger_shake(15.0, 0.8)

	# 3. Drop 15 Bintang + Skor
	GameState.register_kill()
	GameState.add_score(roundi(SCORE_VALUE * GameState.get_multiplier()))
	_drop_boss_stars(STAR_DROP_COUNT)

	defeated.emit()
	queue_free()


func _drop_boss_stars(count: int) -> void:
	var parent: Node = get_parent()
	for i in count:
		var star: Node2D = StarScene.instantiate()
		var offset: Vector2 = Vector2(randf_range(-50, 50), randf_range(-50, 50))
		star.position = position + offset
		parent.add_child.call_deferred(star)
