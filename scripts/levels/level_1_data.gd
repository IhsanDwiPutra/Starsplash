class_name Level1Data
extends RefCounted
## Timeline gelombang musuh Dunia 1: Laut Beku (Stage 1-1 s/d Stage 1-6).
## Termasuk target skor dan kalkulasi 3 bintang per stage.

const STAGE_NAMES: Dictionary = {
	1: "Pesisir Es",
	2: "Selat Gunung Es",
	3: "Benteng Es",
	4: "Badai Salju Malam",
	5: "Palung Laut Dalam",
	6: "Tahta Inti Gloop"
}

## Target skor minimum untuk meraih Bintang 2 di setiap stage
const STAGE_TARGET_SCORES: Dictionary = {
	1: 4500,
	2: 7500,
	3: 13000,
	4: 11000,
	5: 15000,
	6: 22000
}


static func get_stage_name(stage_num: int) -> String:
	return STAGE_NAMES.get(stage_num, "Laut Beku")


static func get_target_score(stage_num: int) -> int:
	return STAGE_TARGET_SCORES.get(stage_num, 5000)


## Menghitung bintang yang diperoleh pada akhir stage:
## - Bintang 1 (Tuntas): Menyelesaikan stage (selamat sampai akhir).
## - Bintang 2 (Target Skor): Skor akhir mencapai atau melampaui target.
## - Bintang 3 (Tangguh): Sisa nyawa minimal 2 (penguasaan pertahanan kapal).
static func calculate_stars(stage_num: int, final_score: int, lives_remaining: int) -> Dictionary:
	var target: int = get_target_score(stage_num)
	var star_1: bool = true
	var star_2: bool = final_score >= target
	var star_3: bool = lives_remaining >= 2
	var total: int = (1 if star_1 else 0) + (1 if star_2 else 0) + (1 if star_3 else 0)

	return {
		"total_stars": total,
		"star_1": star_1,
		"star_2": star_2,
		"star_3": star_3,
		"target_score": target
	}


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
			# === STAGE 1-1: PESISIR ES (~75 detik) ===
			# Pengenalan bertahap Frost Jelly, Carrier Harta, dan manuver dasar
			return [
				{ "time": 0.0, "type": E.BANNER, "text": "STAGE 1-1: PESISIR ES", "duration": 2.8 },
				{ "time": 2.0, "type": E.SPAWN, "scene": drone, "y": 450.0 },
				{ "time": 4.0, "type": E.SPAWN, "scene": drone, "y": 630.0 },
				{ "time": 6.5, "type": E.FORMATION, "formation": "LINE", "scene": drone, "y": 540.0, "count": 3 },
				{ "time": 10.0, "type": E.FORMATION, "formation": "LINE", "scene": drone, "y": 350.0, "count": 3 },
				{ "time": 11.5, "type": E.FORMATION, "formation": "LINE", "scene": drone, "y": 730.0, "count": 3 },
				{ "time": 15.0, "type": E.BANNER, "text": "CARRIER EMAS TERDETEKSI! AMBIL [P]", "duration": 2.5 },
				{ "time": 17.0, "type": E.SPAWN, "scene": carrier, "y": 540.0 },
				{ "time": 19.5, "type": E.FORMATION, "formation": "V", "scene": drone, "y": 540.0, "count": 5 },
				{ "time": 24.0, "type": E.FORMATION, "formation": "WALL", "scene": drone, "y": 540.0, "count": 3 },
				{ "time": 27.5, "type": E.FORMATION, "formation": "SWARM_SINE", "scene": sine, "y": 450.0, "count": 2 },
				{ "time": 30.5, "type": E.FORMATION, "formation": "SWARM_SINE", "scene": sine, "y": 630.0, "count": 2 },
				{ "time": 35.0, "type": E.BANNER, "text": "CHECKPOINT: PESISIR TENGAH", "duration": 2.5 },
				{ "time": 37.0, "type": E.CHECKPOINT, "id": 1, "name": "Pesisir Tengah" },
				{ "time": 38.5, "type": E.SPAWN, "scene": carrier, "y": 480.0 },
				{ "time": 41.5, "type": E.FORMATION, "formation": "V", "scene": drone, "y": 400.0, "count": 5 },
				{ "time": 44.0, "type": E.FORMATION, "formation": "V", "scene": drone, "y": 680.0, "count": 5 },
				{ "time": 48.5, "type": E.FORMATION, "formation": "LINE", "scene": drone, "y": 540.0, "count": 4 },
				{ "time": 52.5, "type": E.FORMATION, "formation": "WALL", "scene": drone, "y": 380.0, "count": 3 },
				{ "time": 53.0, "type": E.FORMATION, "formation": "WALL", "scene": drone, "y": 700.0, "count": 3 },
				{ "time": 58.0, "type": E.BANNER, "text": "WAVE TERAKHIR: SERBUAN BESAR JELLY!", "duration": 2.5 },
				{ "time": 61.0, "type": E.FORMATION, "formation": "V", "scene": drone, "y": 540.0, "count": 5 },
				{ "time": 63.5, "type": E.FORMATION, "formation": "SWARM_SINE", "scene": sine, "y": 540.0, "count": 2 },
				{ "time": 66.0, "type": E.FORMATION, "formation": "LINE", "scene": drone, "y": 340.0, "count": 4 },
				{ "time": 67.5, "type": E.FORMATION, "formation": "LINE", "scene": drone, "y": 740.0, "count": 4 },
				{ "time": 73.0, "type": E.WAIT_CLEAR }
			]

		2:
			# === STAGE 1-2: SELAT GUNUNG ES (~85 detik) ===
			# Serbuan gerak sinus Puffer Snapper & Penembak Es dari jarak jauh
			return [
				{ "time": 0.0, "type": E.BANNER, "text": "STAGE 1-2: SELAT GUNUNG ES", "duration": 2.8 },
				{ "time": 2.0, "type": E.SPAWN, "scene": sine, "y": 420.0 },
				{ "time": 4.5, "type": E.SPAWN, "scene": sine, "y": 660.0 },
				{ "time": 7.0, "type": E.FORMATION, "formation": "SWARM_SINE", "scene": sine, "y": 540.0, "count": 2 },
				{ "time": 10.0, "type": E.FORMATION, "formation": "LINE", "scene": drone, "y": 360.0, "count": 4 },
				{ "time": 12.5, "type": E.BANNER, "text": "WASPADA: PENEMBAK ES MENGHADANG!", "duration": 2.5 },
				{ "time": 14.5, "type": E.SPAWN, "scene": shooter, "y": 400.0 },
				{ "time": 17.0, "type": E.FORMATION, "formation": "V", "scene": drone, "y": 540.0, "count": 5 },
				{ "time": 21.0, "type": E.SPAWN, "scene": carrier, "y": 540.0 },
				{ "time": 24.0, "type": E.FORMATION, "formation": "SWARM_SINE", "scene": sine, "y": 380.0, "count": 2 },
				{ "time": 26.0, "type": E.FORMATION, "formation": "SWARM_SINE", "scene": sine, "y": 700.0, "count": 2 },
				{ "time": 29.5, "type": E.SPAWN, "scene": shooter, "y": 680.0 },
				{ "time": 32.0, "type": E.FORMATION, "formation": "WALL", "scene": drone, "y": 540.0, "count": 3 },
				{ "time": 36.0, "type": E.FORMATION, "formation": "V", "scene": drone, "y": 350.0, "count": 5 },
				{ "time": 38.0, "type": E.FORMATION, "formation": "V", "scene": drone, "y": 730.0, "count": 5 },
				{ "time": 42.0, "type": E.BANNER, "text": "CHECKPOINT: SELAT DALAM", "duration": 2.5 },
				{ "time": 44.0, "type": E.CHECKPOINT, "id": 1, "name": "Selat Dalam" },
				{ "time": 46.0, "type": E.SPAWN, "scene": carrier, "y": 450.0 },
				{ "time": 49.0, "type": E.SPAWN, "scene": shooter, "y": 320.0 },
				{ "time": 50.5, "type": E.SPAWN, "scene": shooter, "y": 760.0 },
				{ "time": 54.0, "type": E.FORMATION, "formation": "WALL", "scene": drone, "y": 540.0, "count": 4 },
				{ "time": 58.0, "type": E.FORMATION, "formation": "SWARM_SINE", "scene": sine, "y": 450.0, "count": 2 },
				{ "time": 60.0, "type": E.FORMATION, "formation": "SWARM_SINE", "scene": sine, "y": 630.0, "count": 2 },
				{ "time": 64.0, "type": E.BANNER, "text": "WAVE TERAKHIR: SKUAD PENEMBAK ELIT!", "duration": 2.5 },
				{ "time": 66.5, "type": E.SPAWN, "scene": shooter, "y": 540.0 },
				{ "time": 68.5, "type": E.FORMATION, "formation": "V", "scene": drone, "y": 540.0, "count": 5 },
				{ "time": 71.5, "type": E.FORMATION, "formation": "SWARM_SINE", "scene": sine, "y": 350.0, "count": 2 },
				{ "time": 73.5, "type": E.FORMATION, "formation": "LINE", "scene": drone, "y": 730.0, "count": 4 },
				{ "time": 81.0, "type": E.WAIT_CLEAR }
			]

		3:
			# === STAGE 1-3: BENTENG ES (~95 detik) ===
			# Pertahanan sengit & Pertempuran Klimaks Mini-Boss Mecha Narwhal
			return [
				{ "time": 0.0, "type": E.BANNER, "text": "STAGE 1-3: BENTENG ES TERAPUNG", "duration": 2.8 },
				{ "time": 2.0, "type": E.FORMATION, "formation": "WALL", "scene": drone, "y": 540.0, "count": 3 },
				{ "time": 5.0, "type": E.SPAWN, "scene": shooter, "y": 380.0 },
				{ "time": 7.5, "type": E.FORMATION, "formation": "V", "scene": drone, "y": 640.0, "count": 5 },
				{ "time": 11.0, "type": E.FORMATION, "formation": "SWARM_SINE", "scene": sine, "y": 400.0, "count": 2 },
				{ "time": 13.5, "type": E.FORMATION, "formation": "LINE", "scene": drone, "y": 540.0, "count": 4 },
				{ "time": 17.0, "type": E.SPAWN, "scene": carrier, "y": 540.0 },
				{ "time": 20.0, "type": E.SPAWN, "scene": shooter, "y": 320.0 },
				{ "time": 21.5, "type": E.SPAWN, "scene": shooter, "y": 760.0 },
				{ "time": 25.0, "type": E.FORMATION, "formation": "WALL", "scene": drone, "y": 540.0, "count": 4 },
				{ "time": 29.0, "type": E.FORMATION, "formation": "SWARM_SINE", "scene": sine, "y": 540.0, "count": 2 },
				{ "time": 32.0, "type": E.FORMATION, "formation": "V", "scene": drone, "y": 400.0, "count": 5 },
				{ "time": 34.0, "type": E.FORMATION, "formation": "V", "scene": drone, "y": 680.0, "count": 5 },
				{ "time": 38.5, "type": E.FORMATION, "formation": "LINE", "scene": drone, "y": 540.0, "count": 4 },
				{ "time": 42.0, "type": E.BANNER, "text": "CHECKPOINT: GERBANG UTAMA BENTENG", "duration": 2.8 },
				{ "time": 44.0, "type": E.CHECKPOINT, "id": 1, "name": "Gerbang Benteng" },
				{ "time": 46.0, "type": E.SPAWN, "scene": carrier, "y": 540.0 },
				{ "time": 49.0, "type": E.SPAWN, "scene": shooter, "y": 450.0 },
				{ "time": 51.5, "type": E.FORMATION, "formation": "WALL", "scene": drone, "y": 540.0, "count": 3 },
				{ "time": 55.0, "type": E.BANNER, "text": "PERINGATAN: MINI-BOSS MECHA NARWHAL MENDEKAT!", "duration": 3.0 },
				{ "time": 58.5, "type": E.BOSS, "scene": mini_boss, "name": "MECHA NARWHAL" },
				{ "time": 59.0, "type": E.WAIT_CLEAR }
			]

		4:
			# === STAGE 1-4: BADAI SALJU MALAM (~90 detik) ===
			# Badai kecepatan tinggi: Formasi rapat bergantian atas-bawah
			return [
				{ "time": 0.0, "type": E.BANNER, "text": "STAGE 1-4: MALAM BADAI SALJU", "duration": 2.8 },
				{ "time": 2.0, "type": E.FORMATION, "formation": "LINE", "scene": drone, "y": 300.0, "count": 4 },
				{ "time": 3.5, "type": E.FORMATION, "formation": "LINE", "scene": drone, "y": 780.0, "count": 4 },
				{ "time": 6.5, "type": E.FORMATION, "formation": "SWARM_SINE", "scene": sine, "y": 540.0, "count": 2 },
				{ "time": 9.5, "type": E.FORMATION, "formation": "V", "scene": drone, "y": 450.0, "count": 5 },
				{ "time": 12.5, "type": E.SPAWN, "scene": shooter, "y": 540.0 },
				{ "time": 15.5, "type": E.SPAWN, "scene": carrier, "y": 540.0 },
				{ "time": 18.5, "type": E.FORMATION, "formation": "WALL", "scene": drone, "y": 540.0, "count": 4 },
				{ "time": 22.0, "type": E.FORMATION, "formation": "LINE", "scene": drone, "y": 360.0, "count": 4 },
				{ "time": 24.0, "type": E.FORMATION, "formation": "LINE", "scene": drone, "y": 720.0, "count": 4 },
				{ "time": 28.0, "type": E.SPAWN, "scene": shooter, "y": 350.0 },
				{ "time": 29.5, "type": E.SPAWN, "scene": shooter, "y": 730.0 },
				{ "time": 33.0, "type": E.FORMATION, "formation": "SWARM_SINE", "scene": sine, "y": 400.0, "count": 2 },
				{ "time": 35.0, "type": E.FORMATION, "formation": "SWARM_SINE", "scene": sine, "y": 680.0, "count": 2 },
				{ "time": 40.0, "type": E.BANNER, "text": "CHECKPOINT: MATA BADAI SALJU", "duration": 2.5 },
				{ "time": 42.0, "type": E.CHECKPOINT, "id": 1, "name": "Mata Badai" },
				{ "time": 44.0, "type": E.SPAWN, "scene": carrier, "y": 540.0 },
				{ "time": 47.0, "type": E.FORMATION, "formation": "V", "scene": drone, "y": 320.0, "count": 5 },
				{ "time": 49.0, "type": E.FORMATION, "formation": "V", "scene": drone, "y": 760.0, "count": 5 },
				{ "time": 53.0, "type": E.FORMATION, "formation": "WALL", "scene": drone, "y": 540.0, "count": 4 },
				{ "time": 56.5, "type": E.SPAWN, "scene": shooter, "y": 450.0 },
				{ "time": 58.0, "type": E.SPAWN, "scene": shooter, "y": 630.0 },
				{ "time": 62.0, "type": E.FORMATION, "formation": "SWARM_SINE", "scene": sine, "y": 540.0, "count": 2 },
				{ "time": 65.0, "type": E.BANNER, "text": "WAVE TERAKHIR: AMUKAN BADAI ES!", "duration": 2.5 },
				{ "time": 68.0, "type": E.FORMATION, "formation": "V", "scene": drone, "y": 540.0, "count": 5 },
				{ "time": 71.0, "type": E.FORMATION, "formation": "WALL", "scene": drone, "y": 540.0, "count": 4 },
				{ "time": 74.0, "type": E.SPAWN, "scene": shooter, "y": 540.0 },
				{ "time": 76.5, "type": E.FORMATION, "formation": "SWARM_SINE", "scene": sine, "y": 400.0, "count": 2 },
				{ "time": 84.0, "type": E.WAIT_CLEAR }
			]

		5:
			# === STAGE 1-5: PALUNG LAUT DALAM (~105 detik) ===
			# Serbuan Elit Palung: Formasi perisai gabungan shooter & sine ganda
			return [
				{ "time": 0.0, "type": E.BANNER, "text": "STAGE 1-5: PALUNG LAUT DALAM", "duration": 2.8 },
				{ "time": 2.0, "type": E.FORMATION, "formation": "V", "scene": drone, "y": 400.0, "count": 5 },
				{ "time": 4.5, "type": E.FORMATION, "formation": "V", "scene": drone, "y": 680.0, "count": 5 },
				{ "time": 8.0, "type": E.SPAWN, "scene": shooter, "y": 540.0 },
				{ "time": 11.0, "type": E.SPAWN, "scene": carrier, "y": 540.0 },
				{ "time": 14.5, "type": E.FORMATION, "formation": "WALL", "scene": drone, "y": 540.0, "count": 4 },
				{ "time": 18.0, "type": E.FORMATION, "formation": "SWARM_SINE", "scene": sine, "y": 380.0, "count": 2 },
				{ "time": 20.0, "type": E.FORMATION, "formation": "SWARM_SINE", "scene": sine, "y": 700.0, "count": 2 },
				{ "time": 24.0, "type": E.SPAWN, "scene": shooter, "y": 320.0 },
				{ "time": 25.5, "type": E.SPAWN, "scene": shooter, "y": 760.0 },
				{ "time": 29.0, "type": E.FORMATION, "formation": "LINE", "scene": drone, "y": 540.0, "count": 5 },
				{ "time": 33.0, "type": E.FORMATION, "formation": "V", "scene": drone, "y": 450.0, "count": 5 },
				{ "time": 35.5, "type": E.FORMATION, "formation": "V", "scene": drone, "y": 630.0, "count": 5 },
				{ "time": 40.0, "type": E.SPAWN, "scene": carrier, "y": 540.0 },
				{ "time": 44.0, "type": E.FORMATION, "formation": "WALL", "scene": drone, "y": 540.0, "count": 4 },
				{ "time": 48.0, "type": E.BANNER, "text": "CHECKPOINT: BIBIR PALUNG DALAM", "duration": 2.5 },
				{ "time": 50.0, "type": E.CHECKPOINT, "id": 1, "name": "Bibir Palung Dalam" },
				{ "time": 52.0, "type": E.SPAWN, "scene": carrier, "y": 480.0 },
				{ "time": 55.0, "type": E.SPAWN, "scene": shooter, "y": 400.0 },
				{ "time": 57.0, "type": E.SPAWN, "scene": shooter, "y": 680.0 },
				{ "time": 61.0, "type": E.FORMATION, "formation": "SWARM_SINE", "scene": sine, "y": 540.0, "count": 2 },
				{ "time": 64.0, "type": E.FORMATION, "formation": "V", "scene": drone, "y": 350.0, "count": 5 },
				{ "time": 66.5, "type": E.FORMATION, "formation": "V", "scene": drone, "y": 730.0, "count": 5 },
				{ "time": 71.0, "type": E.FORMATION, "formation": "WALL", "scene": drone, "y": 540.0, "count": 4 },
				{ "time": 75.0, "type": E.SPAWN, "scene": shooter, "y": 540.0 },
				{ "time": 78.0, "type": E.FORMATION, "formation": "LINE", "scene": drone, "y": 400.0, "count": 5 },
				{ "time": 80.0, "type": E.FORMATION, "formation": "LINE", "scene": drone, "y": 680.0, "count": 5 },
				{ "time": 85.0, "type": E.BANNER, "text": "WAVE TERAKHIR: BENTENG PENUTUP PALUNG!", "duration": 2.5 },
				{ "time": 88.0, "type": E.SPAWN, "scene": shooter, "y": 340.0 },
				{ "time": 89.5, "type": E.SPAWN, "scene": shooter, "y": 740.0 },
				{ "time": 92.0, "type": E.FORMATION, "formation": "WALL", "scene": drone, "y": 540.0, "count": 4 },
				{ "time": 94.5, "type": E.FORMATION, "formation": "SWARM_SINE", "scene": sine, "y": 540.0, "count": 2 },
				{ "time": 102.0, "type": E.WAIT_CLEAR }
			]

		6:
			# === STAGE 1-6: TAHTA INTI GLOOP (~115 detik) ===
			# Duel Puncak Dunia 1: Vanguard elit pengawal + Duel Boss Glacier Gloop
			return [
				{ "time": 0.0, "type": E.BANNER, "text": "STAGE 1-6: TAHTA INTI GLOOP", "duration": 2.8 },
				{ "time": 2.0, "type": E.BANNER, "text": "VANGUARD PENGAWAL TERAKHIR GLOOP!", "duration": 2.2 },
				{ "time": 4.0, "type": E.FORMATION, "formation": "V", "scene": drone, "y": 540.0, "count": 5 },
				{ "time": 7.5, "type": E.SPAWN, "scene": shooter, "y": 380.0 },
				{ "time": 9.0, "type": E.SPAWN, "scene": shooter, "y": 700.0 },
				{ "time": 12.0, "type": E.FORMATION, "formation": "SWARM_SINE", "scene": sine, "y": 540.0, "count": 2 },
				{ "time": 15.0, "type": E.FORMATION, "formation": "WALL", "scene": drone, "y": 540.0, "count": 4 },
				{ "time": 19.0, "type": E.SPAWN, "scene": carrier, "y": 540.0 },
				{ "time": 22.0, "type": E.FORMATION, "formation": "V", "scene": drone, "y": 400.0, "count": 5 },
				{ "time": 24.5, "type": E.FORMATION, "formation": "V", "scene": drone, "y": 680.0, "count": 5 },
				{ "time": 28.0, "type": E.SPAWN, "scene": shooter, "y": 540.0 },
				{ "time": 30.5, "type": E.FORMATION, "formation": "LINE", "scene": drone, "y": 540.0, "count": 5 },
				{ "time": 34.0, "type": E.SPAWN, "scene": carrier, "y": 540.0 },
				{ "time": 38.0, "type": E.BANNER, "text": "CHECKPOINT: SARANG UTAMA GLOOP", "duration": 2.5 },
				{ "time": 40.0, "type": E.CHECKPOINT, "id": 1, "name": "Sarang Utama Gloop" },
				{ "time": 42.0, "type": E.SPAWN, "scene": carrier, "y": 540.0 },
				{ "time": 45.0, "type": E.BANNER, "text": "PERINGATAN: ANOMALI SUHU EKSTREM!", "duration": 3.0 },
				{ "time": 48.5, "type": E.BOSS, "scene": boss, "name": "GLACIER GLOOP" },
				{ "time": 49.0, "type": E.WAIT_CLEAR }
			]

		_:
			# Default Fallback
			return [
				{ "time": 0.0, "type": E.BANNER, "text": "LAUT BEKU: SEKTOR 1", "duration": 3.0 },
				{ "time": 2.0, "type": E.SPAWN, "scene": drone, "y": 420.0 },
				{ "time": 4.5, "type": E.SPAWN, "scene": drone, "y": 680.0 },
				{ "time": 7.0, "type": E.FORMATION, "formation": "LINE", "scene": drone, "y": 540.0, "count": 3 },
				{ "time": 12.0, "type": E.SPAWN, "scene": carrier, "y": 540.0 },
				{ "time": 16.0, "type": E.BOSS, "scene": boss, "name": "GLACIER GLOOP" },
				{ "time": 17.0, "type": E.WAIT_CLEAR }
			]
