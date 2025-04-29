extends Node

@onready var player: Node = $"../Player"
@onready var enemy: Node = $"../Enemy"
@onready var ui_animator: Node = $"../UIAnimator"
@onready var player_ui = $"../UI/PlayerUI"
@onready var enemy_ui = $"../UI/EnemyUI"

var enemy_name: String

enum BattlePhase { SELECTION, COMMIT, ACTING, RESOLUTION }
var current_phase: BattlePhase = BattlePhase.SELECTION

func _ready():
	print("[BattleManager] Ready! Starting fight...")
	player.prepare_hand()
	enemy.prepare_hand(enemy_name)
	start_selection_phase()

#
# SELECTION PHASE
# Player and Enemy choose cassettes.
#
func start_selection_phase():
	current_phase = BattlePhase.SELECTION
	enemy.select_cassettes()
	#check_if_ready()
	

func check_if_ready():
	if player.has_selected_required_cassettes() and enemy.has_selected_required_cassettes():
		enable_commit_button(true)
	else:
		enable_commit_button(false)

func enable_commit_button(enable: bool):
	player_ui.commit_button.disabled = not enable

#
# COMMIT PHASE
# Triggered when the player clicks the commit button
#
func on_commit_button_pressed():
	print("[BattleManager] Commit pressed!")
	current_phase = BattlePhase.COMMIT

	# Move on to the acting phase
	start_acting_phase()

#
# ACTING PHASE
# The cassettes are presented and eventually resolved
#
func start_acting_phase():
	current_phase = BattlePhase.ACTING

	# Gather cassettes to show
	var player_cassettes = player.get_chosen_cassettes()
	var enemy_cassettes = enemy.get_chosen_cassettes()

	# Present them with the UI animator and wait for the animation to finish
	present_cassettes_ui(player_cassettes, enemy_cassettes)
	
func present_cassettes_ui(player_cassettes, enemy_cassettes) -> void:
	ui_animator.presentation_finished.connect(
		self._on_cassettes_presentation_finished
	)
	ui_animator.present_cassettes(player_cassettes, enemy_cassettes)

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
