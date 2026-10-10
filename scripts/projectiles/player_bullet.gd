class_name PlayerBullet
extends Area2D
## Peluru pemain: mendukung sudut tembakan dan damage bertingkat.

const SPEED: float = 1400.0
const DESPAWN_X: float = 2100.0

var direction: Vector2 = Vector2.RIGHT
var damage: int = 1


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	rotation = direction.angle()
	if damage >= 2:
		scale = Vector2(1.3, 1.4)
		$Visual.color = Color(1.0, 0.65, 0.2, 1.0) # Peluru kuat bernuansa oranye berapi


func _physics_process(delta: float) -> void:
	position += direction * SPEED * delta
	if position.x > DESPAWN_X or position.y < -100.0 or position.y > 1180.0:
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	var enemy := area as Enemy
	if enemy != null:
		enemy.take_damage(damage, global_position)
		queue_free()
