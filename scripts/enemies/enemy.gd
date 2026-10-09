class_name Enemy
extends Area2D
## Musuh dasar. Varian dibuat lewat scene dengan nilai export berbeda.
## Nilai awal dari docs/BALANCE.md. (Pengali HP kesulitan: belum diterapkan.)

signal died

enum MoveType { STRAIGHT, SINE }

@export var max_hp: int = 1
@export var speed: float = 300.0
@export var score_value: int = 100
@export var move_type: MoveType = MoveType.STRAIGHT
@export var sine_amplitude: float = 150.0
@export var sine_frequency: float = 2.0

const DESPAWN_X: float = -150.0

var _hp: int
var _time: float = 0.0
var _base_y: float
var _dead: bool = false


func _ready() -> void:
	add_to_group("enemy")
	_hp = max_hp
	_base_y = position.y


func _physics_process(delta: float) -> void:
	_time += delta
	position.x -= speed * delta
	if move_type == MoveType.SINE:
		position.y = _base_y + sin(_time * sine_frequency) * sine_amplitude
	if position.x < DESPAWN_X:
		queue_free()


func take_damage(amount: int) -> void:
	if _dead:
		return
	_hp -= amount
	if _hp <= 0:
		_die()
	else:
		_flash()


func _flash() -> void:
	modulate = Color(2.5, 2.5, 2.5)
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)


func _die() -> void:
	_dead = true
	GameState.add_score(score_value)
	died.emit()
	queue_free()
