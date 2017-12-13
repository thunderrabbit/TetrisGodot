extends Area2D

# object type is parenter than the sprite node
var sprite_type

var typeset = [
	"dog",
	"cat",
	"pig",
	"sheep"
]

func set_type_ordinal(my_type_ordinal):
	sprite_type = typeset[my_type_ordinal]
	get_node("Sprite").set_type_ordinal(my_type_ordinal)
	print("hey I am ", sprite_type)
	pass

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass


func _on_Control_mouse_enter():
	print("on Control enter", sprite_type)
	pass # replace with function body


func _on_Control_mouse_exit():
	print("on Control exit", sprite_type)
	pass # replace with function body
