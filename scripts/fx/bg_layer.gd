class_name BgLayer
extends Node2D
## Satu lapisan parallax prosedural. Bentuk digambar sekali (2 salinan untuk looping mulus)
## lalu hanya digeser, jadi murah untuk Web/Android.

var speed: float = 0.0
var tile_width: float = 3840.0

var _items: Array[Dictionary] = []


func add_poly(points: PackedVector2Array, color: Color, outline: Color = Color(0, 0, 0, 0), closed_outline_count: int = 0) -> void:
	_items.append({"kind": "poly", "pts": points, "color": color, "outline": outline, "outline_count": closed_outline_count})


func add_gradient(points: PackedVector2Array, colors: PackedColorArray) -> void:
	_items.append({"kind": "gradient", "pts": points, "colors": colors})


func add_circle(pos: Vector2, radius: float, color: Color) -> void:
	_items.append({"kind": "circle", "pos": pos, "r": radius, "color": color})


func add_line(from: Vector2, to: Vector2, color: Color, width: float) -> void:
	_items.append({"kind": "line", "a": from, "b": to, "color": color, "width": width})


func add_texture(texture: Texture2D, rect: Rect2, modulate_color: Color = Color.WHITE) -> void:
	_items.append({"kind": "texture", "tex": texture, "rect": rect, "modulate": modulate_color})


func _process(delta: float) -> void:
	if speed <= 0.0:
		return
	position.x -= speed * delta
	if position.x <= -tile_width:
		position.x += tile_width


func _draw() -> void:
	var copies: int = 2 if speed > 0.0 else 1
	for copy in copies:
		draw_set_transform(Vector2(tile_width * copy, 0.0))
		for item in _items:
			_draw_item(item)
	draw_set_transform(Vector2.ZERO)


func _draw_item(item: Dictionary) -> void:
	match item["kind"]:
		"texture":
			draw_texture_rect(item["tex"], item["rect"], false, item["modulate"])
		"poly":
			draw_colored_polygon(item["pts"], item["color"])
			var outline: Color = item["outline"]
			if outline.a > 0.0:
				var pts: PackedVector2Array = item["pts"]
				var count: int = item["outline_count"] if item["outline_count"] > 0 else pts.size()
				draw_polyline(pts.slice(0, count), outline, 4.0, true)
		"gradient":
			draw_polygon(item["pts"], item["colors"])
		"circle":
			draw_circle(item["pos"], item["r"], item["color"])
		"line":
			draw_line(item["a"], item["b"], item["color"], item["width"], true)
