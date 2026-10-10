extends Node
## Pengelola Audio & SFX terpusat.
## Mendukung pemuatan file eksternal (.ogg, .wav) dari assets/audio/
## dengan fallback otomatis ke audio sintetis prosedural jika file belum ada.

const SFX_POOL_SIZE: int = 12
const MIX_RATE: int = 22050

const SFX_FILES: Dictionary = {
	"shoot": [
		"res://assets/audio/sfx/laser.ogg",
		"res://assets/audio/sfx/laser.wav",
		"res://assets/audio/sfx/shoot.ogg",
		"res://assets/audio/sfx/shoot.wav"
	],
	"missile": [
		"res://assets/audio/sfx/missile.ogg",
		"res://assets/audio/sfx/missile.wav"
	],
	"enemy_shoot": [
		"res://assets/audio/sfx/enemy_laser.ogg",
		"res://assets/audio/sfx/enemy_laser.wav"
	],
	"hit": [
		"res://assets/audio/sfx/hit.ogg",
		"res://assets/audio/sfx/hit.wav"
	],
	"explosion": [
		"res://assets/audio/sfx/explosion.ogg",
		"res://assets/audio/sfx/explosion.wav"
	],
	"carrier_explosion": [
		"res://assets/audio/sfx/big_explosion.ogg",
		"res://assets/audio/sfx/big_explosion.wav"
	],
	"star": [
		"res://assets/audio/sfx/star.ogg",
		"res://assets/audio/sfx/star.wav"
	],
	"pickup": [
		"res://assets/audio/sfx/pickup.ogg",
		"res://assets/audio/sfx/pickup.wav"
	],
	"shield_break": [
		"res://assets/audio/sfx/shield_break.ogg",
		"res://assets/audio/sfx/shield_break.wav"
	],
	"splash": [
		"res://assets/audio/sfx/splash.ogg",
		"res://assets/audio/sfx/splash.wav"
	],
	"checkpoint": [
		"res://assets/audio/sfx/checkpoint.ogg",
		"res://assets/audio/sfx/checkpoint.wav"
	],
	"level_clear": [
		"res://assets/audio/sfx/level_clear.ogg",
		"res://assets/audio/sfx/level_clear.wav"
	],
	"game_over": [
		"res://assets/audio/sfx/game_over.ogg",
		"res://assets/audio/sfx/game_over.wav"
	]
}

const MUSIC_FILES: Dictionary = {
	"level_1": [
		"res://assets/audio/music/bgm_level_1.ogg",
		"res://assets/audio/music/bgm_level_1.wav",
		"res://assets/audio/music/level_1.ogg"
	],
	"menu": [
		"res://assets/audio/music/bgm_menu.ogg",
		"res://assets/audio/music/menu.ogg"
	]
}

var master_volume: float = 1.0
var sfx_volume: float = 1.0
var music_volume: float = 0.8

var _sfx_players: Array[AudioStreamPlayer] = []
var _music_player: AudioStreamPlayer
var _procedural_sfx: Dictionary = {}
var _procedural_music: Dictionary = {}
var _loaded_streams: Dictionary = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Siapkan pool player untuk SFX
	for i in SFX_POOL_SIZE:
		var p := AudioStreamPlayer.new()
		p.bus = "Master"
		add_child(p)
		_sfx_players.append(p)

	# Siapkan player untuk Music
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = "Master"
	add_child(_music_player)

	# Bangun bank suara sintetis prosedural awal
	_build_procedural_library()


## Mainkan SFX dengan prioritas: File disk -> Fallback Sintetis
func play_sfx(sfx_name: String, pitch_range: float = 0.06, volume_db: float = 0.0) -> void:
	var stream: AudioStream = _get_or_load_sfx(sfx_name)
	if stream == null:
		return

	var player: AudioStreamPlayer = _get_available_sfx_player()
	player.stream = stream
	player.volume_db = volume_db + linear_to_db(sfx_volume * master_volume)
	player.pitch_scale = randf_range(1.0 - pitch_range, 1.0 + pitch_range)
	player.play()


## Mainkan Musik BGM dengan loop
func play_music(track_name: String, volume_db: float = -4.0) -> void:
	var stream: AudioStream = _get_or_load_music(track_name)
	if stream == null:
		return

	if _music_player.stream == stream and _music_player.is_playing():
		return

	_music_player.stream = stream
	_music_player.volume_db = volume_db + linear_to_db(music_volume * master_volume)
	_music_player.play()


func stop_music() -> void:
	if _music_player:
		_music_player.stop()


func _get_available_sfx_player() -> AudioStreamPlayer:
	for p in _sfx_players:
		if not p.is_playing():
			return p
	# Jika semua sedang berbunyi, curi player pertama
	return _sfx_players[0]


