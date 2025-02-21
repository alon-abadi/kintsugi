extends Node

var current_tetromino 
var next_tetromino
var score: int
var gold_count: int

@export var board: Board
var is_game_over = false
@onready var ui: UI = $"../UI" as UI

enum states {
	TETRIS,
	KINTSUGI,
}

var state: states = states.TETRIS

var possible_tetrominos = []

func _ready():
	gold_count = 2
	possible_tetrominos = Shared.Tetromino.values()
	possible_tetrominos.erase(Shared.Tetromino.Gold)
	
	current_tetromino = possible_tetrominos.pick_random()
	#current_tetromino = Shared.Tetromino.Gold
	board.tetromino_locked.connect(on_tetromino_locked)
	board.line_clear.connect(on_line_clear)
	board.game_over.connect(on_game_over)
	spawn()
	
	
func on_tetromino_locked():
	if is_game_over:
		return
	current_tetromino = next_tetromino
	spawn()
	


	

func spawn():
	match state:
		states.TETRIS:
			next_tetromino = possible_tetrominos.pick_random()
			board.spawn_tetromino(current_tetromino, false, Vector2.ZERO)
			board.spawn_tetromino(next_tetromino, true, Vector2(100,50))
		states.KINTSUGI:
			gold_count -= 1
			
			board.spawn_tetromino(current_tetromino, false, Vector2.ZERO)
			if gold_count > 1: 
				next_tetromino = Shared.Tetromino.Gold
				board.spawn_tetromino(next_tetromino, true, Vector2(100,50))
			else:
				next_tetromino = possible_tetrominos.pick_random()
				board.spawn_tetromino(next_tetromino, true, Vector2(100,50))
				state = states.TETRIS


func on_line_clear():
	score += 1
	print("score:", score)
	gold_count += 1
	print("gold_count: ", gold_count)
	
	if score % 3 == 0: 
		state = states.KINTSUGI

func on_game_over():
	is_game_over = true
	ui.show_game_over()
