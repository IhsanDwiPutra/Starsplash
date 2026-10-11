class_name TouchControls
extends CanvasLayer
## Sistem Kontrol Layar Sentuh (Mobile Touch Controls) Modern untuk Android/Tablet:
## - Floating Virtual Joystick (360° analog inersia halus)
## - Tombol Tembak (Fire) & Toggle Otomatis (Auto-Fire)
## - Tombol Rudal [M] dengan penghitung sisa amunisi
## - Tombol Starsplash [⭐] dengan denyut cahaya saat meter penuh
## - Tombol Jeda (Pause [⏸])

@export var force_show_on_pc: bool = true
@export var joystick_radius: float = 90.0
@export var joystick_deadzone: float = 0.12

# Titik pusat default joystick
const DEFAULT_JOYSTICK_POS: Vector2 = Vector2(240.0, 780.0)

# Multi-touch tracking
var _joystick_touch_id: int = -1
var _joystick_base_pos: Vector2 = DEFAULT_JOYSTICK_POS
var _joystick_vector: Vector2 = Vector2.ZERO

var _fire_touch_id: int = -1
var _auto_fire_enabled: bool = true

# Node references
@onready var _joystick_base: Control = $Joystick/Base
@onready var _joystick_knob: Control = $Joystick/Base/Knob
@onready var _btn_fire: Control = $Buttons/BtnFire
@onready var _btn_auto_fire: Control = $Buttons/BtnAutoFire
@onready var _btn_auto_label: Label = $Buttons/BtnAutoFire/Label
@onready var _btn_missile: Control = $Buttons/BtnMissile
@onready var _missile_label: Label = $Buttons/BtnMissile/AmmoLabel
@onready var _btn_splash: Control = $Buttons/BtnSplash
@onready var _splash_label: Label = $Buttons/BtnSplash/ChargeLabel
@onready var _btn_pause: Control = $Buttons/BtnPause

var _splash_tween: Tween
var _is_splash_ready: bool = false


func _ready() -> void:
	# Cek deteksi layar sentuh atau paksa tampil di PC untuk pengujian
	var is_touch: bool = DisplayServer.is_touchscreen_available() or OS.has_feature("mobile")
	visible = is_touch or force_show_on_pc

	_reset_joystick()
	_update_auto_fire_ui()
	_update_missile_ui(GameState.missile_ammo, GameState.MAX_MISSILES)
	_update_splash_ui(GameState.splash_charge, GameState.SPLASH_MAX)

	GameState.missiles_changed.connect(_update_missile_ui)
	GameState.splash_changed.connect(_update_splash_ui)
	GameState.splash_ready.connect(_on_splash_ready)
	GameState.splash_fired.connect(_on_splash_fired)


func _exit_tree() -> void:
	_release_all_movement()
	if _auto_fire_enabled:
		Input.action_release("fire")


func _process(_delta: float) -> void:
	if not visible:
		return

	# Terapkan auto-fire jika aktif dan tidak sedang ditekan manual
	if _auto_fire_enabled:
		if not Input.is_action_pressed("fire"):
			Input.action_press("fire")


func _input(event: InputEvent) -> void:
	if not visible:
		return

	if event is InputEventScreenTouch:
		if event.pressed:
			_handle_touch_down(event.index, event.position)
		else:
			_handle_touch_up(event.index)

	elif event is InputEventScreenDrag:
		_handle_touch_drag(event.index, event.position)


func _handle_touch_down(touch_id: int, pos: Vector2) -> void:
	# 1. Cek tombol-tombol di sisi kanan layar terlebih dahulu
	if _is_point_inside(_btn_pause, pos, 36.0):
		_press_action_pulse("pause")
		return

	if _is_point_inside(_btn_auto_fire, pos, 40.0):
		_toggle_auto_fire()
		return

	if _is_point_inside(_btn_missile, pos, 54.0):
		_trigger_missile()
		return

	if _is_point_inside(_btn_splash, pos, 58.0):
		_trigger_splash()
		return

	if _is_point_inside(_btn_fire, pos, 62.0):
		_fire_touch_id = touch_id
		Input.action_press("fire")
		_pulse_button(_btn_fire)
		return

	# 2. Cek area joystick (sisi kiri layar: x <= 960)
	if pos.x <= 960.0 and pos.y >= 160.0:
		if _joystick_touch_id == -1:
			_joystick_touch_id = touch_id
			# Posisikan joystick secara floating di posisi sentuhan
			_joystick_base_pos = Vector2(
				clampf(pos.x, 120.0, 840.0),
				clampf(pos.y, 160.0, 960.0)
			)
			_joystick_base.global_position = _joystick_base_pos - (_joystick_base.size * 0.5)
			_joystick_knob.position = (_joystick_base.size - _joystick_knob.size) * 0.5
			_joystick_base.modulate.a = 0.85
			_update_joystick_vector(pos)


func _handle_touch_drag(touch_id: int, pos: Vector2) -> void:
	if touch_id == _joystick_touch_id:
		_update_joystick_vector(pos)


func _handle_touch_up(touch_id: int) -> void:
	if touch_id == _joystick_touch_id:
		_reset_joystick()

	if touch_id == _fire_touch_id:
		_fire_touch_id = -1
		if not _auto_fire_enabled:
			Input.action_release("fire")


func _update_joystick_vector(touch_pos: Vector2) -> void:
	var diff: Vector2 = touch_pos - _joystick_base_pos
	var dist: float = diff.length()

	if dist > joystick_radius:
		diff = diff.normalized() * joystick_radius

	# Posisikan knob
	var center_knob: Vector2 = (_joystick_base.size - _joystick_knob.size) * 0.5
	_joystick_knob.position = center_knob + diff

	# Normalisasi vektor 0..1
	var normal_dist: float = dist / joystick_radius
	if normal_dist < joystick_deadzone:
		_joystick_vector = Vector2.ZERO
		_release_all_movement()
	else:
		_joystick_vector = diff / joystick_radius
		_apply_movement_inputs(_joystick_vector)


