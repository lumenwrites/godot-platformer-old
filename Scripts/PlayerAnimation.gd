extends AnimatedSprite

func updateanim(velocity):
	return false
	
	if velocity.y < 0:
		play("jump")	
	#elif velocity.x > 0:
		# play("run")
		# flip_h = false		
	#elif velocity.x < 0:
		# play("run")
		# flip_h = true
	else:
		play("idle")
		flip_h = false		
