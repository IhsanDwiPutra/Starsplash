extends Control
## Layar Pemilihan Stage (Stage Select Hub) Dunia 1: Laut Beku.
## Menampilkan 6 tahapan dengan informasi musuh/boss dan akses langsung ke gameplay.

const LEVEL_PATH: String = "res://scenes/levels/test_level.tscn"
const MENU_PATH: String = "res://scenes/ui/main_menu.tscn"

const STAGE_DETAILS: Dictionary = {
	1: {
		"title": "STAGE 1-1",
		"name": "Pesisir Es",
		"desc": "Barisan Frost Jelly & Carrier Harta karun",
		"type": "NORMAL",
		"badge": "★ PEMULA"
	},
	2: {
		"title": "STAGE 1-2",
		"name": "Selat Gunung Es",
		"desc": "Uji gelombang gerak sinus & penembak es",
		"type": "NORMAL",
		"badge": "★★ STANDAR"
	},
	3: {
		"title": "STAGE 1-3",
		"name": "Benteng Es",
		"desc": "Pertahanan sengit & duel Mini-Boss Es",
		"type": "MINI_BOSS",
		"badge": "⚔️ MINI-BOSS"
	},
	4: {
		"title": "STAGE 1-4",
		"name": "Badai Salju Malam",
		"desc": "Formasi kilat V di tengah badai es beku",
		"type": "NORMAL",
		"badge": "★★★ SENGIT"
	},
	5: {
		"title": "STAGE 1-5",
		"name": "Palung Laut Dalam",
		"desc": "Serbuan rapat gabungan shooter & carrier",
		"type": "NORMAL",
		"badge": "★★★★ ELITE"
	},
	6: {
		"title": "STAGE 1-6",
		"name": "Tahta Inti Gloop",
		"desc": "Duel klimaks epik 3 Fase Boss Glacier Gloop",
		"type": "MAJOR_BOSS",
		"badge": "👑 FINAL BOSS"
	}
}

@onready var _btn_back: Button = $VBoxContainer/BottomBar/BtnBack
@onready var _cards_container: GridContainer = $VBoxContainer/GridContainer

var _stage_buttons: Array[Button] = []


func _ready() -> void:
	AudioManager.play_music("menu")

	_btn_back.pressed.connect(_on_back_pressed)

	# Setup event listener untuk ke-6 kartu stage
	for stage_num in range(1, 7):
		var btn_path: String = "VBoxContainer/GridContainer/CardStage%d/BtnPlay" % stage_num
		if has_node(btn_path):
			var btn: Button = get_node(btn_path) as Button
			var s_num: int = stage_num
			btn.pressed.connect(func() -> void: _play_stage(s_num))
			btn.mouse_entered.connect(_on_btn_hover)
			_stage_buttons.append(btn)

	if _stage_buttons.size() > 0:
		_stage_buttons[0].grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_on_back_pressed()
		get_viewport().set_input_as_handled()


func _on_btn_hover() -> void:
	AudioManager.play_sfx("pickup", 0.03)


func _play_stage(stage_num: int) -> void:
	AudioManager.play_sfx("checkpoint")
	GameState.start_stage(1, stage_num)
	SceneRouter.go_to(LEVEL_PATH)


func _on_back_pressed() -> void:
	AudioManager.play_sfx("pickup")
	SceneRouter.go_to(MENU_PATH)
