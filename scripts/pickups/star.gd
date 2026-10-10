class_name Star
extends Area2D
## Bintang dari musuh: meledak keluar, hanyut ke kiri, tertarik ke kapal saat dekat.
## Angka dari docs/BALANCE.md (Starsplash Combo).

const ATTRACT_RADIUS: float = 220.0
const ATTRACT_SPEED: float = 900.0
const COLLECT_RADIUS: float = 36.0
const DRIFT_SPEED: float = 180.0
const DESPAWN_X: float = -60.0

var _burst: Vector2 = Vector2.ZERO


func _ready() -> void:
	_burst = Vector2.from_angle(randf() * TAU) * randf_range(120.0, 260.0)


func _physics_process(delta: float) -> void:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player != null and player.visible:
		var to_player: Vector2 = player.global_position - global_position
		var dist: float = to_player.length()
		if dist <= COLLECT_RADIUS:
			GameState.add_stars(1)
			AudioManager.play_sfx("star", 0.08)
			queue_free()
			return
		if dist <= ATTRACT_RADIUS:
			position += to_player.normalized() * ATTRACT_SPEED * delta
			return
	_burst = _burst.lerp(Vector2.ZERO, minf(5.0 * delta, 1.0))
	position += (_burst + Vector2(-DRIFT_SPEED, 0.0)) * delta
	if position.x < DESPAWN_X:
		queue_free()
