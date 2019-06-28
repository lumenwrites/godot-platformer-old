extends Node2D
export var starting_lives = 3
var lives
var coins = 0

func _ready():
	Global.GameState = self
	lives = starting_lives
	update_GUI()
	
func hurt():
	lives -= 1
	update_GUI()
	if lives < 0:
		end_game()

func update_GUI():
	Global.GUI.update_GUI(lives)
	
func end_game():
	# get_tree().change_scene("res://Scenes/GameOver.tscn")
	get_tree().change_scene(Global.Level1)

func coin_up():
	coins += 1
	if coins > 3:
		coins = 0
		lives += 1
		update_GUI()