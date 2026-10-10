class_name LevelRunner
extends Node
## Mengatur timeline kemunculan musuh, formasi, banner teks, checkpoint, dan penyelesaian level.

signal banner_requested(text: String, duration: float)
signal progress_updated(progress_ratio: float, current_time: float, total_time: float)
signal checkpoint_reached(checkpoint_id: int, name: String)
signal boss_spawned(boss_node: Node2D, boss_name: String)
signal level_completed(stats: Dictionary)

enum EventType {
	SPAWN,       # Munculkan 1 musuh
	FORMATION,   # Munculkan formasi sekumpulan musuh (LINE, V, WALL, SWARM_SINE)
	BANNER,      # Tampilkan teks banner di layar
	CHECKPOINT,  # Catat checkpoint tengah level
	BOSS,        # Munculkan boss pertempuran utama
	WAIT_CLEAR   # Tunggu sampai semua musuh di layar musnah sebelum tamat
}

@export var spawn_x: float = 2050.0

var events: Array[Dictionary] = []
var elapsed_time: float = 0.0
var total_duration: float = 140.0
var is_running: bool = false
var is_waiting_clear: bool = false
var is_completed: bool = false

var last_checkpoint_id: int = 0
var last_checkpoint_time: float = 0.0
var last_checkpoint_name: String = ""

var _current_event_idx: int = 0
var _enemies_container: Node2D
var _delayed_spawns: Array[Dictionary] = []


func _ready() -> void:
	pass


func setup(container: Node2D, timeline_events: Array[Dictionary], duration: float = 0.0) -> void:
	_enemies_container = container
	events = timeline_events
	if duration > 0.0:
		total_duration = duration
	elif not events.is_empty():
		total_duration = events.back().get("time", 136.0)
	else:
		total_duration = 136.0
	elapsed_time = 0.0
	_current_event_idx = 0
	_delayed_spawns.clear()
	is_waiting_clear = false
	is_completed = false
	is_running = true


func start() -> void:
	is_running = true


func pause() -> void:
	is_running = false


func restart_from_checkpoint() -> void:
	if last_checkpoint_id <= 0:
		restart_from_beginning()
		return

	# Bersihkan sisa peluru dan musuh di layar
	_clear_active_threats()

	# Kembalikan waktu ke checkpoint
	elapsed_time = last_checkpoint_time
	_delayed_spawns.clear()
	is_waiting_clear = false
	is_completed = false

	# Cari indeks event pertama setelah checkpoint
	_current_event_idx = 0
	while _current_event_idx < events.size():
		var ev: Dictionary = events[_current_event_idx]
		if ev["time"] > last_checkpoint_time:
			break
		_current_event_idx += 1

	is_running = true
	banner_requested.emit("RESPAWN: %s" % last_checkpoint_name, 2.5)


func restart_from_beginning() -> void:
	_clear_active_threats()
	elapsed_time = 0.0
	_current_event_idx = 0
	_delayed_spawns.clear()
	is_waiting_clear = false
	is_completed = false
	is_running = true


func _process(delta: float) -> void:
	if not is_running or is_completed:
		return

	elapsed_time += delta
	_process_delayed_spawns(delta)
	_process_timeline_events()

	var ratio: float = clampf(elapsed_time / maxf(total_duration, 1.0), 0.0, 1.0)
	progress_updated.emit(ratio, elapsed_time, total_duration)

	# Jika semua event telah diproses dan menunggu layar bersih
	if is_waiting_clear:
		var remaining_enemies: int = _enemies_container.get_child_count() if _enemies_container != null else 0
		if remaining_enemies == 0 and _delayed_spawns.is_empty():
			_finish_level()


func _process_timeline_events() -> void:
	while _current_event_idx < events.size():
		var ev: Dictionary = events[_current_event_idx]
		if elapsed_time < ev["time"]:
			break

		_execute_event(ev)
		_current_event_idx += 1


func _execute_event(ev: Dictionary) -> void:
	match ev["type"]:
		EventType.SPAWN:
			_spawn_enemy(ev["scene"], ev.get("y", 540.0), ev.get("params", {}))

		EventType.FORMATION:
			_spawn_formation(ev)

		EventType.BANNER:
			banner_requested.emit(ev["text"], ev.get("duration", 2.5))

		EventType.CHECKPOINT:
			last_checkpoint_id = ev["id"]
			last_checkpoint_time = elapsed_time
			last_checkpoint_name = ev.get("name", "Checkpoint %d" % last_checkpoint_id)
			checkpoint_reached.emit(last_checkpoint_id, last_checkpoint_name)
			banner_requested.emit("CHECKPOINT: %s" % last_checkpoint_name, 3.0)

		EventType.BOSS:
			_spawn_boss(ev)

		EventType.WAIT_CLEAR:
			is_waiting_clear = true


