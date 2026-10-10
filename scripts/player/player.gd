class_name Player
extends Area2D
## Kapal Pip: gerak 8 arah, senjata bertingkat (level 1-5), rudal, shield, dan Splash.
## Nilai dari docs/BALANCE.md.

signal game_over

const SPEED: float = 600.0
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

var _cooldown: float = 0.0
var _missile_cooldown: float = 0.0
var _invuln: float = 0.0
var _dead: bool = false
var _shield_pulse: float = 0.0

@onready var _muzzle: Marker2D = $Muzzle
@onready var _shield_aura: Polygon2D = $ShieldAura


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
	position += dir * SPEED * delta
	var size: Vector2 = get_viewport_rect().size
	position.x = clampf(position.x, SCREEN_MARGIN.x, size.x - SCREEN_MARGIN.x)
	position.y = clampf(position.y, SCREEN_MARGIN.y, size.y - SCREEN_MARGIN.y)


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
		_shield_pulse += delta * 6.0
		var s: float = 1.0 + sin(_shield_pulse) * 0.06
		_shield_aura.scale = Vector2(s, s)


func _on_shield_changed(active: bool) -> void:
	_shield_aura.visible = active


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
