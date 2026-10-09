class_name Missile
extends Area2D
## Rudal pemain: melesat maju, meledak saat mengenai musuh, damage area 10.
## Nilai dari docs/BALANCE.md.

const INITIAL_SPEED: float = 400.0
const ACCELERATION: float = 1600.0
const MAX_SPEED: float = 1500.0
const DAMAGE: int = 10
const BLAST_RADIUS: float = 150.0
const DESPAWN_X: float = 2100.0

var _speed: float = INITIAL_SPEED
var _exploded: bool = false


func _ready() -> void:
	area_entered.connect(_on_area_entered)


func _physics_process(delta: float) -> void:
	if _exploded:
		return
	_speed = minf(_speed + ACCELERATION * delta, MAX_SPEED)
	position.x += _speed * delta
	if position.x > DESPAWN_X or position.y < -100.0 or position.y > 1180.0:
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	if _exploded:
		return
	var enemy := area as Enemy
	if enemy != null:
		_explode()


func _explode() -> void:
	_exploded = true
	# Beri damage ke semua musuh dalam radius ledakan
	for node in get_tree().get_nodes_in_group("enemy"):
		var enemy := node as Enemy
		if enemy != null and enemy.global_position.distance_to(global_position) <= BLAST_RADIUS:
			enemy.take_damage(DAMAGE)
	_play_blast_fx()


func _play_blast_fx() -> void:
	$Visual.visible = false
	$Flame.visible = false
	$CollisionShape2D.set_deferred("disabled", true)
	$Blast.visible = true
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property($Blast, "scale", Vector2(2.5, 2.5), 0.25).from(Vector2(0.3, 0.3))
	tween.tween_property($Blast, "modulate:a", 0.0, 0.25)
	tween.chain().tween_callback(queue_free)