func _get_or_load_sfx(sfx_name: String) -> AudioStream:
	if _loaded_streams.has(sfx_name):
		return _loaded_streams[sfx_name]

	# Cek apakah ada file audio fisik di folder assets/
	if SFX_FILES.has(sfx_name):
		for path in SFX_FILES[sfx_name]:
			if ResourceLoader.exists(path):
				var loaded = load(path) as AudioStream
				if loaded != null:
					_loaded_streams[sfx_name] = loaded
					return loaded

	# Fallback ke generator sintetis
	return _procedural_sfx.get(sfx_name, null)


func _get_or_load_music(track_name: String) -> AudioStream:
	if _loaded_streams.has("music_" + track_name):
		return _loaded_streams["music_" + track_name]

	if MUSIC_FILES.has(track_name):
		for path in MUSIC_FILES[track_name]:
			if ResourceLoader.exists(path):
				var loaded = load(path) as AudioStream
				if loaded != null:
					_loaded_streams["music_" + track_name] = loaded
					return loaded

	return _procedural_music.get(track_name, null)


# --- SYNTHESIZER SFX PROSEDURAL ---

func _build_procedural_library() -> void:
	# 1. Pip Shoot (Pew!)
	_procedural_sfx["shoot"] = _synth_sweep(0.08, 920.0, 260.0, "square", 0.6)

	# 2. Missile Launch (Whoosh bass)
	_procedural_sfx["missile"] = _synth_missile(0.24)

	# 3. Enemy Shoot (Pulse zap)
	_procedural_sfx["enemy_shoot"] = _synth_sweep(0.10, 480.0, 180.0, "triangle", 0.7)

	# 4. Bullet Hit (Sharp click)
	_procedural_sfx["hit"] = _synth_sweep(0.035, 1400.0, 350.0, "sine", 0.5)

	# 5. Explosion (Kaboom rumble)
	_procedural_sfx["explosion"] = _synth_explosion(0.32, 90.0, 0.85)

	# 6. Carrier Big Explosion (Heavy sub-bass rumble)
	_procedural_sfx["carrier_explosion"] = _synth_explosion(0.55, 65.0, 1.0)

	# 7. Star Collect (Sweet high bell chime)
	_procedural_sfx["star"] = _synth_sweep(0.12, 1046.0, 1318.0, "sine", 0.65)

	# 8. Power-up / Item Pickup (Happy ascending arpeggio C5 -> E5 -> G5)
	_procedural_sfx["pickup"] = _synth_arpeggio([523.25, 659.25, 783.99], 0.07, 0.8)

	# 9. Shield Break (Metallic wobble shatter)
	_procedural_sfx["shield_break"] = _synth_shield_break(0.28)

	# 10. Starsplash Bomb (Massive cosmic whoosh blast)
	_procedural_sfx["splash"] = _synth_splash(0.52)

	# 11. Checkpoint Fanfare (D5 -> A5 fanfare)
	_procedural_sfx["checkpoint"] = _synth_arpeggio([587.33, 880.0], 0.16, 0.85)

	# 12. Level Clear (Victory jingle C5 -> E5 -> G5 -> C6)
	_procedural_sfx["level_clear"] = _synth_arpeggio([523.25, 659.25, 783.99, 1046.50], 0.14, 0.9)

	# 13. Game Over (Sad downward slide)
	_procedural_sfx["game_over"] = _synth_sweep(0.48, 380.0, 85.0, "saw", 0.75)

	# 14. Level 1 Ambient Loop (Laut Beku Drone)
	_procedural_music["level_1"] = _synth_ice_ambient(4.0)


func _create_stream(data: PackedByteArray) -> AudioStreamWAV:
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = MIX_RATE
	stream.stereo = false
	stream.data = data
	return stream


func _synth_sweep(duration: float, start_f: float, end_f: float, wave_type: String = "sine", gain: float = 0.7) -> AudioStreamWAV:
	var num_samples: int = int(MIX_RATE * duration)
	var bytes := PackedByteArray()
	bytes.resize(num_samples * 2)

	var phase: float = 0.0
	for i in num_samples:
		var t: float = float(i) / float(MIX_RATE)
		var progress: float = t / duration
		var freq: float = lerpf(start_f, end_f, progress)
		phase += freq * TAU / float(MIX_RATE)

		var wave: float = 0.0
		match wave_type:
			"sine":
				wave = sin(phase)
			"square":
				wave = 1.0 if sin(phase) >= 0.0 else -1.0
			"triangle":
				wave = asin(sin(phase)) * (2.0 / PI)
			"saw":
				wave = fmod(phase / PI, 2.0) - 1.0

		var envelope: float = (1.0 - progress) * gain
		var sample: int = clampi(int(wave * envelope * 32000.0), -32767, 32767)
		bytes.encode_s16(i * 2, sample)

	return _create_stream(bytes)


