extends Node2D


@onready var player_deck_reference = $"../PlayerDeck"
@onready var player_hand_reference = $"../PlayerHand"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(len(player_hand_reference.player_hand), player_hand_reference.max_hand_cards):
		player_deck_reference.draw_card()
		await get_tree().create_timer(0.1).timeout


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
