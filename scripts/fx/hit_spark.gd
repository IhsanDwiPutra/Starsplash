class_name HitSpark
extends Node2D
## Percikan saat peluru mengenai musuh. Menghilang sangat cepat (0.12s).

const DURATION: float = 0.12
const SPARK_COUNT: int = 5

var _sparks: Array[Dictionary] = []
var _time: float = 0.0


func _ready() -> void:
	for i in SPARK_COUNT:
		var angle: float = randf_range(-PI, PI)
		var speed: float = randf_range(160.0, 340.0)
		_sparks.append({
			"dir": Vector2.from_angle(angle),
			"speed": speed,
			"length": randf_range(8.0, 16.0),
			"pos": Vector2.ZERO
		})


func _process(delta: float) -> void:
	_time += delta
	for s in _sparks:
		s["pos"] += s["dir"] * s["speed"] * delta
	queue_redraw()
	if _time >= DURATION:
		queue_free()


func _draw() -> void:
	var alpha: float = 1.0 - (_time / DURATION)
	var color := Color(1.0, 0.95, 0.4, alpha)
	for s in _sparks:
		var p1: Vector2 = s["pos"]
		var p2: Vector2 = p1 - s["dir"] * s["length"] * alpha
		draw_line(p1, p2, color, 3.0, true)
