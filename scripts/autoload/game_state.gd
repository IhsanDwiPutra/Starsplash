extends Node
## Menyimpan status global permainan (nyawa, skor, kesulitan).
## Angka awal ada di docs/BALANCE.md.

enum Difficulty { EASY, NORMAL, HARD }

signal score_changed(new_score: int)
signal lives_changed(new_lives: int)

const START_LIVES: Dictionary = {
	Difficulty.EASY: 5,
	Difficulty.NORMAL: 3,
	Difficulty.HARD: 2,
}

var difficulty: Difficulty = Difficulty.NORMAL
var score: int = 0
var lives: int = 3


func new_game(chosen: Difficulty = Difficulty.NORMAL) -> void:
	difficulty = chosen
	score = 0
	lives = START_LIVES[chosen]
	score_changed.emit(score)
	lives_changed.emit(lives)


func add_score(amount: int) -> void:
	score += amount
	score_changed.emit(score)


func lose_life() -> void:
	lives = maxi(lives - 1, 0)
	lives_changed.emit(lives)
