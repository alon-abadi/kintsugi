extends Node

var current_tetromino 
var next_tetromino
@export var board: Board
var is_game_over = false
@onready var ui: UI = $"../UI" as UI


func _ready():
	current_tetromino = Shared.Tetromino.values().pick_random()
	next_tetromino = Shared.Tetromino.values().pick_random()
	board.spawn_tetromino(current_tetromino, false, Vector2.ZERO)
	board.spawn_tetromino(next_tetromino, true, Vector2(100,50))
	board.tetromino_locked.connect(on_tetromino_locked)
	board.game_over.connect(on_game_over)
	
func on_tetromino_locked():
	if is_game_over:
		return

	current_tetromino = next_tetromino
	next_tetromino = Shared.Tetromino.values().pick_random()
	board.spawn_tetromino(current_tetromino, false, Vector2.ZERO)
	board.spawn_tetromino(next_tetromino, true, Vector2(100,50))
	

func on_game_over():
	is_game_over = true
	ui.show_game_over()
	
