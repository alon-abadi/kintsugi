extends Node

class_name Board

signal tetromino_locked
signal game_over 


@export var tetromino_scene: PackedScene
@export var line_scene: PackedScene
@export var panel_container: PanelContainer

var tetrominos: Array[Tetromino] = []
var row_count = 20
var column_count = 10
var next_tetromino

func spawn_tetromino(type: Shared.Tetromino, is_next_piece: bool, spawn_position: Vector2):
	var tetromino_data = Shared.data[type]
	var tetromino = tetromino_scene.instantiate() as Tetromino
	tetromino.tetromino_data = tetromino_data
	tetromino.is_next_piece = is_next_piece
	
	if !is_next_piece:
		tetromino.position = tetromino_data.spawn_position
		var other_pieces = get_all_pieces()
		tetromino.other_pieces = other_pieces
		tetromino.lock_tetromino.connect(on_tetromino_lock)
		add_child(tetromino)
	else:
		tetromino.scale = Vector2(0.5, 0.5)
		panel_container.add_child(tetromino)
		tetromino.set_position(spawn_position)
		next_tetromino = tetromino
		

func on_tetromino_lock(t: Tetromino):
	next_tetromino.queue_free()
	tetrominos.append(t)
	add_tetromino_to_lines(t)
	remove_full_lines()
	tetromino_locked.emit()
	check_game_over()
	#clear_lines()
	
func check_game_over():
	for piece in get_all_pieces():
		var y_location = piece.global_position.y
		if y_location == -456:
			game_over.emit()
	#
#func clear_lines(): 
	#var board_pieces = fill_board_pieces()
	#clear_board_pieces(board_pieces)
#
#
#func fill_board_pieces():
	#var board_pieces = []
	#for i in row_count:
		#board_pieces.append([])
	#
	#for tetromino in tetrominos:
		#var tetromino_pieces = tetromino.get_children().filter(func(c): return c is Piece)
		#for piece in tetromino_pieces:
			#var row = (piece.global_position.y + piece.get_size().y / 2) / piece.get_size().y + row_count /2
			#board_pieces[row-1].append(piece)
	#
	#return board_pieces

#
#func clear_board_pieces(board_pieces):
	#var i = row_count
	#
	#while i > 0: 
		#var row_to_check = board_pieces[i - 1]
		#
		#if row_to_check.size() == column_count:
			#print("found a row to delete: ",i)
			#clear_row(row_to_check)
			#board_pieces[i-1].clear()
			#move_all_pieces_down(board_pieces,i)
		#
		#i -= 1
##
#func clear_row(row):
	#for piece in row:
		#piece.queue_free()
	#
	#
#func move_all_pieces_down(board_pieces,cleared_row_index):
	#for i in range(cleared_row_index -1, 1, -1):
		#var row_to_move = board_pieces[i-1]
		#if row_to_move.size() == 0:
			#return
		#
		#for piece in row_to_move:
			#piece.position.y += piece.get_size().y
			#board_pieces[cleared_row_index -1].append(piece)
		#board_pieces[i-1].clear()

func add_tetromino_to_lines(t: Tetromino):
	var tetromino_pieces =  t.get_children().filter(func(c): return c is Piece)
	
	for piece in tetromino_pieces:
		var y_position = piece.global_position.y
		var does_line_for_piece_exists = false
		for line in get_lines(): 
			if line.global_position.y == y_position:
				piece.reparent(line)
				does_line_for_piece_exists = true
		
		if !does_line_for_piece_exists: 
			var piece_line = line_scene.instantiate() as Line
			piece_line.global_position = Vector2(0, y_position)
			add_child(piece_line)
			piece.reparent(piece_line)

func get_lines()->Array:
	return get_children().filter(func(l): return l is Line)
	

func remove_full_lines():
	for l in get_lines():
		var line = l as Line
		if line.is_line_full(column_count):
			move_lines_down(line.global_position.y)
			
			line.free()

func move_lines_down(y_pos):
	for line in get_lines(): 
		if line.global_position.y < y_pos:
			line.global_position.y += 48


func get_all_pieces():
	var pieces = []
	for line in get_lines():
		pieces.append_array(line.get_children())
	
	return pieces
