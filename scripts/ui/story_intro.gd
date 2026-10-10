extends Control
## Layar Prolog Cerita Komik Fullscreen (Sinematik Subtitle & Efek Komik).
## Menampilkan ilustrasi penuh layar dengan efek Ken Burns, subtitle sinematik, efek guncangan/flash, dan kontrol interaktif.

const LEVEL_PATH: String = "res://scenes/levels/test_level.tscn"
const STAGE_SELECT_PATH: String = "res://scenes/ui/stage_select.tscn"
const MENU_PATH: String = "res://scenes/ui/main_menu.tscn"

const PANELS: Array[Dictionary] = [
	{
		"texture": "res://assets/art/story/intro_panel_1.jpg",
		"badge": "✦ BAB 1 • KEDAMAIAN SAMUDRA ✦",
		"badge_color": Color(0.4, 0.95, 1.0, 1.0),
		"title": "Cahaya Bintang Abadi",
		"text": "Di perairan Laut Beku yang damai, Bintang Abadi memancarkan kehangatan dan keajaiban. Pip menjaga cahaya suci ini bersama seluruh penghuni kepulauan es dengan penuh suka cita.",
		"sfx": "pickup",
		"shake": 0.0,
		"flash": false
	},
	{
		"texture": "res://assets/art/story/intro_panel_2.jpg",
		"badge": "⚡ BAB 2 • SERBUAN KEGELAPAN ⚡",
		"badge_color": Color(1.0, 0.45, 0.45, 1.0),
		"title": "Serbuan Jahat Raja Es Gloop!",
		"text": "Namun kedamaian sirna seketika! Raja Es Glacier Gloop bangkit dari palung es kelam bersama armada ubur-ubur esnya, menculik bintang-bintang kosmik dan membekukan seluruh samudra!",
		"sfx": "carrier_explosion",
		"shake": 14.0,
		"flash": true
	},
	{
		"texture": "res://assets/art/story/intro_panel_3.jpg",
		"badge": "🚀 BAB 3 • TEKAD MEMBARA 🚀",
		"badge_color": Color(1.0, 0.85, 0.35, 1.0),
		"title": "Lepas Landas Kapal Bintang Pip!",
		"text": "Pip menolak menyerah pada kegelapan! Menyalakan pendorong roket jet kapal tempurnya, Pip meluncur menembus badai es kutub: 'Saatnya merebut kembali bintang kita!'",
		"sfx": "checkpoint",
		"shake": 8.0,
		"flash": false
	}
]

@onready var _panel_image: TextureRect = $FullscreenViewport/PanelImage
@onready var _flash_overlay: ColorRect = $FlashOverlay
@onready var _badge_label: Label = $SubtitlePlate/VBox/HeaderRow/BadgeLabel
@onready var _step_label: Label = $SubtitlePlate/VBox/HeaderRow/StepLabel
@onready var _title_label: Label = $SubtitlePlate/VBox/TitleLabel
@onready var _desc_label: Label = $SubtitlePlate/VBox/DescLabel

@onready var _btn_prev: Button = $SubtitlePlate/VBox/ControlsRow/BtnPrev
@onready var _btn_next: Button = $SubtitlePlate/VBox/ControlsRow/BtnNext
@onready var _btn_skip: Button = $TopBar/BtnSkip

var _current_panel: int = 0
var _zoom_tween: Tween = null
var _type_tween: Tween = null
var _shake_offset: Vector2 = Vector2.ZERO


