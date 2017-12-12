
extends Node2D

export var board_width = 10
export var board_height = 18

export var count_down = 1.5		# count down for gravity
var counter 			# counter for count_down

var gameover			# is the game over?

var current_block		# current block

const width = 30		# matches block.png actual size
var board = {}			# board of board_width x board_height

var player = Vector2()	# player position in x,y index
var player_sprites		# player's block sprite (there are four of them)

var can_move = false	# if the player can move or not
var drop_confirm = false		# if the space bar is pressed for confirming to drop the player directly

var block_sprite = preload("res://SubScenes/block.xml")

var colorset = [
	Color(0.962593, 0.499035, 0.517964), 
	Color(0.962593, 0.95568, 0.517964), 
	Color(0.484998, 0.95568, 0.517964), 
	Color(0.484998, 0.480191, 0.932654)
]

var blockset = [
	# square
	[0, 0, 0, 0,
	 0, 1, 1, 0,
	 0, 1, 1, 0,
	 0, 0, 0, 0
	],
	# right L
	[0, 1, 0, 0,
	 0, 1, 0, 0,
	 0, 1, 1, 0, 
	 0, 0, 0, 0
	],
	# left L
	[0, 0, 1, 0,
	 0, 0, 1, 0,
	 0, 1, 1, 0,
	 0, 0, 0, 0
	],
	# right N
	[0, 1, 0, 0,
	 0, 1, 1, 0,
	 0, 0, 1, 0,
	 0, 0, 0, 0,
	],
	# left N
	[0, 0, 1, 0,
	 0, 1, 1, 0,
	 0, 1, 0, 0,
	 0, 0, 0, 0,
	],
	# line
	[0, 1, 0, 0,
	 0, 1, 0, 0,
	 0, 1, 0, 0,
	 0, 1, 0, 0,
	],
	# T 
	[0, 0, 0, 0,
	 1, 1, 1, 0,
	 0, 1, 0, 0,
	 0, 0, 0, 0
	]
]


func _ready():
	# show input info
	var input_info = get_node("../Control/InputInfo")
	input_info.add_text("W: Rotate\nA: Left\nD: Right\nS: Down\n\nSpace: Confirm/Restart")

	# randomize seed
	randomize()
	
	setup_board()
	new_player()
	counter = count_down
	
	set_process_input(true)
	set_process(true)
	

func _process(delta):

	# directly drop player down
	if drop_confirm:
		if check_movable(0, 1):
			move_player(0, 1)
		else:
			nail_player()
			new_player()
			drop_confirm = false
		return

	if can_move:
		if gameover:
			if Input.is_action_pressed("ui_accept"):
				setup_board()
				new_player()
				gameover = false
				can_move = false
			return
	
		if Input.is_action_pressed("ui_accept"):
			# confirm to drop player
			drop_confirm = true
			can_move = false
	
		if Input.is_action_pressed("ui_right"):
			if check_movable(1, 0):
				move_player(1, 0)
				can_move = false
			
		if Input.is_action_pressed("ui_left"):
			if check_movable(-1, 0):
				move_player(-1, 0)
				can_move = false
			
		if Input.is_action_pressed("ui_up"):
			# rotate player
			if check_rotatable():
				rotate_player()
				can_move = false
		
		if Input.is_action_pressed("ui_down"):
			if check_movable(0, 1):
				move_player(0, 1)
			else:
				nail_player()
				new_player()
			can_move = false
			counter = count_down  # reset counter
	
	if counter <= 0:
		if check_movable(0, 1):
			move_player(0, 1)
		else:
			nail_player()
			new_player()
		counter = count_down  # reset counter
	
	counter -= delta
	

func _input(event):
	if event.type == InputEvent.KEY and event.is_pressed() and !event.is_echo():
		can_move = true


# setup the board
func setup_board():
	# clear block sprites if existing
	var existing_sprites = get_node(".").get_children()
	for sprite in existing_sprites:
		sprite.queue_free()
		
	board = {}
	for i in range(board_width):
		for j in range(board_height):
			board[Vector2(i, j)] = null


# set game over sprites
func set_gameover_sprites():
	var existing_sprites = get_node(".").get_children()
	for sprite in existing_sprites:
		sprite.set_modulate(Color(0.339615, 0.340773, 0.339576))


# get a random block from blockset
func new_block():
    # See if it works to just have a single piece in the 4x4 block
    return [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]

# get a random color from colorset
func random_color():
	return colorset[randi() % colorset.size()]
	

# rotate block by counter-clockwise
func rotate_block(block):
	var b = Array()
	for i in [3, 2, 1, 0]:
		b.append(block[i])
		b.append(block[i+4])
		b.append(block[i+8])
		b.append(block[i+12])
	return b


