class_name Explosion
extends Node2D
## Ledakan musuh: flash inti, gelombang kejut, dan pecahan poligon melayang.

const DURATION: float = 0.38

@export var base_color: Color = Color(1.0, 0.5, 0.25)
@export var shard_count: int = 10
@export var blast_scale: float = 1.0

var _time: float = 0.0
var _shards: Array[Dictionary] = []


func _ready() -> void:
	for i in shard_count:
		var angle: float = randf_range(-PI, PI)
		var speed: float = randf_range(180.0, 480.0) * blast_scale
		var rot_speed: float = randf_range(-12.0, 12.0)
		var size: float = randf_range(6.0, 14.0) * blast_scale
		# Buat bentuk pecahan poligon acak
		var pts := PackedVector2Array([
			Vector2(-size, -size * 0.5),
			Vector2(size * 0.8, -size * 0.7),
			Vector2(size, size * 0.6),
			Vector2(-size * 0.5, size)
		])
		var outline := PackedVector2Array([
			Vector2(-size, -size * 0.5),
			Vector2(size * 0.8, -size * 0.7),
			Vector2(size, size * 0.6),
			Vector2(-size * 0.5, size),
			Vector2(-size, -size * 0.5)
		])
		_shards.append({
			"pos": Vector2.ZERO,
			"vel": Vector2.from_angle(angle) * speed,
			"rot": randf() * TAU,
			"rot_speed": rot_speed,
			"pts": pts,
			"outline": outline,
			"scale": 1.0
		})


func _process(delta: float) -> void:
	_time += delta
	for s in _shards:
		s["pos"] += s["vel"] * delta
		s["rot"] += s["rot_speed"] * delta
		s["scale"] = maxf(0.0, 1.0 - (_time / DURATION))
	queue_redraw()
	if _time >= DURATION:
		queue_free()


func _draw() -> void:
	var progress: float = _time / DURATION
	var alpha: float = 1.0 - progress

	# 1. Flash inti di tengah
	var flash_r: float = 38.0 * blast_scale * (1.0 - progress)
	if flash_r > 0.0:
		draw_circle(Vector2.ZERO, flash_r, Color(1.0, 0.95, 0.7, alpha * 0.85))

	# 2. Ring gelombang kejut yang mengembang
	var ring_r: float = 65.0 * blast_scale * progress
	draw_arc(Vector2.ZERO, ring_r, 0.0, TAU, 32, Color(1.0, 0.8, 0.3, alpha * 0.7), 4.0 * blast_scale, true)

	# 3. Pecahan-pecahan yang terlempar berputar
	var shard_color := Color(base_color.r, base_color.g, base_color.b, alpha)
	var outline_color := Color(0.15, 0.1, 0.15, alpha)

	for s in _shards:
		var xf := Transform2D(s["rot"], s["scale"] * Vector2.ONE, 0.0, s["pos"])
		draw_set_transform_matrix(xf)
		draw_colored_polygon(s["pts"], shard_color)
		draw_polyline(s["outline"], outline_color, 2.0, true)
	draw_set_transform_matrix(Transform2D.IDENTITY)
