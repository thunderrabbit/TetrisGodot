extends Sprite

# class member variables go here, for example:
var sprite_type

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	print("hey I am _ready")

func set_type(my_type):
	sprite_type = my_type
	print("hey I am ", sprite_type)
