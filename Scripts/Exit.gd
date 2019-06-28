extends Area2D

func _on_Exit_body_entered(body):
	Global.GameState.end_game()