class_name StatusEffectManager
extends Node

var active_effects: Dictionary  # Stores effects, keys = player/enemy, values = array of StatusEffect

func _init():
	active_effects = {
		0: [],  # Effects on enemy
		1: []   # Effects on player
	}

# Apply a new effect
func apply_effect(target: int, effect: StatusEffect):
	active_effects[target].append(effect)

# Remove expired effects
func update_effects():
	for target in active_effects.keys():
		for effect in active_effects[target].duplicate():
			if effect.duration > 0:
				effect.duration -= 1
			if effect.duration == 0:
				active_effects[target].erase(effect)

# Trigger effects at the right time
func trigger_effects(trigger_event: String, target: int):
	for effect in active_effects[target]:
		if effect.when_active == trigger_event:
			_activate_effect(effect, target)

# Handles what happens when an effect activates
func _activate_effect(effect: StatusEffect, target: int):
	match effect.effect_name:
		"burn":
			_apply_damage(target, effect.value)
		"damage_boost":
			_increase_attack(target, effect.value)
	# Play animations or sound feedback
	if effect.animation_to_play:
		_play_animation(effect.animation_to_play, target)

# Example functions that modify game state
func _apply_damage(target: int, amount: int):
	print("Applying", amount, "damage to", target)

func _increase_attack(target: int, amount: int):
	print("Increasing attack by", amount, "for", target)

func _play_animation(animation: String, target: int):
	print("Playing animation", animation, "for", target)
