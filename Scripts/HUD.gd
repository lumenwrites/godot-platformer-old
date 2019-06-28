extends Label

func _ready():
	Global.HUD = self
	
func update_HUD(text):
	self.text = str(text) # + '\n' + self.text