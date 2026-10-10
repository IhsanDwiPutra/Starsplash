class_name Level1Data
extends RefCounted
## Timeline gelombang musuh untuk Level 1: Laut Beku.
## Durasi target: ~140 detik (2.3 menit), Checkpoint di detik 70.

static func get_timeline(scenes: Dictionary) -> Array[Dictionary]:
	var drone: PackedScene = scenes["drone"]
	var sine: PackedScene = scenes["sine"]
	var shooter: PackedScene = scenes["shooter"]
	var carrier: PackedScene = scenes["carrier"]

	var E = LevelRunner.EventType

	return [
		# --- SEKTOR 1: PEMBUKA & PENGENALAN (0s - 25s) ---
		{ "time": 0.0, "type": E.BANNER, "text": "LAUT BEKU: SEKTOR 1", "duration": 3.0 },
		{ "time": 2.0, "type": E.SPAWN, "scene": drone, "y": 420.0 },
		{ "time": 4.5, "type": E.SPAWN, "scene": drone, "y": 680.0 },
		{ "time": 7.0, "type": E.FORMATION, "formation": "LINE", "scene": drone, "y": 540.0, "count": 3 },
		{ "time": 11.0, "type": E.BANNER, "text": "WAVE 2: GELOMBANG SINE", "duration": 2.2 },
		{ "time": 13.0, "type": E.SPAWN, "scene": sine, "y": 380.0 },
		{ "time": 15.5, "type": E.SPAWN, "scene": sine, "y": 700.0 },
		{ "time": 18.5, "type": E.FORMATION, "formation": "SWARM_SINE", "scene": sine, "y": 540.0, "count": 2 },
		
		# --- SEKTOR 2: CARRIER PERTAMA & UPGRADE (25s - 45s) ---
		{ "time": 24.0, "type": E.BANNER, "text": "CARRIER EMAS TERDETEKSI! AMBIL [P]", "duration": 3.0 },
		{ "time": 26.0, "type": E.SPAWN, "scene": carrier, "y": 540.0 },
		{ "time": 27.5, "type": E.SPAWN, "scene": drone, "y": 360.0 },
		{ "time": 27.5, "type": E.SPAWN, "scene": drone, "y": 720.0 },
		{ "time": 33.0, "type": E.BANNER, "text": "WAVE 3: SERBUAN FORMASI V", "duration": 2.2 },
		{ "time": 35.0, "type": E.FORMATION, "formation": "V", "scene": drone, "y": 540.0, "count": 5 },
		{ "time": 40.0, "type": E.FORMATION, "formation": "LINE", "scene": drone, "y": 320.0, "count": 3 },

		# --- SEKTOR 3: PENEMBAK & ANCAMAN PELURU (45s - 68s) ---
		{ "time": 45.0, "type": E.BANNER, "text": "WAVE 4: WASPADAI PENEMBAK!", "duration": 2.5 },
		{ "time": 47.0, "type": E.SPAWN, "scene": shooter, "y": 400.0 },
		{ "time": 50.0, "type": E.SPAWN, "scene": sine, "y": 750.0 },
		{ "time": 54.0, "type": E.SPAWN, "scene": shooter, "y": 680.0 },
		{ "time": 56.0, "type": E.FORMATION, "formation": "LINE", "scene": drone, "y": 420.0, "count": 3 },
		{ "time": 61.0, "type": E.FORMATION, "formation": "WALL", "scene": drone, "y": 540.0, "count": 3 },
		{ "time": 64.0, "type": E.FORMATION, "formation": "SWARM_SINE", "scene": sine, "y": 540.0, "count": 2 },

		# --- SEKTOR 4: CHECKPOINT 1 (50% LEVEL) ---
		{ "time": 69.0, "type": E.CHECKPOINT, "id": 1, "name": "Bongkahan Es Tengah" },
		{ "time": 71.5, "type": E.SPAWN, "scene": carrier, "y": 480.0 },
		{ "time": 73.0, "type": E.SPAWN, "scene": drone, "y": 280.0 },
		{ "time": 73.0, "type": E.SPAWN, "scene": drone, "y": 800.0 },

		# --- SEKTOR 5: PENJAGA SELAT BEKU (78s - 105s) ---
		{ "time": 78.0, "type": E.BANNER, "text": "WAVE 5: PENJAGA SELAT BEKU", "duration": 2.5 },
		{ "time": 80.0, "type": E.SPAWN, "scene": shooter, "y": 520.0 },
		{ "time": 82.5, "type": E.FORMATION, "formation": "LINE", "scene": drone, "y": 300.0, "count": 3 },
		{ "time": 87.0, "type": E.FORMATION, "formation": "SWARM_SINE", "scene": sine, "y": 540.0, "count": 2 },
		{ "time": 90.0, "type": E.FORMATION, "formation": "V", "scene": drone, "y": 640.0, "count": 5 },
		{ "time": 95.0, "type": E.BANNER, "text": "WAVE 6: DUAL SHOOTER SQUAD!", "duration": 2.5 },
		{ "time": 97.0, "type": E.SPAWN, "scene": shooter, "y": 320.0 },
		{ "time": 98.5, "type": E.SPAWN, "scene": shooter, "y": 760.0 },
		{ "time": 102.0, "type": E.FORMATION, "formation": "LINE", "scene": drone, "y": 540.0, "count": 4 },

		# --- SEKTOR 6: CARRIER FINAL & SERANGAN KLIMAKS (105s - 135s) ---
		{ "time": 108.0, "type": E.BANNER, "text": "CARRIER TERAKHIR: PERSIAPAN TEMPUR!", "duration": 2.5 },
		{ "time": 110.0, "type": E.SPAWN, "scene": carrier, "y": 540.0 },
		{ "time": 112.0, "type": E.FORMATION, "formation": "WALL", "scene": drone, "y": 540.0, "count": 3 },
		{ "time": 116.0, "type": E.BANNER, "text": "WAVE 7: GELOMBANG AKHIR LAUT BEKU!", "duration": 2.8 },
		{ "time": 118.0, "type": E.SPAWN, "scene": shooter, "y": 540.0 },
		{ "time": 120.0, "type": E.FORMATION, "formation": "SWARM_SINE", "scene": sine, "y": 540.0, "count": 2 },
		{ "time": 123.0, "type": E.FORMATION, "formation": "V", "scene": drone, "y": 540.0, "count": 5 },
		{ "time": 128.0, "type": E.FORMATION, "formation": "LINE", "scene": drone, "y": 380.0, "count": 4 },
		{ "time": 129.5, "type": E.FORMATION, "formation": "LINE", "scene": drone, "y": 700.0, "count": 4 },

		# --- SEKTOR 7: PEMBERSIHAN & KEMENANGAN (135s+) ---
		{ "time": 134.0, "type": E.BANNER, "text": "BERSIHKAN SEMUA SISA MUSUH!", "duration": 3.0 },
		{ "time": 136.0, "type": E.WAIT_CLEAR }
	]