func _spawn_boss(ev: Dictionary) -> void:
	if _enemies_container == null or ev.get("scene") == null:
		return
	var boss = ev["scene"].instantiate() as Node2D
	boss.position = Vector2(2150.0, ev.get("y", 540.0))
	_enemies_container.add_child(boss)
	var boss_name: String = ev.get("name", "BOSS")
	boss_spawned.emit(boss, boss_name)
	banner_requested.emit("PERINGATAN: %s TERDETEKSI!" % boss_name, 3.5)


func _spawn_enemy(scene: PackedScene, y_pos: float, params: Dictionary = {}, x_offset: float = 0.0) -> void:
	if _enemies_container == null or scene == null:
		return
	var enemy: Enemy = scene.instantiate() as Enemy
	enemy.position = Vector2(spawn_x + x_offset, y_pos)

	# Terapkan modifikasi opsional
	if params.has("speed"):
		enemy.speed = params["speed"]
	if params.has("max_hp"):
		enemy.max_hp = params["max_hp"]
	if params.has("sine_amplitude"):
		enemy.sine_amplitude = params["sine_amplitude"]

	_enemies_container.add_child(enemy)


func _spawn_formation(ev: Dictionary) -> void:
	var formation: String = ev.get("formation", "LINE")
	var scene: PackedScene = ev["scene"]
	var base_y: float = ev.get("y", 540.0)
	var count: int = ev.get("count", 3)

	match formation:
		"LINE":
			# Berurutan dengan interval waktu
			for i in count:
				if i == 0:
					_spawn_enemy(scene, base_y)
				else:
					_delayed_spawns.append({
						"delay": float(i) * 0.35,
						"scene": scene,
						"y": base_y,
						"params": ev.get("params", {})
					})

		"V":
			# Pola huruf V menghadap ke kiri
			# 0 = puncak depan, 1,2 = sayap atas/bawah, 3,4 = sayap terluar
			_spawn_enemy(scene, base_y, ev.get("params", {}), 0.0)
			if count >= 3:
				_spawn_enemy(scene, base_y - 80.0, ev.get("params", {}), 90.0)
				_spawn_enemy(scene, base_y + 80.0, ev.get("params", {}), 90.0)
			if count >= 5:
				_spawn_enemy(scene, base_y - 160.0, ev.get("params", {}), 180.0)
				_spawn_enemy(scene, base_y + 160.0, ev.get("params", {}), 180.0)

		"WALL":
			# Garis vertikal bersamaan
			var spacing: float = 240.0
			var start_y: float = base_y - (float(count - 1) * spacing * 0.5)
			for i in count:
				_spawn_enemy(scene, start_y + float(i) * spacing, ev.get("params", {}))

		"SWARM_SINE":
			# Sepasang sine dengan fase atas dan bawah
			_spawn_enemy(scene, base_y - 140.0, ev.get("params", {}))
			_spawn_enemy(scene, base_y + 140.0, ev.get("params", {}))


func _process_delayed_spawns(delta: float) -> void:
	var i: int = _delayed_spawns.size() - 1
	while i >= 0:
		_delayed_spawns[i]["delay"] -= delta
		if _delayed_spawns[i]["delay"] <= 0.0:
			var item: Dictionary = _delayed_spawns[i]
			_delayed_spawns.remove_at(i)
			_spawn_enemy(item["scene"], item["y"], item.get("params", {}))
		i -= 1


func _clear_active_threats() -> void:
	if _enemies_container != null:
		for child in _enemies_container.get_children():
			child.queue_free()
	for bullet in get_tree().get_nodes_in_group("enemy_bullet"):
		bullet.queue_free()


func _finish_level() -> void:
	is_completed = true
	is_running = false
	elapsed_time = total_duration
	progress_updated.emit(1.0, total_duration, total_duration)
	var bonus_lives: int = GameState.lives * 1000
	var final_score: int = GameState.score + bonus_lives
	var stats: Dictionary = {
		"base_score": GameState.score,
		"lives_remaining": GameState.lives,
		"life_bonus": bonus_lives,
		"final_score": final_score
	}
	level_completed.emit(stats)
