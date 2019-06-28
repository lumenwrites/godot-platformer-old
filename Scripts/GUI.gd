extends CanvasLayer

func _ready():
	Global.GUI = self
	
func update_GUI(lives):
	$Banner/HBoxContainer/Label.text = str(lives)