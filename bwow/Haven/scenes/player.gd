extends CharacterBody2D

const SPEED = 180.0
const GROUND_DRAG = 0.1
const AIR_DRAG = 0.01
const JUMP_VELOCITY = 300.0
const JUMP_BOOST = 1
const BOUNCE_VELOCITY = 400.0
const WALLBUMP_MULT_GROUND = 0.6
const WALLBUMP_MULT_AIR = 0.8
const COYOTE_MAX = 5

func _physics_process(delta: float) -> void:
	
	var tileType
	
	var congratsStar: Sprite2D = $"../Congrats"
	
	if get_slide_collision_count() > 0:
		var collision = get_slide_collision(0)
		var collider = collision.get_collider()
		var colliderName= collider.name
		if colliderName == "TileMapLayer (Ground)":
			tileType = 1
		elif colliderName == "TileMapLayer (Ice)":
			tileType = 2
		elif colliderName == "TileMapLayer (Bounce)":
			tileType = 3
		elif colliderName == "End":
			congratsStar.visible = true
	else:
		tileType = 0
	
	var canJump = is_on_floor()
	
	if get_meta("GroundedAgo1") and COYOTE_MAX >= 1:
		canJump = true
	elif get_meta("GroundedAgo2") and COYOTE_MAX >= 2:
		canJump = true
	elif get_meta("GroundedAgo3") and COYOTE_MAX >= 3:
		canJump = true
	elif get_meta("GroundedAgo4") and COYOTE_MAX >= 4:
		canJump = true
	elif get_meta("GroundedAgo5") and COYOTE_MAX >= 5:
		canJump = true
	
	#Deal with wall collisions
	if is_on_wall() and is_on_floor():
		velocity.x = -1 * WALLBUMP_MULT_GROUND * get_meta("previousFrameVelo")
	elif is_on_wall():
		velocity.x = -1 * WALLBUMP_MULT_AIR * get_meta("previousFrameVelo")
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	var jumped
	if Input.is_action_just_pressed("jump") and canJump and not jumped:
		velocity.y = -1 * JUMP_VELOCITY
		velocity.x = velocity.x * JUMP_BOOST
		#Coyote Time Handler 2
		set_meta("GroundedAgo5", false)
		set_meta("GroundedAgo4", false)
		set_meta("GroundedAgo3", false)
		set_meta("GroundedAgo2", false)
		set_meta("GroundedAgo1", false)
		jumped = true
	else:
		jumped = false
	
	#Bouncy Block Code
	if tileType == 3 and is_on_floor():
		velocity.y = -1 * BOUNCE_VELOCITY
		velocity.x = velocity.x * JUMP_BOOST
		#Coyote Time Handler 3
		set_meta("GroundedAgo5", false)
		set_meta("GroundedAgo4", false)
		set_meta("GroundedAgo3", false)
		set_meta("GroundedAgo2", false)
		set_meta("GroundedAgo1", false)
		jumped = true
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction and is_on_floor() and velocity.x <= SPEED and tileType != 2:
		velocity.x = move_toward(velocity.x, direction * SPEED, (GROUND_DRAG * SPEED))
	elif is_on_floor() and tileType != 2:
		velocity.x = move_toward(velocity.x, 0, (GROUND_DRAG * max(SPEED, velocity.x)))
	elif direction and velocity.x <= SPEED:
		velocity.x = move_toward(velocity.x, direction * SPEED, (AIR_DRAG * SPEED))
	else:
		velocity.x = move_toward(velocity.x, 0, (AIR_DRAG * max(SPEED, velocity.x)))
	
	#Wall Collisions Part 2
	set_meta("previousFrameVelo", velocity.x)
	#Coyote Time Handler
	if not jumped:
		set_meta("GroundedAgo5", get_meta("GroundedAgo4"))
		set_meta("GroundedAgo4", get_meta("GroundedAgo3"))
		set_meta("GroundedAgo3", get_meta("GroundedAgo2"))
		set_meta("GroundedAgo2", get_meta("GroundedAgo1"))
		set_meta("GroundedAgo1", is_on_floor())
	
	move_and_slide()
