class_name Pickup
extends Area2D
## Item drop dari musuh: Weapon Upgrade (P), Missile Ammo (M), Shield (S).

enum Type { WEAPON, MISSILE, SHIELD }

const DRIFT_SPEED: float = 120.0
const DESPAWN_X: float = -100.0

@export var type: Type = Type.WEAPON

var _time: float = 0.0
var _base_y: float = 0.0


func _ready() -> void:
	add_to_group("pickup")
	_base_y = position.y
	area_entered.connect(_on_area_entered)
	_setup_visual()


func _setup_visual() -> void:
	match type:
		Type.WEAPON:
			if has_node("SpriteWeapon"):
				$SpriteWeapon.visible = true
				$Border.visible = false
				$Badge.visible = false
				$Label.visible = false
			else:
				$Badge.color = Color(1.0, 0.72, 0.1, 1.0)
				$Label.text = "P"
		Type.MISSILE:
			if has_node("SpriteWeapon"):
				$SpriteWeapon.visible = false
			$Border.visible = true
			$Badge.visible = true
			$Label.visible = true
			$Badge.color = Color(0.95, 0.3, 0.3, 1.0)
			$Label.text = "M"
		Type.SHIELD:
			if has_node("SpriteWeapon"):
				$SpriteWeapon.visible = false
			$Border.visible = true
			$Badge.visible = true
			$Label.visible = true
			$Badge.color = Color(0.2, 0.75, 1.0, 1.0)
			$Label.text = "S"


func _physics_process(delta: float) -> void:
	_time += delta
	position.x -= DRIFT_SPEED * delta
	position.y = _base_y + sin(_time * 3.0) * 15.0
	
	if has_node("SpriteWeapon") and $SpriteWeapon.visible:
		$SpriteWeapon.rotation = sin(_time * 3.5) * 0.1
		$SpriteWeapon.scale = Vector2(0.065, 0.065) * (1.0 + sin(_time * 6.0) * 0.07)
		
	if position.x < DESPAWN_X:
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		_collect()


func _collect() -> void:
	match type:
		Type.WEAPON:
			GameState.upgrade_weapon()
		Type.MISSILE:
			GameState.add_missiles(3)
		Type.SHIELD:
			GameState.set_shield(true)
	GameState.add_score(150)
	AudioManager.play_sfx("pickup")
	queue_free()
