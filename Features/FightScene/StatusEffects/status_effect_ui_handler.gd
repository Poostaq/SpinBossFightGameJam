extends Node

const STATUS_EFFECT_ICON_SCENE_PATH = "res://Features/FightScene/StatusEffects/StatusEffectIcon.tscn"


func _on_status_effect_added(effect: StatusEffect):
	var icon = preload(STATUS_EFFECT_ICON_SCENE_PATH).instantiate()
	icon.setup(effect)
	self.add_child(icon)
	effect.icon_reference = icon

func _on_status_effect_removed(effect: StatusEffect):
	if effect.icon_reference and effect.icon_reference.is_inside_tree():
		effect.icon_reference.queue_free()
