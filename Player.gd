# Compared to the grid example (final/06), only a few lines changed
# The Grid (TileMap) node supports isometric projection out of the box, 
# but we still have to calculate isometric motion by ourselves.
# The player has a cartesian_to_isometric method that converts the coordinates,
# explained in details in the Intro to Isometric Worlds tutorial (https://youtu.be/KvSjJ-kdGio)
extends KinematicBody2D

var direction = Vector2()

const MAX_SPEED = 1200

var speed = 0
var motion = Vector2()

var target_pos = Vector2()
var target_direction = Vector2()
var is_moving = false

var type
var grid


func cartesian_to_isometric(vector):
	return Vector2(vector.x - vector.y, (vector.x + vector.y) / 2)

func _ready():
	# The Player is now a child of the YSort node, so we have to go 1 more step up the node tree
	grid = get_parent().get_parent()
	type = grid.PLAYER
	set_physics_process(true)  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review


func _physics_process(delta):  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
	direction = Vector2()
	speed = 0

	if Input.is_action_pressed("move_up"):
		direction.y = -1
	elif Input.is_action_pressed("move_down"):
		direction.y = 1

	if Input.is_action_pressed("move_left"):
		direction.x = -1
	elif Input.is_action_pressed("move_right"):
		direction.x = 1
	elif Input.is_mouse_button_pressed(1):
		#direction = get_viewport().get_mouse_position()
		direction = get_local_mouse_position()
		# compensate for isometric height offset to allow diagonal movement and correct vertical
		direction = direction - grid.tile_offset
		direction.x = int(round(direction.x))/64
		direction.y = int(round(direction.y))/32
		print(direction)
	if not is_moving and direction != Vector2():
		target_direction = direction.normalized()
		if grid.is_cell_vacant(get_position(), direction):  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
			target_pos = grid.update_child_position(get_position(), direction, type)  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
			is_moving = true
	elif is_moving:
		speed = MAX_SPEED
		# We have to convert the player's motion to the isometric system.
		# The target_direction is normalized a few lines above so the player moves at the same speed in all directions.
		motion = cartesian_to_isometric(speed * target_direction * delta)

		var pos = get_position()  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
		var distance_to_target = pos.distance_to(target_pos)
		var move_distance = motion.length()

		# In the previous example, the player could land on floating positions
		# We force him to stop exactly on the target by setting the position instead of using the move method
		# As the grid handles the "collisions", we can use the two functions interchangeably:
		# move_and_collide(motion) <=> set_position(get_position() + motion)  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
		if move_distance > distance_to_target:
			set_position(target_pos)  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
			is_moving = false
		else:
			move_and_collide(motion)  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review

