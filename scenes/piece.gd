extends Area2D

class_name Piece

@export var sprite_2d: Sprite2D
@export var collision_shape: CollisionShape2D

	
func set_texture(texture: Texture2D): 
	sprite_2d.texture = texture
	

func get_size():
	return collision_shape.shape.get_rect().size
