extends Node2D

class_name Line

var board : Board = Shared.board
var max_count
var idx
var pieces: Array[Piece]

func reset():
	# Reset the array!
	while pieces.size() > 0:
		pieces.pop_front()
	
	for i in range(board.column_count):
		pieces.append(null)

func _ready() -> void:
	reset()
	
func setPiece(p: Piece, n: int):
	pieces[n] = p

func is_line_full(max_count)->bool:
	return max_count == get_child_count()
