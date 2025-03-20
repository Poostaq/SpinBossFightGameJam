extends Node

var cassettes = {}       # Holds all cassette definitions (replacing CassetteDatabase.cassettes)
var effects = {}         # Holds all status effect definitions (replacing StatusEffectDatabase.effects)
var boss_decks = {}      # Holds boss decks if needed (can pull from your existing boss_decks)

func _ready():
	load_all_data()

func load_all_data():
	load_cassettes()
	load_status_effects()
	load_boss_decks()

func load_cassettes():
	var file = FileAccess.open("res://Data/cassettes.json", FileAccess.READ)
	if file:
		cassettes = JSON.parse_string(file.get_as_text())
	else:
		push_error("Failed to load cassettes.json")
func load_status_effects():
	var file = FileAccess.open("res://Data/status_effect.json", FileAccess.READ)
	if file:
		effects = JSON.parse_string(file.get_as_text())
	else:
		push_error("Failed to load status_effects.json")

func load_boss_decks():
	var file = FileAccess.open("res://Data/boss_decks.json", FileAccess.READ)
	if file:
		boss_decks = JSON.parse_string(file.get_as_text())
	else:
		push_error("Failed to load boss_decks.json")

# Convenience methods
func get_cassette(cassette_name: String):
	return cassettes.get(cassette_name)

func get_effect(effect_name: String):
	return effects.get(effect_name)

func get_boss_deck(boss_name: String):
	return boss_decks.get(boss_name)
