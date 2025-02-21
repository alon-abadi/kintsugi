extends Area2D

class_name Piece

@export var sprite_2d: Sprite2D
@export var collision_shape: CollisionShape2D
@onready var gold: Sprite2D = $Gold
@onready var cracked: Sprite2D = $Cracked

	
func set_texture(texture: Texture2D): 
	sprite_2d.texture = texture
	
func break_tile():
	cracked.set_visible(true)
	sprite_2d.set_visible(false)
	
	
func fill_with_gold():
	gold.set_visible(true)
	
func get_size():
	return collision_shape.shape.get_rect().size
