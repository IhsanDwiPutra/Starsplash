class_name Level1Data
extends RefCounted
## Timeline gelombang musuh Dunia 1: Laut Beku (Stage 1-1 s/d Stage 1-6).

const STAGE_NAMES: Dictionary = {
	1: "Pesisir Es",
	2: "Selat Gunung Es",
	3: "Benteng Es",
	4: "Badai Salju Malam",
	5: "Palung Laut Dalam",
	6: "Tahta Inti Gloop"
}


static func get_stage_name(stage_num: int) -> String:
	return STAGE_NAMES.get(stage_num, "Laut Beku")


static func get_timeline(scenes: Dictionary) -> Array[Dictionary]:
	return get_stage_timeline(GameState.current_stage, scenes)


static func get_stage_timeline(stage_num: int, scenes: Dictionary) -> Array[Dictionary]:
	var drone: PackedScene = scenes.get("drone")
	var sine: PackedScene = scenes.get("sine")
	var shooter: PackedScene = scenes.get("shooter")
	var carrier: PackedScene = scenes.get("carrier")
	var boss: PackedScene = scenes.get("boss")
	var mini_boss: PackedScene = scenes.get("mini_boss", boss)

	var E = LevelRunner.EventType

	match stage_num:
		1:
			# === STAGE 1-1: PESISIR ES (Pengenalan Frost Jelly & Carrier Harta) ===
			return [
				{ "time": 0.0, "type": E.BANNER, "text": "STAGE 1-1: PESISIR ES", "duration": 2.8 },
				{ "time": 2.0, "type": E.SPAWN, "scene": drone, "y": 440.0 },
				{ "time": 4.5, "type": E.SPAWN, "scene": drone, "y": 640.0 },
				{ "time": 7.0, "type": E.FORMATION, "formation": "LINE", "scene": drone, "y": 540.0, "count": 3 },
				{ "time": 12.0, "type": E.BANNER, "text": "CARRIER EMAS TERDETEKSI! AMBIL [P]", "duration": 2.5 },
				{ "time": 14.0, "type": E.SPAWN, "scene": carrier, "y": 540.0 },
				{ "time": 15.5, "type": E.SPAWN, "scene": drone, "y": 360.0 },
				{ "time": 15.5, "type": E.SPAWN, "scene": drone, "y": 720.0 },
				{ "time": 20.0, "type": E.BANNER, "text": "WAVE 2: FORMASI V FROST JELLY", "duration": 2.2 },
				{ "time": 22.0, "type": E.FORMATION, "formation": "V", "scene": drone, "y": 540.0, "count": 5 },
				{ "time": 27.0, "type": E.FORMATION, "formation": "LINE", "scene": drone, "y": 340.0, "count": 3 },
				{ "time": 28.5, "type": E.FORMATION, "formation": "LINE", "scene": drone, "y": 740.0, "count": 3 },
				{ "time": 33.0, "type": E.WAIT_CLEAR }
			]

		2:
			# === STAGE 1-2: SELAT GUNUNG ES (Gelombang Sinus & Penembak Pertama) ===
			return [
				{ "time": 0.0, "type": E.BANNER, "text": "STAGE 1-2: SELAT GUNUNG ES", "duration": 2.8 },
				{ "time": 2.0, "type": E.SPAWN, "scene": sine, "y": 420.0 },
				{ "time": 4.5, "type": E.SPAWN, "scene": sine, "y": 660.0 },
				{ "time": 7.5, "type": E.FORMATION, "formation": "SWARM_SINE", "scene": sine, "y": 540.0, "count": 2 },
				{ "time": 12.0, "type": E.BANNER, "text": "WAVE 2: WASPADAI PENEMBAK ES!", "duration": 2.5 },
				{ "time": 14.0, "type": E.SPAWN, "scene": shooter, "y": 420.0 },
				{ "time": 17.0, "type": E.FORMATION, "formation": "LINE", "scene": drone, "y": 600.0, "count": 3 },
				{ "time": 22.0, "type": E.SPAWN, "scene": carrier, "y": 480.0 },
				{ "time": 25.0, "type": E.FORMATION, "formation": "V", "scene": drone, "y": 540.0, "count": 5 },
				{ "time": 30.0, "type": E.SPAWN, "scene": shooter, "y": 680.0 },
				{ "time": 32.5, "type": E.FORMATION, "formation": "SWARM_SINE", "scene": sine, "y": 400.0, "count": 2 },
				{ "time": 37.0, "type": E.FORMATION, "formation": "WALL", "scene": drone, "y": 540.0, "count": 3 },
				{ "time": 42.0, "type": E.WAIT_CLEAR }
			]

		3:
			# === STAGE 1-3: BENTENG ES (Klimaks Paruh Pertama: Pertahanan Intensif & Sub-Boss) ===
			return [
				{ "time": 0.0, "type": E.BANNER, "text": "STAGE 1-3: BENTENG ES TERAPUNG", "duration": 2.8 },
				{ "time": 2.0, "type": E.FORMATION, "formation": "WALL", "scene": drone, "y": 540.0, "count": 3 },
				{ "time": 6.0, "type": E.SPAWN, "scene": shooter, "y": 380.0 },
				{ "time": 9.0, "type": E.FORMATION, "formation": "V", "scene": drone, "y": 640.0, "count": 5 },
				{ "time": 14.0, "type": E.BANNER, "text": "WAVE 2: DUAL SHOOTER SQUAD!", "duration": 2.5 },
				{ "time": 16.0, "type": E.SPAWN, "scene": shooter, "y": 320.0 },
				{ "time": 17.5, "type": E.SPAWN, "scene": shooter, "y": 760.0 },
				{ "time": 20.0, "type": E.SPAWN, "scene": carrier, "y": 540.0 },
				{ "time": 24.0, "type": E.FORMATION, "formation": "SWARM_SINE", "scene": sine, "y": 540.0, "count": 3 },
				{ "time": 28.0, "type": E.FORMATION, "formation": "WALL", "scene": drone, "y": 540.0, "count": 3 },
				{ "time": 32.0, "type": E.BANNER, "text": "PERINGATAN: MINI-BOSS MECHA NARWHAL MENDEKAT!", "duration": 2.8 },
				{ "time": 35.0, "type": E.BOSS, "scene": mini_boss, "name": "MECHA NARWHAL" },
				{ "time": 35.5, "type": E.WAIT_CLEAR }
			]

		4:
			# === STAGE 1-4: BADAI SALJU MALAM (Serbuan Cepat & Formasi Padat) ===
			return [
				{ "time": 0.0, "type": E.BANNER, "text": "STAGE 1-4: MALAM BADAI SALJU", "duration": 2.8 },
				{ "time": 2.0, "type": E.FORMATION, "formation": "LINE", "scene": drone, "y": 300.0, "count": 4 },
				{ "time": 4.5, "type": E.FORMATION, "formation": "LINE", "scene": drone, "y": 780.0, "count": 4 },
				{ "time": 8.0, "type": E.FORMATION, "formation": "SWARM_SINE", "scene": sine, "y": 540.0, "count": 3 },
				{ "time": 13.0, "type": E.SPAWN, "scene": carrier, "y": 540.0 },
				{ "time": 16.0, "type": E.BANNER, "text": "WAVE 2: SERANGAN GANDA BADAI ES!", "duration": 2.5 },
				{ "time": 18.0, "type": E.SPAWN, "scene": shooter, "y": 440.0 },
				{ "time": 21.0, "type": E.FORMATION, "formation": "V", "scene": drone, "y": 540.0, "count": 5 },
				{ "time": 26.0, "type": E.FORMATION, "formation": "WALL", "scene": drone, "y": 540.0, "count": 3 },
				{ "time": 30.0, "type": E.SPAWN, "scene": shooter, "y": 680.0 },
				{ "time": 33.0, "type": E.FORMATION, "formation": "LINE", "scene": drone, "y": 420.0, "count": 4 },
				{ "time": 38.0, "type": E.WAIT_CLEAR }
			]

		5:
			# === STAGE 1-5: PALUNG LAUT DALAM (Perang Formasi Sebelum Boss) ===
			return [
				{ "time": 0.0, "type": E.BANNER, "text": "STAGE 1-5: PALUNG LAUT DALAM", "duration": 2.8 },
				{ "time": 2.0, "type": E.FORMATION, "formation": "V", "scene": drone, "y": 400.0, "count": 5 },
				{ "time": 5.5, "type": E.FORMATION, "formation": "V", "scene": drone, "y": 680.0, "count": 5 },
				{ "time": 10.0, "type": E.SPAWN, "scene": carrier, "y": 540.0 },
				{ "time": 13.0, "type": E.BANNER, "text": "WAVE 2: BENTENG PERTAHANAN PALUNG", "duration": 2.5 },
				{ "time": 15.0, "type": E.FORMATION, "formation": "WALL", "scene": drone, "y": 540.0, "count": 4 },
				{ "time": 18.0, "type": E.SPAWN, "scene": shooter, "y": 340.0 },
				{ "time": 19.5, "type": E.SPAWN, "scene": shooter, "y": 740.0 },
				{ "time": 23.0, "type": E.FORMATION, "formation": "SWARM_SINE", "scene": sine, "y": 540.0, "count": 3 },
				{ "time": 28.0, "type": E.FORMATION, "formation": "LINE", "scene": drone, "y": 540.0, "count": 5 },
				{ "time": 33.0, "type": E.SPAWN, "scene": carrier, "y": 460.0 },
				{ "time": 36.0, "type": E.FORMATION, "formation": "WALL", "scene": drone, "y": 540.0, "count": 3 },
				{ "time": 42.0, "type": E.WAIT_CLEAR }
			]

		6:
			# === STAGE 1-6: TAHTA INTI GLOOP (Duel Puncak: Boss Glacier Gloop 3 Fase) ===
			return [
				{ "time": 0.0, "type": E.BANNER, "text": "STAGE 1-6: TAHTA INTI GLOOP", "duration": 2.8 },
				{ "time": 2.0, "type": E.BANNER, "text": "PERSIAPAN TERAKHIR: AMBIL HADIAH!", "duration": 2.2 },
				{ "time": 3.5, "type": E.SPAWN, "scene": carrier, "y": 540.0 },
				{ "time": 6.0, "type": E.BANNER, "text": "PERINGATAN: ANOMALI SUHU EKSTREM!", "duration": 2.5 },
				{ "time": 8.5, "type": E.BOSS, "scene": boss, "name": "GLACIER GLOOP" },
				{ "time": 9.0, "type": E.WAIT_CLEAR }
			]

		_:
			# Default Fallback: Full Marathon Level 1
			return [
				{ "time": 0.0, "type": E.BANNER, "text": "LAUT BEKU: SEKTOR 1", "duration": 3.0 },
				{ "time": 2.0, "type": E.SPAWN, "scene": drone, "y": 420.0 },
				{ "time": 4.5, "type": E.SPAWN, "scene": drone, "y": 680.0 },
				{ "time": 7.0, "type": E.FORMATION, "formation": "LINE", "scene": drone, "y": 540.0, "count": 3 },
				{ "time": 12.0, "type": E.SPAWN, "scene": carrier, "y": 540.0 },
				{ "time": 16.0, "type": E.BOSS, "scene": boss, "name": "GLACIER GLOOP" },
				{ "time": 17.0, "type": E.WAIT_CLEAR }
			]