func _synth_missile(duration: float) -> AudioStreamWAV:
	var num_samples: int = int(MIX_RATE * duration)
	var bytes := PackedByteArray()
	bytes.resize(num_samples * 2)

	var phase: float = 0.0
	for i in num_samples:
		var t: float = float(i) / float(MIX_RATE)
		var progress: float = t / duration
		var freq: float = lerpf(140.0, 420.0, progress)
		phase += freq * TAU / float(MIX_RATE)

		var noise: float = randf_range(-1.0, 1.0) * 0.45
		var tone: float = sin(phase) * 0.55
		var envelope: float = (1.0 - progress) * 0.75
		var sample: int = clampi(int((tone + noise) * envelope * 32000.0), -32767, 32767)
		bytes.encode_s16(i * 2, sample)

	return _create_stream(bytes)


func _synth_explosion(duration: float, sub_freq: float = 80.0, gain: float = 0.85) -> AudioStreamWAV:
	var num_samples: int = int(MIX_RATE * duration)
	var bytes := PackedByteArray()
	bytes.resize(num_samples * 2)

	var phase: float = 0.0
	var low_pass: float = 0.0
	for i in num_samples:
		var t: float = float(i) / float(MIX_RATE)
		var progress: float = t / duration
		phase += sub_freq * TAU / float(MIX_RATE)

		var raw_noise: float = randf_range(-1.0, 1.0)
		low_pass = lerpf(low_pass, raw_noise, 0.18) # smoothing low-pass filter

		var sub_bass: float = sin(phase) * (1.0 - progress)
		var envelope: float = exp(-progress * 4.5) * gain
		var sample: int = clampi(int((low_pass * 0.75 + sub_bass * 0.45) * envelope * 32000.0), -32767, 32767)
		bytes.encode_s16(i * 2, sample)

	return _create_stream(bytes)


func _synth_arpeggio(freqs: Array[float], note_dur: float, gain: float = 0.8) -> AudioStreamWAV:
	var total_dur: float = float(freqs.size()) * note_dur
	var num_samples: int = int(MIX_RATE * total_dur)
	var bytes := PackedByteArray()
	bytes.resize(num_samples * 2)

	var phase: float = 0.0
	for i in num_samples:
		var t: float = float(i) / float(MIX_RATE)
		var note_idx: int = mini(int(t / note_dur), freqs.size() - 1)
		var freq: float = freqs[note_idx]
		phase += freq * TAU / float(MIX_RATE)

		var note_progress: float = fmod(t, note_dur) / note_dur
		var envelope: float = (1.0 - note_progress * 0.7) * gain
		var sample: int = clampi(int(sin(phase) * envelope * 32000.0), -32767, 32767)
		bytes.encode_s16(i * 2, sample)

	return _create_stream(bytes)


func _synth_shield_break(duration: float) -> AudioStreamWAV:
	var num_samples: int = int(MIX_RATE * duration)
	var bytes := PackedByteArray()
	bytes.resize(num_samples * 2)

	var phase: float = 0.0
	for i in num_samples:
		var t: float = float(i) / float(MIX_RATE)
		var progress: float = t / duration
		var mod_freq: float = 680.0 + sin(t * 40.0) * 180.0
		phase += mod_freq * TAU / float(MIX_RATE)

		var envelope: float = (1.0 - progress) * 0.75
		var sample: int = clampi(int(sin(phase) * envelope * 32000.0), -32767, 32767)
		bytes.encode_s16(i * 2, sample)

	return _create_stream(bytes)


func _synth_splash(duration: float) -> AudioStreamWAV:
	var num_samples: int = int(MIX_RATE * duration)
	var bytes := PackedByteArray()
	bytes.resize(num_samples * 2)

	var phase: float = 0.0
	for i in num_samples:
		var t: float = float(i) / float(MIX_RATE)
		var progress: float = t / duration
		var freq: float = 160.0 + sin(progress * PI) * 850.0
		phase += freq * TAU / float(MIX_RATE)

		var noise: float = randf_range(-1.0, 1.0) * progress * 0.4
		var tone: float = sin(phase) * (1.0 - progress * 0.4)
		var envelope: float = (1.0 - progress) * 0.9
		var sample: int = clampi(int((tone + noise) * envelope * 32000.0), -32767, 32767)
		bytes.encode_s16(i * 2, sample)

	return _create_stream(bytes)


func _synth_ice_ambient(duration: float = 4.0) -> AudioStreamWAV:
	var num_samples: int = int(MIX_RATE * duration)
	var bytes := PackedByteArray()
	bytes.resize(num_samples * 2)

	var p1: float = 0.0
	var p2: float = 0.0
	for i in num_samples:
		var t: float = float(i) / float(MIX_RATE)
		p1 += 110.0 * TAU / float(MIX_RATE) # A2 drone
		p2 += 330.0 * TAU / float(MIX_RATE) # E4 gentle fifth

		var s1: float = sin(p1) * 0.4
		var s2: float = sin(p2) * 0.25 * (0.6 + sin(t * 1.5) * 0.4)
		var noise: float = randf_range(-0.06, 0.06) # soft wind
		var sample: int = clampi(int((s1 + s2 + noise) * 0.45 * 32000.0), -32767, 32767)
		bytes.encode_s16(i * 2, sample)

	var stream := _create_stream(bytes)
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = num_samples
	return stream