func _ready() -> void:
	AudioManager.play_music("menu")

	if _btn_skip != null:
		_btn_skip.pressed.connect(_skip_or_back)
	if _btn_next != null:
		_btn_next.pressed.connect(_next_panel)
	if _btn_prev != null:
		_btn_prev.pressed.connect(_prev_panel)

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

	# 1. Update gambar & mulai animasi Ken Burns zoom perlahan
	if _panel_image != null:
		var tex_path: String = data.get("texture", "")
		if ResourceLoader.exists(tex_path):
			_panel_image.texture = load(tex_path)

		_panel_image.pivot_offset = Vector2(960, 540)
		_panel_image.scale = Vector2(1.0, 1.0)
		_panel_image.modulate = Color(1.0, 1.0, 1.0, 0.2)

		if _zoom_tween != null and _zoom_tween.is_valid():
			_zoom_tween.kill()
		_zoom_tween = create_tween()
		_zoom_tween.set_parallel(true)
		_zoom_tween.tween_property(_panel_image, "modulate:a", 1.0, 0.4)
		_zoom_tween.tween_property(_panel_image, "scale", Vector2(1.045, 1.045), 7.0).set_trans(Tween.TRANS_SINE)

	# 2. Update teks & badge subtitle
	if _badge_label != null:
		_badge_label.text = data.get("badge", "")
		_badge_label.modulate = data.get("badge_color", Color.WHITE)
	if _title_label != null:
		_title_label.text = data.get("title", "")
	if _step_label != null:
		_step_label.text = "[ %d / %d ]" % [index + 1, PANELS.size()]

	# 3. Efek ketik teks narasi (Typewriter Effect)
	var full_text: String = data.get("text", "")
	if _desc_label != null:
		_desc_label.text = full_text
		_desc_label.visible_characters = 0

		if _type_tween != null and _type_tween.is_valid():
			_type_tween.kill()
		_type_tween = create_tween()
		var char_duration: float = clampf(full_text.length() * 0.016, 0.6, 1.6)
		_type_tween.tween_property(_desc_label, "visible_characters", full_text.length(), char_duration)

	# 4. Efek Suara, Flash Petir & Screen Shake dramatis
	var sfx_name: String = data.get("sfx", "pickup")
	AudioManager.play_sfx(sfx_name, 0.05)

	if data.get("flash", false) and _flash_overlay != null:
		_trigger_flash()

	var shake_val: float = float(data.get("shake", 0.0))
	if shake_val > 0.0:
		_trigger_shake(shake_val)

	# 5. Tombol navigasi
	if _btn_prev != null:
		_btn_prev.visible = (index > 0)

	if _btn_next != null:
		if index >= PANELS.size() - 1:
			_btn_next.text = "🚀  GAS BERANGKAT! [SPASI]"
		else:
			_btn_next.text = "SELANJUTNYA ▶ [SPASI]"
		_btn_next.grab_focus()


func _trigger_flash() -> void:
	if _flash_overlay == null:
		return
	_flash_overlay.visible = true
	_flash_overlay.color = Color(0.9, 0.8, 1.0, 0.85)
	var t: Tween = create_tween()
	t.tween_property(_flash_overlay, "color:a", 0.0, 0.35)
	t.tween_callback(func() -> void: _flash_overlay.visible = false)


func _trigger_shake(intensity: float) -> void:
	var t: Tween = create_tween()
	var steps: int = 8
	var duration: float = 0.4
	for i in range(steps):
		var damp: float = 1.0 - (float(i) / float(steps))
		var offset: Vector2 = Vector2(
			randf_range(-intensity, intensity) * damp,
			randf_range(-intensity, intensity) * damp
		)
		t.tween_property(self, "position", offset, duration / steps)
	t.tween_property(self, "position", Vector2.ZERO, 0.05)


func _next_panel() -> void:
	if _current_panel < PANELS.size() - 1:
		_show_panel(_current_panel + 1)
	else:
		_finish_intro()


func _prev_panel() -> void:
	AudioManager.play_sfx("pickup", 0.03)
	if _current_panel > 0:
		_show_panel(_current_panel - 1)


func _skip_or_back() -> void:
	AudioManager.play_sfx("pickup")
	if SaveManager.has_seen_intro:
		# Jika sedang menonton ulang, kembali ke menu utama
		SceneRouter.go_to(MENU_PATH)
	else:
		_finish_intro()


func _finish_intro() -> void:
	AudioManager.play_sfx("checkpoint")
	SaveManager.mark_intro_seen()
	# Mulai Stage 1-1
	GameState.start_stage(1, 1)
	SceneRouter.go_to(LEVEL_PATH)
