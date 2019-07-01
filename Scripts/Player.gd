extends KinematicBody2D

const MAX_SPEED = 1500
const ACCELERATION = 5000
const DECELERATION = 5000
const GRAVITY = 5000
const UP = Vector2(0,-1)
const JUMP_SPEED = 500
const JUMP_ACCELERATION = 120
const JUMP_BOOST = 2 # Multiplier for jump pads
const DASH_SPEED = 1400
var speed = 0
var velocity = Vector2()
export var world_limit = 3000

func _ready():
	Global.Player = self
	
	
func _physics_process(delta):
	update_velocity(delta)
	
func _process(delta):
	$AnimatedSprite.updateanim(velocity)
	
func update_velocity(delta):
	# delta is amount of time since the last frame
	fall(delta)	
	run(delta)
	jump(delta)
	decelerate(delta)
	dash(delta)
	move_and_slide(velocity, UP)
	
	



func run(delta):		

	# Accelerate (capped at max speed)
	if velocity.x < MAX_SPEED and Input.is_action_pressed("ui_right"): 
		velocity.x += ACCELERATION*delta
	if velocity.x > -MAX_SPEED and Input.is_action_pressed("ui_left"): 
		velocity.x -= ACCELERATION*delta

	Global.HUD.update_HUD("velocity.x " + str(velocity.y))

func decelerate(delta):
	# friction simply modifies velocity in the opposite direction
	velocity.x = velocity.x * 0.9
	
	# Decelerate, simply subtract deceleration from velocity until it reaches 0
	# I decelerate as long as I'm not pressing accelerate buttton
	# It's a separate if, because if I want to move in the opposite direction, deceleration will be applied on top of acceleration
#	if velocity.x > 0 and not Input.is_action_pressed("ui_right"):
#		velocity.x -= DECELERATION*delta
#		if velocity.x < 0: velocity.x = 0 # If I have subtracted too much and it's below 0 now, set it to 0
#	elif velocity.x < 0 and not Input.is_action_pressed("ui_left"):
#		velocity.x += DECELERATION*delta
#		if velocity.x > 0: velocity.x = 0

# fit numbers in range
func fit(value, oldMin, oldMax, newMin, newMax):
    # Figure out how 'wide' each range is
    var oldSpan = oldMax - oldMin
    var newSpan = newMax - newMin

    # Convert the left range into a 0-1 range (float)
    var valueScaled = float(value - oldMin) / float(oldSpan)

    # Convert the 0-1 range into a value in the right range.
    return newMin + (valueScaled * newSpan)	
	
const JUMP_TIME = 0.5
var jumpTimer = JUMP_TIME
var isJumping = false
var canJump = false
const JUMP_MAX_AIRBORNE_TIME = 0.2
var on_air_time = 0

func jump(delta):
	Global.HUD.update_HUD("velocity.y " + str(velocity.y))
	
	# Coyote time is when you press jump slightly too late after falling off a ledge, but you jump anyway. 
	# I can jump when Im on the floor, or if I just fell off the ledge, so Im in air just for a bit and falling down
	canJump = is_on_floor() or (on_air_time < JUMP_MAX_AIRBORNE_TIME and velocity.y > 0)
	# Start jumping. Add initial velocity, and start jump timer
	if canJump  and Input.is_action_pressed("ui_jump"):
		velocity.y = -JUMP_SPEED
		isJumping = true
		jumpTimer = JUMP_TIME
	
	if isJumping:
		# Keep moving player up, lose jump speed as timer runs out.
		velocity.y -= JUMP_ACCELERATION * fit(jumpTimer,0, JUMP_TIME, 0, 1)
		# Increment jump timer
		jumpTimer -= delta
		# Stop jumping when button is released or was pressed for longer than 1 second
		if Input.is_action_just_released("ui_jump") or jumpTimer < 0:
			isJumping = false

var dashDirection = Vector2()
var canDash = true
func dash(delta):
	dashDirection.x = 0
	dashDirection.y = 0
	if Input.is_action_pressed("ui_right"): dashDirection.x = 1
	if Input.is_action_pressed("ui_left"): dashDirection.x = -1
	if Input.is_action_pressed("ui_up"): dashDirection.y = -1
	if Input.is_action_pressed("ui_down"): dashDirection.y = 1
	dashDirection = dashDirection.normalized()
	if Input.is_action_pressed("ui_dash") and canDash: 	
		velocity.x += dashDirection.x * DASH_SPEED
		velocity.y += dashDirection.y * DASH_SPEED * 2 # dash up feels smaller for some reason
		canDash = false
		print("Dash")
		print(dashDirection.x)
		print(dashDirection.y)
		print(canDash)
	

func boost():
	velocity.y = -1500

func fall(delta):
	if is_on_ceiling():
		velocity.y = 0
	if is_on_floor():
		# recharge dash
		canDash = true
		velocity.y = 0
		on_air_time = 0
	else:
		# move_and_slide already multiplies thingamabob by delta
		# this multiplies by delta second time, because that's how acceleration works
		velocity.y += GRAVITY * delta
		on_air_time += delta
	