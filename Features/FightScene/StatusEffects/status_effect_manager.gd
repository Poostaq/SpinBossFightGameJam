class_name StatusEffectManager
extends Node

@onready var player_effects_area = $"../UI/PlayerUI/StatusEffectsArea"
@onready var enemy_effects_area = $"../UI/EnemyUI/StatusEffectsArea"

var active_effects: Dictionary = {
    GlobalEnums.PLAYER: {
        "this_turn": [],
        "next_turn": [],
        "permanent": [],
        "next_cassette": [],
        "next_attack": []
    },
    GlobalEnums.ENEMY: {
        "this_turn": [],
        "next_turn": [],
        "permanent": [],
        "next_cassette": [],
        "next_attack": []
    }
}

func move_next_turn_effects_to_this_turn():
    for target in [GlobalEnums.PLAYER, GlobalEnums.ENEMY]:
        active_effects[target]["this_turn"] = active_effects[target]["next_turn"]
        active_effects[target]["next_turn"] = []

func create_status_effect_element(cassette_action: Dictionary, status_effect_data: Array, effect_target: int) -> void:
    var effect_name = cassette_action.get("effect_name", "")
    if effect_name == "":
        print("Invalid or missing effect name:", effect_name)
        return

    var parent_node = player_effects_area if effect_target == GlobalEnums.PLAYER else enemy_effects_area

    var description_template = status_effect_data[2]
    var value = cassette_action.get("value", 0)
    var description = description_template
    if description_template.find("%s") != -1:
        description = description_template % str(int(value))

    var status_effect = StatusEffect.new()
    status_effect.effect_name = effect_name
    status_effect.icon_name = status_effect_data[0]
    status_effect.description = description
    status_effect.when_active = status_effect_data[1]
    status_effect.value = value
    status_effect.affected_target = cassette_action.get("affected_target", 0)

    var effect_icon_scene = load("res://Features/FightScene/StatusEffects/StatusEffectIcon.tscn")
    var effect_icon_instance = effect_icon_scene.instantiate()
    effect_icon_instance.setup(status_effect)
    add_status_effect(effect_target, status_effect)
    parent_node.add_child(effect_icon_instance)

func add_status_effect(target: int, status_effect: StatusEffect) -> void:
    match status_effect.when_active:
        "this_turn":
            active_effects[target]["this_turn"].append(status_effect)
        "next_turn":
            active_effects[target]["next_turn"].append(status_effect)
        "permanent":
            active_effects[target]["permanent"].append(status_effect)
        "next_cassette":
            active_effects[target]["next_cassette"].append(status_effect)
        "next_attack":
            active_effects[target]["next_attack"].append(status_effect)
        _:
            print("Unknown effect timing:", status_effect.when_active)

