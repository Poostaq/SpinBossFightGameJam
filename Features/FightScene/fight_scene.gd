extends Node

@onready var player: Node = %Player
@onready var enemy = $"Enemy"
@onready var ui_animator = $"UIAnimator"

@onready var player_ui = $"UI/PlayerUI"
@onready var enemy_ui = $"UI/EnemyUI"
@onready var cassette_manager: Node2D = %CassetteManager

enum BattlePhase { SELECTION, COMMIT, ACTING, RESOLUTION }
var current_phase: BattlePhase = BattlePhase.SELECTION

func _ready():
	print("[FightManager] Ready! Starting fight...")
	player.prepare_hand()
	enemy.prepare_hand("hound")
	start_selection_phase()

#
# SELECTION PHASE
# Player and Enemy choose cassettes.
#
func start_selection_phase():
	current_phase = BattlePhase.SELECTION
	
	enemy.select_cassettes_for_sequence()

func check_if_ready():
	# If both sides have selected 3 cassettes (example), we enable COMMIT in the UI
	if player.has_selected_required_cassettes() and enemy.has_selected_required_cassettes():
		enable_commit_button(true)
	else:
		enable_commit_button(false)

func enable_commit_button(enable: bool):
	# Let your PlayerUI or a shared commit button know it's clickable
	player_ui.commit_button.disabled = not enable

#
# COMMIT PHASE
# Triggered when the player clicks the commit button
#
func _on_commit_sequence_pressed() -> void:
	print("[BattleManager] Commit pressed!")
	current_phase = BattlePhase.COMMIT
	ui_animator.close_slots()
	ui_animator.close_enemy_slots()
	cassette_manager.deactivate_cassettes(true)
	start_acting_phase()

#
# ACTING PHASE
# The cassettes are presented and eventually resolved
#
func start_acting_phase():
	current_phase = BattlePhase.ACTING

	ui_animator.present_mini_cassettes()

func _on_cassettes_presentation_finished():
	print("[BattleManager] Cassettes presentation done. Now resolve actions.")
	resolve_actions()

#
# RESOLUTION PHASE
# Actually carry out the cassette actions (damage, status, etc.)
#
func resolve_actions():
	current_phase = BattlePhase.RESOLUTION

	# Example: apply cassette effects in order
	apply_cassette_effects()

	# Then check if the fight ends, or if we go another round
	if fight_is_over():
		end_fight()
	else:
		# If multiple rounds are possible, go back to selection
		start_selection_phase()

func apply_cassette_effects():
	# Minimal example
	# For each side's chosen cassettes, apply their effect to the other side
	# ...
	pass

func fight_is_over() -> bool:
	# Check player or enemy health from their scripts
	if player.health <= 0 or enemy.health <= 0:
		return true
	return false

func end_fight():
	print("[BattleManager] Fight is over!")
	# Possibly emit a signal for FightScene or GameManager
	# E.g.:
	# emit_signal("fight_complete")
	# Then you'd do any post-fight cleanup
