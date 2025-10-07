extends TextureRect

var effect_data: StatusEffect
@onready var animation_player = get_node("AnimationPlayer")


func setup(effect: StatusEffect):
	effect_data = effect
	texture = load("res://Images/action_icons/%s.png"% effect_data.icon_name)
	tooltip_text = str(effect_data.description) + " - " + str(effect_data.when_active)