func _apply_movement_inputs(v: Vector2) -> void:
	# Sumbu horizontal X
	if v.x > 0.05:
		Input.action_press("move_right", v.x)
		Input.action_release("move_left")
	elif v.x < -0.05:
		Input.action_press("move_left", -v.x)
		Input.action_release("move_right")
	else:
		Input.action_release("move_left")
		Input.action_release("move_right")

	# Sumbu vertikal Y
	if v.y > 0.05:
		Input.action_press("move_down", v.y)
		Input.action_release("move_up")
	elif v.y < -0.05:
		Input.action_press("move_up", -v.y)
		Input.action_release("move_down")
	else:
		Input.action_release("move_up")
		Input.action_release("move_down")


func _release_all_movement() -> void:
	Input.action_release("move_left")
	Input.action_release("move_right")
	Input.action_release("move_up")
	Input.action_release("move_down")


func _reset_joystick() -> void:
	_joystick_touch_id = -1
	_joystick_vector = Vector2.ZERO
	_release_all_movement()
	_joystick_base_pos = DEFAULT_JOYSTICK_POS
	_joystick_base.global_position = _joystick_base_pos - (_joystick_base.size * 0.5)
	_joystick_knob.position = (_joystick_base.size - _joystick_knob.size) * 0.5
	_joystick_base.modulate.a = 0.38


func _toggle_auto_fire() -> void:
	_auto_fire_enabled = not _auto_fire_enabled
	_update_auto_fire_ui()
	_pulse_button(_btn_auto_fire)
	AudioManager.play_sfx("pickup", 0.05)
	if not _auto_fire_enabled and _fire_touch_id == -1:
		Input.action_release("fire")


func _update_auto_fire_ui() -> void:
	if _btn_auto_label == null:
		return
	if _auto_fire_enabled:
		_btn_auto_label.text = "AUTO\nON"
		_btn_auto_fire.modulate = Color(0.4, 1.0, 0.7, 0.95)
	else:
		_btn_auto_label.text = "AUTO\nOFF"
		_btn_auto_fire.modulate = Color(0.65, 0.72, 0.85, 0.5)


func _trigger_missile() -> void:
	if GameState.missile_ammo <= 0:
		_shake_button(_btn_missile)
		return
	_pulse_button(_btn_missile)
	_press_action_pulse("missile")


func _trigger_splash() -> void:
	if GameState.splash_charge < GameState.SPLASH_MAX:
		_shake_button(_btn_splash)
		return
	_pulse_button(_btn_splash)
	_press_action_pulse("splash")


func _press_action_pulse(action_name: String) -> void:
	var ev_down := InputEventAction.new()
	ev_down.action = action_name
	ev_down.pressed = true
	Input.parse_input_event(ev_down)

	var ev_up := InputEventAction.new()
	ev_up.action = action_name
	ev_up.pressed = false
	Input.parse_input_event(ev_up)


func _update_missile_ui(ammo: int, _max_ammo: int) -> void:
	if _missile_label != null:
		_missile_label.text = "x%d" % ammo
	if _btn_missile != null:
		_btn_missile.modulate.a = 0.95 if ammo > 0 else 0.45


func _update_splash_ui(charge: int, max_charge: int) -> void:
	if _splash_label != null:
		if charge >= max_charge:
			_splash_label.text = "SIAP!"
		else:
			_splash_label.text = "%d/%d" % [charge, max_charge]

	if _btn_splash != null and not _is_splash_ready:
		var ratio: float = float(charge) / float(max_charge)
		_btn_splash.modulate.a = lerpf(0.45, 0.85, ratio)


func _on_splash_ready() -> void:
	_is_splash_ready = true
	if _btn_splash == null:
		return
	_btn_splash.modulate = Color(1.0, 0.9, 0.35, 1.0)
	if _splash_tween and _splash_tween.is_valid():
		_splash_tween.kill()
	_splash_tween = create_tween().set_loops()
	_splash_tween.tween_property(_btn_splash, "scale", Vector2(1.1, 1.1), 0.3)
	_splash_tween.tween_property(_btn_splash, "scale", Vector2(1.0, 1.0), 0.3)


func _on_splash_fired() -> void:
	_is_splash_ready = false
	if _splash_tween and _splash_tween.is_valid():
		_splash_tween.kill()
	if _btn_splash != null:
		_btn_splash.scale = Vector2(1.0, 1.0)
		_btn_splash.modulate = Color(1.0, 1.0, 1.0, 0.45)


func _pulse_button(node: Control) -> void:
	if node == null:
		return
	var t: Tween = create_tween()
	t.tween_property(node, "scale", Vector2(0.88, 0.88), 0.06)
	t.tween_property(node, "scale", Vector2(1.0, 1.0), 0.1)


func _shake_button(node: Control) -> void:
	if node == null:
		return
	var t: Tween = create_tween()
	t.tween_property(node, "position:x", node.position.x + 8.0, 0.05)
	t.tween_property(node, "position:x", node.position.x - 8.0, 0.05)
	t.tween_property(node, "position:x", node.position.x, 0.05)


func _is_point_inside(node: Control, pt: Vector2, radius: float = 50.0) -> bool:
	if node == null or not node.is_visible_in_tree():
		return false
	var center: Vector2 = node.global_position + (node.size * 0.5)
	return pt.distance_to(center) <= radius
