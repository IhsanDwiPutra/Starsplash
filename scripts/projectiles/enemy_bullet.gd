class_name EnemyBullet
extends Area2D
## Peluru musuh. Kecepatan mengikuti kesulitan (GameState).

const MIN_BOUNDS: Vector2 = Vector2(-120.0, -120.0)
const MAX_BOUNDS: Vector2 = Vector2(2040.0, 1200.0)

var direction: Vector2 = Vector2.LEFT
var speed: float = -1.0
var _speed: float = 450.0


func _ready() -> void:
	add_to_group("enemy_bullet")
	_speed = speed if speed > 0.0 else GameState.get_enemy_bullet_speed()
	rotation = direction.angle() - PI


func _physics_process(delta: float) -> void:
	position += direction * _speed * delta
	if position.x < MIN_BOUNDS.x or position.x > MAX_BOUNDS.x \
			or position.y < MIN_BOUNDS.y or position.y > MAX_BOUNDS.y:
		queue_free()
