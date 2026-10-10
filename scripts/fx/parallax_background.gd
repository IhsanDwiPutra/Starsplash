extends Node2D
## Background parallax dunia Laut Beku (placeholder prosedural, pastel flat).
## Semua bentuk dibuat dari kode dengan seed tetap, jadi hasilnya selalu sama.

const SCREEN: Vector2 = Vector2(1920.0, 1080.0)
const TILE_W: float = 3840.0
const HORIZON_Y: float = 720.0

const SKY_TOP: Color = Color(0.17, 0.26, 0.6)
const SKY_HORIZON: Color = Color(0.5, 0.68, 0.93)
const SEA_TOP: Color = Color(0.3, 0.5, 0.82)
const SEA_BOTTOM: Color = Color(0.13, 0.24, 0.56)
const FAR_MOUNTAIN: Color = Color(0.42, 0.46, 0.78)
const FAR_OUTLINE: Color = Color(0.3, 0.33, 0.64)
const ICEBERG: Color = Color(0.66, 0.74, 0.96)
const ICEBERG_OUTLINE: Color = Color(0.44, 0.52, 0.82)
const SNOW: Color = Color(0.93, 0.96, 1.0, 0.9)

const SkyboxTex: Texture2D = preload("res://assets/art/backgrounds/bg_skybox_aurora.jpg")
const FarMountainsTex: Texture2D = preload("res://assets/art/backgrounds/bg_mountains_far.png")

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	_rng.seed = 7
	_build_sky()
	_build_stars()
	_build_far_mountains()
	_build_mountains(ICEBERG, ICEBERG_OUTLINE, 65.0, HORIZON_Y + 10.0, 90.0, 210.0, 160.0, 320.0)
	_build_ripples()
	_build_floes()


func _new_layer(speed: float) -> BgLayer:
	var layer := BgLayer.new()
	layer.speed = speed
	layer.tile_width = TILE_W
	add_child(layer)
	return layer


func _build_sky() -> void:
	var layer: BgLayer = _new_layer(5.0)
	layer.tile_width = 1920.0
	layer.add_texture(SkyboxTex, Rect2(0.0, 0.0, 1920.0, 1080.0))


func _build_far_mountains() -> void:
	var layer: BgLayer = _new_layer(25.0)
	layer.tile_width = 1920.0
	# Skala proporsional 1920 x 1070, posisi Y di-offset agar puncak es pas di atas horizon laut
	layer.add_texture(FarMountainsTex, Rect2(0.0, 90.0, 1920.0, 1070.0), Color(1.0, 1.0, 1.0, 0.98))


func _build_stars() -> void:
	var layer: BgLayer = _new_layer(10.0)
	for i in 40:
		var pos := Vector2(_rng.randf_range(20.0, TILE_W - 20.0), _rng.randf_range(20.0, 480.0))
		layer.add_circle(pos, _rng.randf_range(1.5, 3.0), Color(1.0, 0.95, 0.7, _rng.randf_range(0.3, 0.7)))


func _build_clouds() -> void:
	var layer: BgLayer = _new_layer(45.0)
	for i in 7:
		var cx: float = (TILE_W / 7.0) * i + _rng.randf_range(100.0, 300.0)
		var cy: float = _rng.randf_range(120.0, 460.0)
		var scale_f: float = _rng.randf_range(0.8, 1.5)
		var color := Color(1, 1, 1, 0.55)
		layer.add_circle(Vector2(cx, cy), 50.0 * scale_f, color)
		layer.add_circle(Vector2(cx + 60.0 * scale_f, cy - 22.0 * scale_f), 62.0 * scale_f, color)
		layer.add_circle(Vector2(cx + 125.0 * scale_f, cy), 48.0 * scale_f, color)
		layer.add_circle(Vector2(cx + 62.0 * scale_f, cy + 18.0 * scale_f), 55.0 * scale_f, color)


func _build_mountains(color: Color, outline: Color, speed: float, base_y: float,
		h_min: float, h_max: float, step_min: float, step_max: float) -> void:
	var layer: BgLayer = _new_layer(speed)
	var pts := PackedVector2Array()
	var peak_indices: Array[int] = []
	pts.append(Vector2(0.0, base_y - 30.0))
	var x: float = 0.0
	var high: bool = true
	while true:
		x += _rng.randf_range(step_min, step_max)
		if x >= TILE_W - step_min:
			break
		if high:
			peak_indices.append(pts.size())
			pts.append(Vector2(x, base_y - _rng.randf_range(h_min, h_max)))
		else:
			pts.append(Vector2(x, base_y - _rng.randf_range(10.0, h_min * 0.45)))
		high = not high
	pts.append(Vector2(TILE_W, base_y - 30.0))
	var skyline_count: int = pts.size()
	pts.append(Vector2(TILE_W, base_y + 2.0))
	pts.append(Vector2(0.0, base_y + 2.0))
	layer.add_poly(pts, color, outline, skyline_count)
	for idx in peak_indices:
		_add_snow_cap(layer, pts, idx)


func _add_snow_cap(layer: BgLayer, pts: PackedVector2Array, idx: int) -> void:
	if idx <= 0 or idx >= pts.size() - 3:
		return
	var apex: Vector2 = pts[idx]
	var left: Vector2 = apex.lerp(pts[idx - 1], 0.3)
	var right: Vector2 = apex.lerp(pts[idx + 1], 0.3)
	var low := Vector2((left.x + right.x) * 0.5, maxf(left.y, right.y) + 22.0)
	layer.add_poly(PackedVector2Array([apex, right, low, left]), SNOW)


func _build_ripples() -> void:
	var layer: BgLayer = _new_layer(120.0)
	for i in 55:
		var y: float = _rng.randf_range(HORIZON_Y + 30.0, SCREEN.y - 20.0)
		var x: float = _rng.randf_range(0.0, TILE_W - 200.0)
		var length: float = _rng.randf_range(60.0, 170.0)
		layer.add_line(Vector2(x, y), Vector2(x + length, y), Color(1, 1, 1, 0.18), 4.0)


func _build_floes() -> void:
	var layer: BgLayer = _new_layer(200.0)
	for i in 9:
		var cx: float = (TILE_W / 9.0) * i + _rng.randf_range(60.0, 260.0)
		var cy: float = _rng.randf_range(HORIZON_Y + 130.0, SCREEN.y - 40.0)
		var w: float = _rng.randf_range(140.0, 280.0)
		var h: float = w * 0.14
		var pts := PackedVector2Array()
		for step in 14:
			var a: float = TAU * float(step) / 14.0
			pts.append(Vector2(cx + cos(a) * w, cy + sin(a) * h))
		layer.add_poly(pts, Color(0.86, 0.92, 1.0, 0.6), Color(1, 1, 1, 0.5))
