extends Control
## Layar Pemilihan Dunia (World Select) Starsplash.
## Menampilkan 4 dunia petualangan dengan kartu interaktif dan navigasi ke pilihan stage.

const STAGE_SELECT_PATH: String = "res://scenes/ui/stage_select.tscn"
const MENU_PATH: String = "res://scenes/ui/main_menu.tscn"

@onready var _btn_back: Button = $VBoxContainer/BottomBar/BtnBack
@onready var _btn_world_1: Button = $VBoxContainer/CenterBox/CardsHBox/CardWorld1/VBox/BtnEnterWorld1
@onready var _card_world_1: PanelContainer = $VBoxContainer/CenterBox/CardsHBox/CardWorld1


func _ready() -> void:
	AudioManager.play_music("menu")

	if _btn_back != null:
		_btn_back.pressed.connect(_on_back_pressed)

	if _btn_world_1 != null:
		_btn_world_1.pressed.connect(_enter_world_1)
		_btn_world_1.mouse_entered.connect(_on_btn_hover)
		_btn_world_1.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_on_back_pressed()
		get_viewport().set_input_as_handled()


func _on_btn_hover() -> void:
	AudioManager.play_sfx("pickup", 0.03)


func _enter_world_1() -> void:
	AudioManager.play_sfx("checkpoint")
	GameState.current_world = 1
	SceneRouter.go_to(STAGE_SELECT_PATH)


func _on_back_pressed() -> void:
	AudioManager.play_sfx("pickup")
	SceneRouter.go_to(MENU_PATH)
