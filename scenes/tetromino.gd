extends Node2D

class_name Tetromino

signal lock_tetromino(tetromino: Tetromino)

var bounds = {
	"min_x": -216, 
	"max_x": 216, #216 +48 = 264
	"min_y": -300,
	"max_y": 457, #480 - 48/2 -1 = 457
}

enum modes {
	FALLING,
	STATIC,
	FLOATING
}
var mode: modes

var rotation_index = 0
var wall_kicks
var tetromino_data
var is_preview
var tetromino_cells
var pieces = []
var other_pieces
var gravity: bool = true
var ghost: bool = false
var ghost_tetromino: GhostTetromino

@export var piece_scene: PackedScene
@export var timer: Timer
@export var ghost_tetromino_scene: PackedScene

func _ready() -> void:
	timer.timeout.connect(on_timer_timeout)
	tetromino_cells = Shared.cells[tetromino_data.tetromino_type]
	
	for cell in tetromino_cells: 
		var piece = piece_scene.instantiate() as Piece
		pieces.append(piece)
		add_child(piece)
		piece.set_texture(tetromino_data.piece_texture)
		piece.position = cell * piece.get_size()
	
	if mode == modes.STATIC || mode == modes.FLOATING:
		timer.stop()
	
	if mode == modes.FLOATING:
		hard_drop_golden.call_deferred()
		
	if mode == modes.STATIC:
		set_process_input(false)

	if mode != modes.STATIC:
		position = tetromino_data.spawn_position
		
	if tetromino_data.tetromino_type == Shared.Tetromino.I:
		wall_kicks = Shared.wall_kicks_i
	else:
		wall_kicks = Shared.wall_kicks_jlostz
	
	if mode == modes.FALLING:
		ghost = true
		ghost_tetromino = ghost_tetromino_scene.instantiate() as GhostTetromino
		ghost_tetromino.tetromino_data = tetromino_data
		get_tree().root.add_child.call_deferred(ghost_tetromino)
		hard_drop_ghost.call_deferred()
		


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("left"):
		move(Vector2.LEFT)
	elif Input.is_action_just_pressed("right"):
		move(Vector2.RIGHT)
	elif Input.is_action_just_pressed("down"):
		move(Vector2.DOWN)
	elif Input.is_action_just_pressed("hard_drop"):
		hard_drop()
	elif Input.is_action_just_pressed("rotate_left"):
		rotate_tetromino(-1)
	elif Input.is_action_just_pressed("rotate_right"):
		rotate_tetromino(1)
	elif Input.is_action_just_pressed("up") and mode == modes.FLOATING:
		move(Vector2.UP)
		
func set_mode(s):
	if s == "FALLING":
		mode = modes.FALLING
	elif s == "STATIC": 
		mode = modes.STATIC
	else:
		mode = modes.FLOATING

func move(direction: Vector2)-> bool: 
	if mode == modes.STATIC: 
		return false
		
	var new_position = calculate_global_position(direction, global_position)
	
	if new_position:
		global_position = new_position
		if direction != Vector2.DOWN:
			hard_drop_ghost.call_deferred()
		return true
	
	return false
	
func calculate_global_position(direction: Vector2, starting_global_position:Vector2):
	if is_colliding_with_other_tetrominos(direction, starting_global_position):
		return null
		
	if !is_within_game_bounds(direction, starting_global_position):
		return null
		
	return starting_global_position + direction * pieces[0].get_size().x
	

func is_within_game_bounds(direction: Vector2, starting_global_position: Vector2)->bool:
	for piece in pieces: 
		var new_position = starting_global_position + piece.position + direction * piece.get_size()
		
		if direction == Vector2.UP and new_position.y < bounds.get("min_y"):
			return false
			
		if new_position.x < bounds.get("min_x") || 	 new_position.x > bounds.get("max_x") || new_position.y > bounds.get("max_y"):
			return false
		
			
		
	return true

func is_colliding_with_other_tetrominos(direction: Vector2, starting_global_position: Vector2) -> bool:
	for tetromino_piece in other_pieces:
		for piece in pieces:
			if starting_global_position + piece.position + direction * piece.get_size().x == tetromino_piece.global_position:
				return true
	return false
	
func rotate_tetromino(direction: int):
	var original_rotation_index = rotation_index
	if tetromino_data.tetromino_type == Shared.Tetromino.O:
		return
	
	apply_rotation(direction)
	rotation_index = wrap(rotation_index + direction, 0, 4)
	
	if !test_wall_kicks(rotation_index, direction):
		rotation_index = original_rotation_index
		apply_rotation(-direction)
		
	hard_drop_ghost.call_deferred()
	

func test_wall_kicks(rotation_index: int, rotation_direction: int): 
	var wall_kick_index = get_wall_kick_index(rotation_index, rotation_direction)
	
	for i in wall_kicks[0].size(): 
		var translation = wall_kicks[wall_kick_index][i]
		if move(translation):
			return true
		
	return false


func get_wall_kick_index(rotation_index: int, rotation_direction: int):
	var wall_kick_index = rotation_index * 2
	if rotation_direction < 0:
		wall_kick_index -= 1
	return wrap(wall_kick_index, 0, wall_kicks.size())
	

func apply_rotation(direction: int):
		
	var rotation_matrix
	if direction == 1: 
		rotation_matrix = Shared.clockwise_rotation_matrix
	else:
		rotation_matrix = Shared.counter_clockwise_rotation_matrix
		
	var tetromino_cells = Shared.cells[tetromino_data.tetromino_type]
	
	for i in tetromino_cells.size():
		var cell = tetromino_cells[i]
		var coordinates = rotation_matrix[0] * cell.x + rotation_matrix[1] * cell.y
		tetromino_cells[i] = coordinates
		
	for i in pieces.size():
		var piece = pieces[i]
		piece.position = tetromino_cells[i] * piece.get_size()
		
		
func on_timer_timeout():
	if mode == modes.FLOATING:
		return
		
	var should_lock = !move(Vector2.DOWN)
	if should_lock:
		lock()
	

func hard_drop():
	if mode == modes.FLOATING:
		lock()
		return
		
	while(move(Vector2.DOWN)):
		continue
	lock()

func hard_drop_golden():
	#var final_hard_drop_position
	#var golden_position_update = calculate_global_position(Vector2.DOWN, global_position)
	#
	#while golden_position_update != null:
		#golden_position_update = calculate_global_position(Vector2.DOWN, ghost_position_update)
	pass 

func hard_drop_ghost():
	if !ghost: 
		return 
		
	var final_hard_drop_position
	var ghost_position_update = calculate_global_position(Vector2.DOWN, global_position)
	
	while ghost_position_update != null:
		ghost_position_update = calculate_global_position(Vector2.DOWN, ghost_position_update)
		if ghost_position_update != null:
			final_hard_drop_position = ghost_position_update
	
	if final_hard_drop_position:
		var children = get_children().filter(func(c): return c is Piece)
		
		var pieces_position = []
		
		for i in children.size():
			var piece_position = children[i].position
			pieces_position.append(piece_position)
		
		ghost_tetromino.set_ghost_tetromino(final_hard_drop_position, pieces_position)
	
	return final_hard_drop_position


func lock():
	timer.stop()
	lock_tetromino.emit(self)
	set_process_input(false)
	if ghost:
		ghost_tetromino.queue_free()
