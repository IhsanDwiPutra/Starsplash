extends Control
## Layar Prolog Cerita (Story Intro) 3 Panel.
## Menjelaskan pencurian Bintang Abadi oleh Raja Glacier Gloop dan tekad Pip.

const LEVEL_PATH: String = "res://scenes/levels/test_level.tscn"
const STAGE_SELECT_PATH: String = "res://scenes/ui/stage_select.tscn"

const PANELS: Array[Dictionary] = [
	{
		"texture": "res://assets/art/story/intro_panel_1.jpg",
		"badge": "PANEL 1 / 3 • KEDAMAIAN SAMUDRA",
		"title": "Cahaya Bintang Abadi",
		"text": "Di perairan Laut Beku yang damai, Bintang Abadi memancarkan kehangatan dan keajaiban. Pip menjaga cahaya suci ini bersama seluruh penghuni kepulauan es dengan penuh suka cita."
	},
	{
		"texture": "res://assets/art/story/intro_panel_2.jpg",
		"badge": "PANEL 2 / 3 • SERBUAN KEGELAPAN",
		"title": "Serbuan Jahat Raja Es Gloop!",
		"text": "Namun kedamaian sirna seketika! Raja Es Glacier Gloop bangkit dari palung es kelam bersama armada ubur-ubur esnya, menculik bintang-bintang kosmik dan membekukan seluruh samudra!"
	},
	{
		"texture": "res://assets/art/story/intro_panel_3.jpg",
		"badge": "PANEL 3 / 3 • TEKAD MEMBARA",
		"title": "Lepas Landas Kapal Bintang Pip!",
		"text": "Pip menolak menyerah pada kegelapan! Menyalakan pendorong roket jet kapal tempurnya, Pip meluncur menembus badai es kutub: 'Saatnya merebut kembali bintang kita!'"
	}
]

@onready var _panel_image: TextureRect = $MainContainer/PanelCard/ImageContainer/PanelImage
@onready var _badge_label: Label = $MainContainer/StoryBox/VBox/TopInfo/BadgeLabel
@onready var _title_label: Label = $MainContainer/StoryBox/VBox/TitleLabel
@onready var _desc_label: Label = $MainContainer/StoryBox/VBox/DescLabel
@onready var _step_label: Label = $MainContainer/StoryBox/VBox/TopInfo/StepLabel

@onready var _btn_next: Button = $MainContainer/ActionBox/BtnNext
@onready var _btn_skip: Button = $TopBar/BtnSkip
@onready var _panel_card: PanelContainer = $MainContainer/PanelCard

var _current_panel: int = 0
var _target_scene: String = LEVEL_PATH


func _ready() -> void:
	AudioManager.play_music("menu")

	if _btn_skip != null:
		_btn_skip.pressed.connect(_skip_or_back)
	if _btn_next != null:
		_btn_next.pressed.connect(_next_panel)

	_show_panel(0)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_skip_or_back()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("fire"):
		_next_panel()
		get_viewport().set_input_as_handled()


func _show_panel(index: int) -> void:
	_current_panel = index
	var data: Dictionary = PANELS[index]

	var tex_path: String = data.get("texture", "")
	if ResourceLoader.exists(tex_path):
		_panel_image.texture = load(tex_path)

	_badge_label.text = data.get("badge", "")
	_title_label.text = data.get("title", "")
	_desc_label.text = data.get("text", "")
	_step_label.text = "[ %d / %d ]" % [index + 1, PANELS.size()]

	if index >= PANELS.size() - 1:
		_btn_next.text = "🚀  GAS BERANGKAT! [SPASI]"
	else:
		_btn_next.text = "▶  LANJUTKAN [SPASI]"

	_btn_next.grab_focus()

	# Animasi fade halus pada panel gambar
	if _panel_card != null:
		_panel_card.modulate = Color(1.0, 1.0, 1.0, 0.4)
		var tw: Tween = create_tween()
		tw.tween_property(_panel_card, "modulate:a", 1.0, 0.3)


func _next_panel() -> void:
	AudioManager.play_sfx("pickup", 0.05)
	if _current_panel < PANELS.size() - 1:
		_show_panel(_current_panel + 1)
	else:
		_finish_intro()


func _skip_or_back() -> void:
	AudioManager.play_sfx("pickup")
	if SaveManager.has_seen_intro:
		# Jika sedang menonton ulang, kembali ke menu utama
		SceneRouter.go_to("res://scenes/ui/main_menu.tscn")
	else:
		_finish_intro()


func _finish_intro() -> void:
	AudioManager.play_sfx("checkpoint")
	SaveManager.mark_intro_seen()
	# Pastikan GameState diatur ke Stage 1-1
	GameState.start_stage(1, 1)
	SceneRouter.go_to(LEVEL_PATH)
