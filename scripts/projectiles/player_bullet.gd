class_name PlayerBullet
extends Area2D
## Peluru pemain: lurus ke kanan. Nilai dari docs/BALANCE.md (level 1).

const SPEED: float = 1400.0
const DAMAGE: int = 1
const DESPAWN_X: float = 2100.0


func _ready() -> void:
	area_entered.connect(_on_area_entered)


func _physics_process(delta: float) -> void:
	position.x += SPEED * delta
	if position.x > DESPAWN_X:
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	var enemy := area as Enemy
	if enemy != null:
		enemy.take_damage(DAMAGE)
		queue_free()
