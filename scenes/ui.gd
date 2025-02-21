extends CanvasLayer


class_name UI
@onready var center_container: CenterContainer = $CenterContainer
@onready var button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Button
@onready var music_manager: Node = $"../MusicManager"

func _ready() -> void:
	button.pressed.connect(on_button_pressed)

func show_game_over():
	center_container.show()

func on_button_pressed():
	music_manager.reset()
	get_tree().reload_current_scene()
