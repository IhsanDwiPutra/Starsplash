class_name Player
extends Area2D
## Kapal Pip: gerak 8 arah, senjata bertingkat (level 1-5), rudal, shield, dan Splash.
## Nilai dari docs/BALANCE.md.

signal game_over

const MAX_SPEED: float = 600.0
const ACCELERATION: float = 2500.0      ## Percepatan mesin saat menekan arah
const FRICTION: float = 1900.0          ## Hambatan inersia saat meluncur melepas tombol
const BRAKING_FORCE: float = 3600.0     ## Tenaga rem saat berbalik arah melawan inersia
const MAX_TILT_DEG: float = 7.5         ## Kemiringan badan pesawat saat naik/turun
const TILT_SPEED: float = 9.0           ## Kecepatan respon miring badan pesawat
const INVULN_TIME: float = 2.0
const SCREEN_MARGIN: Vector2 = Vector2(60.0, 40.0)

const FIRE_RATES: Array[float] = [6.0, 7.0, 8.0, 9.0, 10.0]
const MISSILE_COOLDOWN_TIME: float = 0.6
const SPLASH_DAMAGE: int = 8
const SPLASH_OFFSCREEN_MARGIN: float = 50.0

const BulletScene: PackedScene = preload("res://scenes/projectiles/player_bullet.tscn")
const MissileScene: PackedScene = preload("res://scenes/projectiles/missile.tscn")
const SplashWaveScene: PackedScene = preload("res://scenes/fx/splash_wave.tscn")
const ExplosionScene: PackedScene = preload("res://scenes/fx/explosion.tscn")

const BASE_SHIELD_SCALE: Vector2 = Vector2(0.21, 0.21)

var _velocity: Vector2 = Vector2.ZERO
var _cooldown: float = 0.0
var _missile_cooldown: float = 0.0
var _invuln: float = 0.0
var _dead: bool = false
var _shield_pulse: float = 0.0

@onready var _muzzle: Marker2D = $Muzzle
@onready var _shield_aura: Sprite2D = $ShieldAura
@onready var _thruster_flame: CPUParticles2D = $ThrusterFlame
@onready var _stardust_trail: CPUParticles2D = $StardustTrail


func _ready() -> void:
	add_to_group("player")
	GameState.shield_changed.connect(_on_shield_changed)
	_shield_aura.visible = GameState.has_shield


func _physics_process(delta: float) -> void:
	if _dead:
		return
	_move(delta)
	_handle_fire(delta)
	_handle_missile(delta)
	if Input.is_action_just_pressed("splash"):
		_try_splash()
	_update_shield_visual(delta)
	_handle_damage(delta)


func _move(delta: float) -> void:
	var dir: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var target_vel: Vector2 = dir * MAX_SPEED

	# Inersia sumbu horizontal (X) dengan bobot akselerasi dan pengereman balik arah
	if dir.x != 0.0:
		var accel_x: float = BRAKING_FORCE if (_velocity.x * dir.x < 0.0) else ACCELERATION
		_velocity.x = move_toward(_velocity.x, target_vel.x, accel_x * delta)
	else:
		_velocity.x = move_toward(_velocity.x, 0.0, FRICTION * delta)

	# Inersia sumbu vertikal (Y)
	if dir.y != 0.0:
		var accel_y: float = BRAKING_FORCE if (_velocity.y * dir.y < 0.0) else ACCELERATION
		_velocity.y = move_toward(_velocity.y, target_vel.y, accel_y * delta)
	else:
		_velocity.y = move_toward(_velocity.y, 0.0, FRICTION * delta)

	# Update posisi berdasarkan kecepatan saat ini
	position += _velocity * delta

	# Batasi agar tetap di dalam layar dan redam sisa kecepatan saat mentok batas
	var size: Vector2 = get_viewport_rect().size
	var prev_pos: Vector2 = position
	position.x = clampf(position.x, SCREEN_MARGIN.x, size.x - SCREEN_MARGIN.x)
	position.y = clampf(position.y, SCREEN_MARGIN.y, size.y - SCREEN_MARGIN.y)
	if position.x != prev_pos.x:
		_velocity.x = 0.0
	if position.y != prev_pos.y:
		_velocity.y = 0.0

	# Kemiringan badan kapal (Aerodynamic Pitch Lean saat naik / turun)
	var target_tilt: float = (_velocity.y / MAX_SPEED) * deg_to_rad(MAX_TILT_DEG)
	rotation = lerp_angle(rotation, target_tilt, delta * TILT_SPEED)

	# Efek dinamik semburan jet roket saat akselerasi dan meluncur
	if _thruster_flame != null:
		if dir.x > 0.1:
			_thruster_flame.initial_velocity_min = 230.0
			_thruster_flame.initial_velocity_max = 340.0
			_thruster_flame.lifetime = 0.35
		elif dir.x < -0.1:
			_thruster_flame.initial_velocity_min = 60.0
			_thruster_flame.initial_velocity_max = 120.0
			_thruster_flame.lifetime = 0.18
		else:
			# Saat idle atau meluncur inersia
			var speed_ratio: float = clampf(_velocity.x / MAX_SPEED, -0.5, 1.0)
			_thruster_flame.initial_velocity_min = lerpf(110.0, 200.0, maxf(0.0, speed_ratio))
			_thruster_flame.initial_velocity_max = lerpf(180.0, 290.0, maxf(0.0, speed_ratio))
			_thruster_flame.lifetime = lerpf(0.24, 0.32, maxf(0.0, speed_ratio))


