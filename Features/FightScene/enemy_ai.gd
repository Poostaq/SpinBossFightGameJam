# Enemy.gd  
# Coordinates AI logic and UI handling without directly managing UI components.
extends Node2D

@onready var character_logic: Node = $CharacterLogic
@onready var ui_handler: Node = $StatusEffectUIHandler
@onready var total_fuel_spent_label: Label = $"../FuelSpent/Sprite2D/FuelSpent"
@onready var ai_controller: Node = $AIController  # Handles decision-making for the enemy

func _ready():
	ai_controller.action_decided.connect(_on_action_decided)
	ai_controller.select_cassettes_for_sequence()

func apply_status_effect(effect: StatusEffect):
	character_logic.add_status_effect(effect)

func remove_status_effect(identifier: String):
	character_logic.remove_status_effect(identifier)

func update_fuel_display():
	total_fuel_spent_label.text = str(character_logic.total_fuel_spent)

func _on_action_decided(action_data):
	# Handle the AI's decided action (e.g., select cassette, perform attack)
	character_logic.update_fuel_spent(action_data.fuel_cost)
	update_fuel_display()

	for effect in action_data.status_effects_to_apply:
		apply_status_effect(effect)
