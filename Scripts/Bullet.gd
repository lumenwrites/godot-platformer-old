extends Area2D

const SPEED = 200
var ypos = Vector2()

func _ready():
	# Once bullet is spawned, save it's y position, so it doesn't keep following the gun animation
	ypos = global_position.y
	
func _physics_process(delta):
	# Move to the right
	position.x += SPEED * delta
	# Maintain y position, don't follow the cannon movement.
	global_position.y = ypos
	# Once bullet hits something
	manage_collision()
	# Delete bullet once it leaves screen
	if not $VisibilityNotifier2D.is_on_screen():
		queue_free()
		
func manage_collision():
	var collider = get_overlapping_bodies()
	# Loop through objects it collides with
	for object in collider:
		if object == Global.Player:
			Global.GameState.hurt()
		# Delete bullet after collision
		queue_free()