extends Node

class_name MusicManager 

@export var streamPlayer: AudioStreamPlayer
var interactive: AudioStreamInteractive
var stream: AudioStreamSynchronized

@export var timer: Timer

@export var intensity: float = -60.0
@export var craziness: float = -60.0
@export var serenity: float = 0.0

@export var board: Board

var tweens: Dictionary  # Store tweens for each layer

func reset(): 
	intensity = -60
	craziness = -60 
	serenity = 0
	_on_timer_timeout()


func _ready() -> void:
	timer.timeout.connect(_on_timer_timeout)

	if streamPlayer:
		interactive = streamPlayer.stream
		if interactive and interactive is AudioStreamInteractive:
			stream = interactive.get_clip_stream(0)
			streamPlayer.play()


func _on_timer_timeout():
	if not stream:
		return
	
	var lines = board.get_number_of_lines()
	var pieces = board.get_number_of_pieces()

	lines = clamp(lines, 0, 20)  
	pieces = clamp(pieces, 0, 90) 

	var line_threshold = 5
	var piece_threshold = 20

	var line_boost_threshold = 10
	var piece_boost_threshold = 45

	var line_factor = 0.0
	if lines > line_threshold:
		line_factor = float(lines - line_threshold) / float(20 - line_threshold)

	var piece_factor = 0.0
	if pieces > piece_threshold:
		piece_factor = float(pieces - piece_threshold) / float(100 - piece_threshold)

	var boost_factor = 1.0
	if lines >= line_boost_threshold or pieces >= piece_boost_threshold:
		boost_factor = 1.5  

	var intensity_factor = ((line_factor * 0.7) + (piece_factor * 0.3)) * boost_factor
	intensity = lerp(-60.0, 0.0, intensity_factor)
	intensity = clamp(intensity, -60, 0)

	### === CRAZINESS === ###
	# Craziness increases both when there are many lines but few pieces (holes), and when many pieces exist (messy board)
	var hole_factor = 0.0
	if lines > line_threshold:
		hole_factor = float(lines - line_threshold) / float(20 - line_threshold)

	var piece_factor_full = float(pieces) / 100.0  # Normalizes pieces between 0 and 1

	var craziness_factor = (hole_factor + piece_factor_full) / 2.0  # Balanced approach

	craziness = lerp(-60.0, 0.0, craziness_factor * 1.5)  # Scaling for a faster effect
	craziness = clamp(craziness, -60, 0)

	# Debugging prints
	print("Lines:", lines, " Pieces:", pieces, " Intensity:", intensity, " Craziness:", craziness)

	# Apply volume changes
	_tween_volume(0, serenity)
	_tween_volume(1, craziness)
	_tween_volume(2, intensity)


func _tween_volume(layer: int, target_volume: float):
	var current_volume = stream.get_sync_stream_volume(layer)
	if current_volume == target_volume:
		return  # Skip if no change needed

	# Stop existing tween if it exists
	if tweens.has(layer):
		tweens[layer].kill()

	# Create new tween
	var tween = get_tree().create_tween()
	tweens[layer] = tween
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_SINE)

	# Smoothly transition to the new volume
	tween.tween_method(
		func(v): stream.set_sync_stream_volume(layer, v),
		current_volume,  
		target_volume,  
		2.0  # Duration (2 seconds)
	)