func _handle_fire(delta: float) -> void:
	_cooldown -= delta
	var lvl: int = clampi(GameState.weapon_level, 1, 5)
	var fire_rate: float = FIRE_RATES[lvl - 1]
	if Input.is_action_pressed("fire") and _cooldown <= 0.0:
		_cooldown = 1.0 / fire_rate
		_shoot_weapon_pattern(lvl)
		AudioManager.play_sfx("shoot")


func _shoot_weapon_pattern(lvl: int) -> void:
	var m_pos: Vector2 = _muzzle.global_position
	match lvl:
		1:
			_spawn_bullet(m_pos, Vector2.RIGHT, 1)
		2:
			_spawn_bullet(m_pos + Vector2(0, -14), Vector2.RIGHT, 1)
			_spawn_bullet(m_pos + Vector2(0, 14), Vector2.RIGHT, 1)
		3:
			_spawn_bullet(m_pos, Vector2.RIGHT, 1)
			_spawn_bullet(m_pos, Vector2.from_angle(-0.18), 1)
			_spawn_bullet(m_pos, Vector2.from_angle(0.18), 1)
		4:
			_spawn_bullet(m_pos, Vector2.RIGHT, 2)
			_spawn_bullet(m_pos, Vector2.from_angle(-0.18), 2)
			_spawn_bullet(m_pos, Vector2.from_angle(0.18), 2)
		5:
			_spawn_bullet(m_pos, Vector2.RIGHT, 2)
			_spawn_bullet(m_pos, Vector2.from_angle(-0.16), 2)
			_spawn_bullet(m_pos, Vector2.from_angle(0.16), 2)
			_spawn_bullet(m_pos, Vector2.from_angle(-0.32), 2)
			_spawn_bullet(m_pos, Vector2.from_angle(0.32), 2)


func _spawn_bullet(pos: Vector2, dir: Vector2, dmg: int) -> void:
	var bullet := BulletScene.instantiate() as PlayerBullet
	bullet.direction = dir
	bullet.damage = dmg
	get_parent().add_child(bullet)
	bullet.global_position = pos


func _handle_missile(delta: float) -> void:
	_missile_cooldown -= delta
	if Input.is_action_just_pressed("missile") and _missile_cooldown <= 0.0:
		if GameState.use_missile():
			_missile_cooldown = MISSILE_COOLDOWN_TIME
			var missile := MissileScene.instantiate() as Missile
			get_parent().add_child(missile)
			missile.global_position = _muzzle.global_position
			AudioManager.play_sfx("missile")


func _try_splash() -> void:
	if not GameState.try_splash():
		return
	AudioManager.play_sfx("splash")
	GameState.trigger_shake(10.0, 0.35)
	for bullet in get_tree().get_nodes_in_group("enemy_bullet"):
		bullet.queue_free()
	var limit_x: float = get_viewport_rect().size.x + SPLASH_OFFSCREEN_MARGIN
	for node in get_tree().get_nodes_in_group("enemy"):
		if node is Node2D and node.has_method("take_damage"):
			var target := node as Node2D
			if target.global_position.x < limit_x:
				target.take_damage(SPLASH_DAMAGE, target.global_position)
	var wave := SplashWaveScene.instantiate() as Node2D
	get_parent().add_child(wave)
	wave.global_position = global_position


func _update_shield_visual(delta: float) -> void:
	if _shield_aura.visible:
		_shield_pulse += delta * 5.0
		_shield_aura.rotation += delta * 0.9
		var s: float = 1.0 + sin(_shield_pulse) * 0.05
		_shield_aura.scale = BASE_SHIELD_SCALE * s


func _on_shield_changed(active: bool) -> void:
	_shield_aura.visible = active
	if active:
		_shield_aura.scale = BASE_SHIELD_SCALE * 1.35
		var tween: Tween = create_tween()
		tween.tween_property(_shield_aura, "scale", BASE_SHIELD_SCALE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


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
	# Jika memiliki shield: serap serangan, jangan kurangi nyawa & level senjata
	if GameState.has_shield:
		GameState.set_shield(false)
		GameState.trigger_shake(5.0, 0.2)
		AudioManager.play_sfx("shield_break")
		_invuln = 1.0
		return
	# Tanpa shield: turunkan level senjata dan kurangi nyawa
	GameState.downgrade_weapon()
	GameState.lose_life()
	if GameState.lives <= 0:
		_dead = true
		visible = false
		_velocity = Vector2.ZERO
		rotation = 0.0
		if _thruster_flame != null:
			_thruster_flame.emitting = false
		if _stardust_trail != null:
			_stardust_trail.emitting = false
		var exp := ExplosionScene.instantiate() as Explosion
		exp.global_position = global_position
		exp.base_color = Color(0.35, 0.75, 1.0)
		exp.blast_scale = 1.8
		exp.shard_count = 18
		get_parent().add_child(exp)
		GameState.trigger_shake(12.0, 0.45)
		AudioManager.play_sfx("game_over")
		game_over.emit()
	else:
		GameState.trigger_shake(8.0, 0.25)
		AudioManager.play_sfx("hit")
		_invuln = INVULN_TIME


func respawn_at(spawn_pos: Vector2) -> void:
	_dead = false
	visible = true
	position = spawn_pos
	_velocity = Vector2.ZERO
	rotation = 0.0
	_invuln = 2.5
	if _thruster_flame != null:
		_thruster_flame.emitting = true
	if _stardust_trail != null:
		_stardust_trail.emitting = true
