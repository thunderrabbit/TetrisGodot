extends Sprite

# class member variables go here, for example:
var sprite_type

var typeset = [
	"dog",
	"cat",
	"pig",
	"sheep"
]

var colorset = [
	Color(0.962593, 0.499035, 0.517964), 
	Color(0.962593, 0.95568, 0.517964), 
	Color(0.484998, 0.95568, 0.517964), 
	Color(0.484998, 0.480191, 0.932654)
]

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	print("hey I am _ready")

func set_type_ordinal(my_type_ordinal):
	sprite_type = typeset[my_type_ordinal]

	# set the color
	set_modulate(colorset[my_type_ordinal])

	print("hey I am ", sprite_type)
