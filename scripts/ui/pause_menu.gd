class_name PauseMenu
extends CanvasLayer
## Menu Pause In-Game: Menghentikan game, mengatur volume BGM/SFX, restart, dan kembali ke menu utama.

signal resumed

@onready var _root_control: Control = $RootControl
@onready var _btn_resume: Button = $RootControl/Card/VBox/BtnResume
@onready var _btn_restart: Button = $RootControl/Card/VBox/BtnRestart
@onready var _btn_menu: Button = $RootControl/Card/VBox/BtnMenu

@onready var _music_slider: HSlider = $RootControl/Card/VBox/AudioBox/MusicSlider
@onready var _music_val_label: Label = $RootControl/Card/VBox/AudioBox/MusicRow/MusicValLabel
@onready var _sfx_slider: HSlider = $RootControl/Card/VBox/AudioBox/SfxSlider
@onready var _sfx_val_label: Label = $RootControl/Card/VBox/AudioBox/SfxRow/SfxValLabel

var is_paused: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_root_control.visible = false
	
	_btn_resume.pressed.connect(resume_game)
	_btn_restart.pressed.connect(_on_restart_pressed)
	_btn_menu.pressed.connect(_on_menu_pressed)
	
	_music_slider.value_changed.connect(_on_music_slider_changed)
	_sfx_slider.value_changed.connect(_on_sfx_slider_changed)
	
	# Muat nilai slider dari SaveManager
	_sync_audio_sliders()


func _sync_audio_sliders() -> void:
	var m_pct: int = roundi(SaveManager.music_volume * 100.0)
	var s_pct: int = roundi(SaveManager.sfx_volume * 100.0)
	_music_slider.value = m_pct
	_music_val_label.text = "%d%%" % m_pct
	_sfx_slider.value = s_pct
	_sfx_val_label.text = "%d%%" % s_pct


func toggle_pause() -> void:
	if is_paused:
		resume_game()
	else:
		pause_game()


func pause_game() -> void:
	if is_paused:
		return
	is_paused = true
	get_tree().paused = true
	_sync_audio_sliders()
	_root_control.visible = true
	_btn_resume.grab_focus()
	AudioManager.play_sfx("pickup", 0.02)


func resume_game() -> void:
	if not is_paused:
		return
	is_paused = false
	get_tree().paused = false
	_root_control.visible = false
	AudioManager.play_sfx("pickup", 0.02)
	resumed.emit()


func _on_restart_pressed() -> void:
	is_paused = false
	get_tree().paused = false
	_root_control.visible = false
	GameState.new_game(GameState.difficulty)
	SceneRouter.go_to("res://scenes/levels/test_level.tscn")


func _on_menu_pressed() -> void:
	is_paused = false
	get_tree().paused = false
	_root_control.visible = false
	SceneRouter.go_to("res://scenes/ui/main_menu.tscn")


func _on_music_slider_changed(value: float) -> void:
	var norm: float = value / 100.0
	_music_val_label.text = "%d%%" % int(value)
	SaveManager.save_settings(norm, SaveManager.sfx_volume)


func _on_sfx_slider_changed(value: float) -> void:
	var norm: float = value / 100.0
	_sfx_val_label.text = "%d%%" % int(value)
	SaveManager.save_settings(SaveManager.music_volume, norm)
	AudioManager.play_sfx("shoot", 0.05)