# update player sprite display
func update_player_sprites(sprites):
	var index = 0
	for i in range(1):
		for j in range(1):
			if current_block[i+j*4] == 1:
				sprites[index].set_pos(Vector2(i*width + player.x*width, j*width + player.y*width))
				index += 1


# generate a new player
func new_player():
	# new player will be a random of four colors
	var color = random_color()

	# new player will be random of four shapes
	current_block = new_block()

	# select top center position
	player = Vector2(board_width/2-2, 0)

	# player_sprites will hold 1 blocks which represent our player
	player_sprites = []

	# instantiate four blocks for our player.  i is unused here
	for i in range(1):
		# instantiate a block
		var sprite = block_sprite.instance()
		# set the color
		sprite.set_modulate(color)
		# keep it in player_sprites so we can find them later
		player_sprites.append(sprite)
		# add it to scene
		add_child(sprite)

	# now arrange the blocks making up this player in the right shape
	update_player_sprites(player_sprites)

	# check game over
	for block in get_player_block_positions():
		if board[Vector2(block.x, block.y)] != null:
			game_over()
			return



# check game over
func game_over():
	gameover = true
	set_gameover_sprites()


# roate player
func rotate_player():
	current_block = rotate_block(current_block)
	# update sprite positions
	update_player_sprites(player_sprites)


# get player block poision by x,y index
func get_player_block_positions():
	var positions = []
	for i in range(4):
		for j in range(4):
			if current_block[i+j*4] == 1:
				positions.append(Vector2(player.x+i, player.y+j))
	return positions
				

# move player
func move_player(x, y):
	if player_sprites.size() == 0:
		return
	player.x += x
	player.y += y
	# update sprite positions
	update_player_sprites(player_sprites)
	
	
# check movable
func check_movable(x, y):
	var player_blocks = get_player_block_positions()
	
	if x != 0:
		for block in player_blocks:
			# check border
			if block.x + x >= board_width or block.x + x < 0:
				return false
			# check collision
			if board[Vector2(block.x+x, block.y)] != null:
				return false
	
	elif y > 0:
		return !check_ground()
	return true
	
	
# check hit ground or get fixed (collision)
func check_ground():
	for block in get_player_block_positions():
		# check ground
		if block.y + 1 >= board_height:
			return true
		# check getting fixed (collision)
		if board[Vector2(block.x, block.y+1)] != null:
			return true
	return false


# check rotatable
func check_rotatable():
	var next = rotate_block(current_block)
	for i in range(4):
		for j in range(4):
			if next[i+j*4] == 1:
				var board_x = player.x + i
				var board_y = player.y + j
				if board_x < 0 or board_x >= board_width or board_y >= board_height:
					return false
				if board[Vector2(board_x, board_y)] != null:
					return false
	return true
	

# nail player to board
func nail_player():
	var index = 0
	for block in get_player_block_positions():
		board[Vector2(block.x, block.y)] = player_sprites[index]
		player_sprites[index].set_pos(Vector2(block.x*width, block.y*width))
		index+=1
		
	check_bingo()


# check bingo
func check_bingo():
	var bingo_y = []
	# if the line is bingo, clear the line
	for block in get_player_block_positions():
		var bingo = true
		# check y index of board
		for x in range(board_width):
			if board[Vector2(x, block.y)] == null:
				bingo = false
				break
		if bingo:
			if not block.y in bingo_y:
				bingo_y.append(block.y)
				# clear the line
				for x in range(board_width):
					var sprite = board[Vector2(x, block.y)]
					sprite.queue_free()
					board[Vector2(x, block.y)] = null
	# move down the above blocks
	if bingo_y.size() > 0:
		move_gap(bingo_y)
	
	
# move down the blocks above empty lines that was remove by check_bingo
func move_gap(gap_lines):
	gap_lines.sort()
	gap_lines.invert()
	var move = 1
	var next_index = 0
	for y in range(gap_lines[0], 0, -1):
		# if y reaches the current examing bingo_y line, add next_index by 1
		if y == gap_lines[next_index] and next_index < gap_lines.size()-1:
			next_index += 1
				
		# find continuous bingo lines
		var tmp_index = next_index
		while move < gap_lines.size() and y - move == gap_lines[tmp_index]:
			move+=1
			tmp_index+=1
				
		# if (y - move) reaches top, exit
		if y - move < 0:
			break
				
		for x in range(board_width):
			board[Vector2(x, y)] = board[Vector2(x, y-move)]
			if board[Vector2(x, y)] != null:
				board[Vector2(x, y)].set_pos(Vector2(x * width, y * width))
			board[Vector2(x, y-move)] = null