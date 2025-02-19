extends CanvasLayer


class_name UI
@onready var center_container: CenterContainer = $CenterContainer
@onready var button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button.pressed.connect(on_button_pressed)

func show_game_over():
	center_container.show()

func on_button_pressed():
	get_tree().reload_current_scene()
