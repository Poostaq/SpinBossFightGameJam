extends TextureRect

var effect_data: StatusEffect

func setup(effect: StatusEffect):
	effect_data = effect
	self.texture = load("res://Images/vfx/Icons/%s.png"% effect_data.icon_name)
	self.tooltip_text = str(effect_data.value)
	effect_data.expired.connect(_on_effect_expired)

func _on_effect_expired():
	queue_free()  # Removes the icon when the effect expires
