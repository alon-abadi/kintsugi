extends Node

class_name Board

signal tetromino_locked
signal game_over
signal kintsugi_time
signal line_clear


@export var tetromino_scene: PackedScene
@export var line_scene: PackedScene
@export var panel_container: PanelContainer

var tetrominos: Array[Tetromino] = []
var row_count = 20
var column_count = 10
var next_tetromino
var kintsugi: bool = false

func spawn_tetromino(type: Shared.Tetromino, is_preview: bool, spawn_position: Vector2):
	var tetromino_data = Shared.data[type]
	var tetromino = tetromino_scene.instantiate() as Tetromino
	tetromino.tetromino_data = tetromino_data
	tetromino.is_preview = is_preview
	if type == Shared.Tetromino.Gold:
		tetromino.set_mode("FLOATING")
	
	if is_preview:
		tetromino.scale = Vector2(0.5, 0.5)
		tetromino.set_mode("STATIC")
		panel_container.add_child(tetromino)
		tetromino.set_position(spawn_position)
		next_tetromino = tetromino
	else:
		tetromino.position = tetromino_data.spawn_position
		var other_pieces = get_all_pieces()
		tetromino.other_pieces = other_pieces
		tetromino.lock_tetromino.connect(on_tetromino_lock)
		add_child(tetromino)

func spawn_kintsugi(is_preview: bool):
	kintsugi = true
	var tetromino = tetromino_scene.instantiate() as Tetromino
	tetromino.gravity = false
	tetromino.kintsugi = true
	var tetromino_data = Shared.data[Shared.Kintsugi.Gold]

	
	tetromino.tetromino_data = tetromino_data
	tetromino.position = tetromino_data.spawn_position
	var other_pieces = get_all_pieces()
	tetromino.other_pieces = other_pieces
	tetromino.lock_tetromino.connect(on_tetromino_lock)
	add_child(tetromino)
	

func on_tetromino_lock(t: Tetromino):
	if !kintsugi: 
		next_tetromino.queue_free()
	tetrominos.append(t)
	add_tetromino_to_lines(t)
	remove_full_lines()
	tetromino_locked.emit()
	check_game_over()
	
func check_game_over():
	for piece in get_all_pieces():
		var y_location = piece.global_position.y
		if y_location == -456:
			game_over.emit()
	
	
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
			line_clear.emit()
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
	
func get_holes():
	return []

func get_number_of_lines():
	return get_lines().size()
	
func get_number_of_pieces():
	return get_all_pieces().size()
	
