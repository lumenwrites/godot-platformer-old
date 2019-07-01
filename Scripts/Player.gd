extends KinematicBody2D

const MAX_SPEED = 1500
const ACCELERATION = 5000
const DECELERATION = 5000
const GRAVITY = 5000
const UP = Vector2(0,-1)
const JUMP_SPEED = 500
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

	
	
const JUMP_TIME = 0.5
var jumpTimer = JUMP_TIME
var isJumping = false

func jump(delta):
	Global.HUD.update_HUD("velocity.y " + str(velocity.y))
	# Start jumping. Add initial velocity, and start jump timer
	if is_on_floor() and Input.is_action_pressed("ui_jump"):
		velocity.y = -JUMP_SPEED*2
		isJumping = true
		jumpTimer = JUMP_TIME
	
	if isJumping:
		# Keep moving player up, lose jump speed as timer runs out.
		velocity.y = -JUMP_SPEED
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
	else:
		# move_and_slide already multiplies thingamabob by delta
		# this multiplies by delta second time, because that's how acceleration works
		velocity.y += GRAVITY * delta
	