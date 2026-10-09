extends Node2D
## Efek gelombang Splash: cincin yang membesar lalu menghilang.

const MAX_RADIUS: float = 2300.0
const DURATION: float = 0.7

var _radius: float = 0.0
var _alpha: float = 1.0


func _ready() -> void:
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(self, "_radius", MAX_RADIUS, DURATION).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "_alpha", 0.0, DURATION)
	tween.chain().tween_callback(queue_free)


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	draw_circle(Vector2.ZERO, _radius, Color(1.0, 1.0, 1.0, _alpha * 0.15))
	draw_arc(Vector2.ZERO, _radius, 0.0, TAU, 128, Color(1.0, 0.95, 0.5, _alpha), 18.0)
