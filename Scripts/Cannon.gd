extends Node2D

var reloaded = true

func _process(delta):
	if $Barrel/RayCast2D.is_colliding():
		fire()
		
func fire():
	if reloaded:
		# Spawn bullet. At RayCast position.
		$Barrel/RayCast2D.add_child(load(Global.Bullet).instance())
		$Barrel/Timer.start()
		reloaded = false


func _on_Timer_timeout():
	reloaded = true
