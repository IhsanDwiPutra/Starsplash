extends Control
## Menu Utama Starsplash: Parallax background hidup, pilihan kesulitan, pengaturan audio, dan rekor skor.

const WORLD_SELECT_PATH: String = "res://scenes/ui/world_select.tscn"
const LEVEL_PATH: String = "res://scenes/levels/test_level.tscn"

const DIFFICULTY_INFO: Dictionary = {
	GameState.Difficulty.EASY: "MUDAH: 5 Nyawa • Kecepatan Peluru Musuh Santai (Cocok untuk pemula)",
	GameState.Difficulty.NORMAL: "NORMAL: 3 Nyawa • Pengalaman Shmup Standar yang Seimbang",
	GameState.Difficulty.HARD: "SULIT: 2 Nyawa • Peluru Musuh Cepat & Agresif (Tantangan Veteran)"
}

@onready var _pip_ship: Node2D = $PipAnchor/PipShip
@onready var _high_score_label: Label = $CenterContainer/MainCard/HighScoreBadge/HighScoreLabel
@onready var _diff_desc_label: Label = $CenterContainer/MainCard/DiffDescLabel

@onready var _btn_easy: Button = $CenterContainer/MainCard/DifficultyBox/BtnEasy
@onready var _btn_normal: Button = $CenterContainer/MainCard/DifficultyBox/BtnNormal
@onready var _btn_hard: Button = $CenterContainer/MainCard/DifficultyBox/BtnHard

@onready var _btn_start: Button = $CenterContainer/MainCard/ActionBox/BtnStart
@onready var _btn_settings: Button = $CenterContainer/MainCard/ActionBox/BtnSettings
@onready var _btn_quit: Button = $CenterContainer/MainCard/ActionBox/BtnQuit

@onready var _settings_modal: Control = $SettingsModal
@onready var _music_slider: HSlider = $SettingsModal/SettingsCard/VBox/AudioBox/MusicSlider
@onready var _music_val_label: Label = $SettingsModal/SettingsCard/VBox/AudioBox/MusicRow/MusicValLabel
@onready var _sfx_slider: HSlider = $SettingsModal/SettingsCard/VBox/AudioBox/SfxSlider
@onready var _sfx_val_label: Label = $SettingsModal/SettingsCard/VBox/AudioBox/SfxRow/SfxValLabel
@onready var _btn_close_settings: Button = $SettingsModal/SettingsCard/VBox/BtnCloseSettings

var _time: float = 0.0
var _current_diff: GameState.Difficulty = GameState.Difficulty.NORMAL


func _ready() -> void:
	AudioManager.play_music("menu")
	_settings_modal.visible = false

	# Tampilkan Rekor
	_high_score_label.text = "🏆 REKOR TERTINGGI: %07d" % SaveManager.high_score

	# Muat kesulitan dari SaveManager
	_current_diff = SaveManager.selected_difficulty as GameState.Difficulty
	_update_difficulty_buttons()

	# Connect buttons
	_btn_easy.pressed.connect(func() -> void: _set_difficulty(GameState.Difficulty.EASY))
	_btn_normal.pressed.connect(func() -> void: _set_difficulty(GameState.Difficulty.NORMAL))
	_btn_hard.pressed.connect(func() -> void: _set_difficulty(GameState.Difficulty.HARD))

	_btn_start.pressed.connect(_start_game)
	_btn_settings.pressed.connect(_open_settings)
	_btn_quit.pressed.connect(func() -> void: get_tree().quit())

	# Connect audio modal
	_btn_close_settings.pressed.connect(_close_settings)
	_music_slider.value_changed.connect(_on_music_slider_changed)
	_sfx_slider.value_changed.connect(_on_sfx_slider_changed)

	_sync_audio_sliders()
	_btn_start.grab_focus()


func _process(delta: float) -> void:
	_time += delta
	# Animasi melayang lembut kapal Pip di samping logo
	if _pip_ship != null:
		_pip_ship.position.y = sin(_time * 2.8) * 14.0
		_pip_ship.rotation = sin(_time * 1.5) * 0.08


func _unhandled_input(event: InputEvent) -> void:
	if _settings_modal.visible:
		if event.is_action_pressed("pause"):
			_close_settings()
			get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed("fire"):
		_start_game()
		get_viewport().set_input_as_handled()


func _set_difficulty(diff: GameState.Difficulty) -> void:
	_current_diff = diff
	SaveManager.save_settings(SaveManager.music_volume, SaveManager.sfx_volume, int(diff))
	_update_difficulty_buttons()
	AudioManager.play_sfx("pickup", 0.04)


func _update_difficulty_buttons() -> void:
	_btn_easy.modulate = Color(1.2, 1.2, 1.2) if _current_diff == GameState.Difficulty.EASY else Color(0.65, 0.65, 0.65)
	_btn_normal.modulate = Color(1.2, 1.2, 1.2) if _current_diff == GameState.Difficulty.NORMAL else Color(0.65, 0.65, 0.65)
	_btn_hard.modulate = Color(1.2, 1.2, 1.2) if _current_diff == GameState.Difficulty.HARD else Color(0.65, 0.65, 0.65)

	_btn_easy.text = "★ MUDAH" if _current_diff == GameState.Difficulty.EASY else "  MUDAH"
	_btn_normal.text = "★ NORMAL" if _current_diff == GameState.Difficulty.NORMAL else "  NORMAL"
	_btn_hard.text = "★ SULIT" if _current_diff == GameState.Difficulty.HARD else "  SULIT"

	_diff_desc_label.text = DIFFICULTY_INFO.get(_current_diff, "")


func _start_game() -> void:
	AudioManager.play_sfx("checkpoint")
	GameState.new_game(_current_diff)
	SceneRouter.go_to(WORLD_SELECT_PATH)


func _open_settings() -> void:
	_sync_audio_sliders()
	_settings_modal.visible = true
	_btn_close_settings.grab_focus()
	AudioManager.play_sfx("pickup")


func _close_settings() -> void:
	_settings_modal.visible = false
	_btn_settings.grab_focus()
	AudioManager.play_sfx("pickup")


func _sync_audio_sliders() -> void:
	var m_pct: int = roundi(SaveManager.music_volume * 100.0)
	var s_pct: int = roundi(SaveManager.sfx_volume * 100.0)
	_music_slider.value = m_pct
	_music_val_label.text = "%d%%" % m_pct
	_sfx_slider.value = s_pct
	_sfx_val_label.text = "%d%%" % s_pct


func _on_music_slider_changed(value: float) -> void:
	var norm: float = value / 100.0
	_music_val_label.text = "%d%%" % int(value)
	SaveManager.save_settings(norm, SaveManager.sfx_volume)


func _on_sfx_slider_changed(value: float) -> void:
	var norm: float = value / 100.0
	_sfx_val_label.text = "%d%%" % int(value)
	SaveManager.save_settings(SaveManager.music_volume, norm)
	AudioManager.play_sfx("shoot", 0.05)
