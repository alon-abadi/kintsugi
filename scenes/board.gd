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
var piece_size = 48
var top_y = -456
var top_x = -240
var next_tetromino
var kintsugi: bool = false
var lines: Array[Line]

func _ready() -> void:
	for i in range(row_count):
		lines.append(null)

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
	
	for p in tetromino_pieces:
		var piece = p as Piece
		var y_position = piece.global_position.y
		var does_line_for_piece_exists = false
		var lineIdx = row_count - int((piece.global_position.y - top_y) / piece_size) - 1
		var line = lines[lineIdx] as Line

		if line == null:
			line = line_scene.instantiate() as Line
			lines[lineIdx] = line
			line.global_position = Vector2(0, y_position)
			add_child(line)
		piece.reparent(line)
		
		var pieceIdx = int((piece.global_position.x - top_x) / piece_size) 
		line.setPiece(piece, pieceIdx)
		print("Setting piece at (" + str(pieceIdx) + ", " + str(lineIdx) + ")")

func get_lines()->Array:
	return get_children().filter(func(l): return l is Line)
	

func remove_full_lines():
	for i in range(row_count):
		var line = lines[i] as Line
		if line != null and line.is_line_full(column_count):
			move_lines_down(i)
			line_clear.emit()
			line.free()

func move_lines_down(n):
	for i in range(n, row_count - 1):
		if i > n:
			var line = lines[i] as Line
			if line != null:
				line.global_position.y += piece_size
				
		lines[i] = lines[i + 1]
	lines[row_count - 1] = null
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
	
