extends Node2D
## Background Parallax Dunia 1: Laut Beku (Skybox Aurora Kosmik & Pegunungan Es Bersalju).

const SCREEN: Vector2 = Vector2(1920.0, 1080.0)

const SkyboxTex: Texture2D = preload("res://assets/art/backgrounds/bg_skybox_aurora.jpg")
const FarMountainsTex: Texture2D = preload("res://assets/art/backgrounds/bg_mountains_far.png")

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	_rng.seed = 7
	_build_sky()
	_build_stars()
	_build_far_mountains()


func _new_layer(speed: float) -> BgLayer:
	var layer := BgLayer.new()
	layer.speed = speed
	layer.tile_width = SCREEN.x
	add_child(layer)
	return layer


func _build_sky() -> void:
	# Skybox kanvas panorama penuh 16:9, statis agar aurora dan bulan tampil megah tanpa garis patah
	var layer: BgLayer = _new_layer(0.0)
	layer.add_texture(SkyboxTex, Rect2(0.0, 0.0, SCREEN.x, SCREEN.y))


func _build_stars() -> void:
	# Percikan bintang kosmik lembut di langit
	var layer: BgLayer = _new_layer(12.0)
	for i in 35:
		var pos := Vector2(_rng.randf_range(20.0, SCREEN.x - 20.0), _rng.randf_range(20.0, 400.0))
		layer.add_circle(pos, _rng.randf_range(1.5, 3.2), Color(1.0, 0.95, 0.7, _rng.randf_range(0.3, 0.75)))


func _build_far_mountains() -> void:
	# Pegunungan es bersalju baru meluncur mulus di separuh bawah layar
	var layer: BgLayer = _new_layer(35.0)
	layer.add_texture(FarMountainsTex, Rect2(0.0, 10.0, SCREEN.x, 1070.0), Color(1.0, 1.0, 1.0, 0.98))
