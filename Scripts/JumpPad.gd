extends Area2D

func _ready():
	pass


func _on_JumpPad_body_entered(body):
	$AnimationPlayer.play("bounce")
	Global.Player.boost()