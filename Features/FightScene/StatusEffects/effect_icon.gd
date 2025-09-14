extends TextureRect

var effect_data: StatusEffect

func setup(effect: StatusEffect):
	effect_data = effect
	self.texture = load("res://Images/action_icons/%s.png"% effect_data.icon_name)
	self.tooltip_text = str(effect_data.description) + " - " + str(effect_data.when_active)
