extends Node

@onready var player: Node = %Player
@onready var enemy = $"Enemy"
@onready var ui_animator = $"UIAnimator"

@onready var player_ui = $"UI/PlayerUI"
@onready var enemy_ui = $"UI/EnemyUI"
@onready var cassette_manager: Node2D = %CassetteManager
@onready var eject_button = $"UI/PlayerUI/EjectButton"
@onready var commit_button = $"UI/PlayerUI/CommitSequence"

enum BattlePhase { SELECTION, COMMIT, ACTING, RESOLUTION }
var current_phase: BattlePhase = BattlePhase.SELECTION

func _ready():
	print("Starting the fight")
	player.prepare_hand()	
	enemy.prepare_hand("hound")
	start_selection_phase()


func start_selection_phase():
	current_phase = BattlePhase.SELECTION
	enemy.select_cassettes_for_sequence()


# func check_if_ready():
# 	if player.has_selected_required_cassettes() and enemy.has_selected_required_cassettes():
# 		disable_commit_button(false)
# 	else:
# 		disable_commit_button(true)


func disable_commit_button(disabled: bool):
	commit_button.disabled = disabled

func disable_eject_button(disabled: bool):
	eject_button.disabled = disabled

func _on_commit_sequence_pressed() -> void:
	print("[BattleManager] Commit pressed!")
	current_phase = BattlePhase.COMMIT
	ui_animator.close_slots()
	ui_animator.close_enemy_slots()
	cassette_manager.deactivate_cassettes(true)
	disable_commit_button(true)
	disable_eject_button(true)
	start_acting_phase()


func start_acting_phase():
	current_phase = BattlePhase.ACTING
	ui_animator.present_mini_cassettes()


func _on_cassettes_presentation_finished():
	print("[BattleManager] Cassettes presentation done. Now resolve actions.")
	resolve_actions()


func resolve_actions():
	current_phase = BattlePhase.RESOLUTION
	apply_cassette_effects()
	if fight_is_over():
		end_fight()
	else:
		start_selection_phase()


func apply_cassette_effects():
	pass


func fight_is_over() -> bool:
	if player.health <= 0 or enemy.health <= 0:
		return true
	return false


func end_fight():
	print("[BattleManager] Fight is over!")
