extends Control
## Layar Pemilihan Stage (Stage Select Hub) Dunia 1: Laut Beku.
## Menampilkan 6 tahapan dengan sistem buka kunci progres (unlocked stage).

const LEVEL_PATH: String = "res://scenes/levels/test_level.tscn"
const WORLD_SELECT_PATH: String = "res://scenes/ui/world_select.tscn"
const STORY_INTRO_PATH: String = "res://scenes/ui/story_intro.tscn"

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
@onready var _btn_prologue: Button = $VBoxContainer/BottomBar/BtnPrologue
@onready var _cards_container: GridContainer = $VBoxContainer/GridContainer
@onready var _sub_title_label: Label = $VBoxContainer/HeaderBox/SubTitleLabel

var _stage_buttons: Array[Button] = []


func _ready() -> void:
	AudioManager.play_music("menu")

	if _btn_back != null:
		_btn_back.pressed.connect(_on_back_pressed)
	if _btn_prologue != null:
		_btn_prologue.pressed.connect(func() -> void:
			AudioManager.play_sfx("pickup")
			SceneRouter.go_to(STORY_INTRO_PATH)
		)

	_setup_stage_cards()


func _setup_stage_cards() -> void:
	_stage_buttons.clear()
	var default_focus_btn: Button = null

	var total_stars: int = SaveManager.get_total_stars(GameState.current_world)
	if _sub_title_label != null:
		_sub_title_label.text = "PILIH TAHAPAN PETUALANGAN PIP  •  ⭐ %d / 18 BINTANG TERKUMPUL" % total_stars

	for stage_num in range(1, 7):
		var card_node: Control = _cards_container.get_node_or_null("CardStage%d" % stage_num) as Control
		if card_node == null:
			continue

		var btn: Button = card_node.find_child("BtnPlay", true, false) as Button
		var badge_label: Label = card_node.find_child("Badge", true, false) as Label
		var stage_tag: Label = card_node.find_child("StageTag", true, false) as Label
		var is_unlocked: bool = SaveManager.is_stage_unlocked(GameState.current_world, stage_num)
		var stars: int = SaveManager.get_stage_stars(GameState.current_world, stage_num)

		if btn != null:
			var s_num: int = stage_num
			btn.mouse_filter = Control.MOUSE_FILTER_STOP
			btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

			if is_unlocked:
				card_node.modulate = Color(1.0, 1.0, 1.0, 1.0)
				btn.disabled = false
				btn.text = "▶  MAINKAN"

				var star_icons: String = ""
				for i in range(3):
					star_icons += "★" if i < stars else "☆"

				if stage_tag != null:
					stage_tag.text = "STAGE 1-%d  %s" % [s_num, star_icons]

				if badge_label != null:
					var base_badge: String = STAGE_DETAILS.get(s_num, {}).get("badge", "★ TERBUKA")
					if stars == 3:
						badge_label.text = "🏆 " + base_badge
						badge_label.modulate = Color(1.0, 0.88, 0.25, 1.0)
					else:
						badge_label.text = base_badge

				# Hubungkan klik tombol
				btn.pressed.connect(func() -> void: _play_stage(s_num))
				btn.mouse_entered.connect(_on_btn_hover)
				_stage_buttons.append(btn)

				# Default fokus ke stage tertinggi yang terbuka
				default_focus_btn = btn
			else:
				# Tampilan kartu terkunci
				card_node.modulate = Color(0.65, 0.72, 0.85, 0.6)
				btn.disabled = true
				btn.text = "🔒 TERKUNCI"
				if stage_tag != null:
					stage_tag.text = "STAGE 1-%d" % s_num
				if badge_label != null:
					badge_label.text = "🔒 TERKUNCI"
					badge_label.modulate = Color(0.7, 0.75, 0.85, 0.8)

	if default_focus_btn != null:
		default_focus_btn.grab_focus()
	elif _stage_buttons.size() > 0:
		_stage_buttons[0].grab_focus()



func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_on_back_pressed()
		get_viewport().set_input_as_handled()


func _on_btn_hover() -> void:
	AudioManager.play_sfx("pickup", 0.03)


func _play_stage(stage_num: int) -> void:
	AudioManager.play_sfx("checkpoint")
	GameState.start_stage(GameState.current_world, stage_num)
	if stage_num == 1 and not SaveManager.has_seen_intro:
		SceneRouter.go_to(STORY_INTRO_PATH)
	else:
		SceneRouter.go_to(LEVEL_PATH)


func _on_back_pressed() -> void:
	AudioManager.play_sfx("pickup")
	SceneRouter.go_to(WORLD_SELECT_PATH)
