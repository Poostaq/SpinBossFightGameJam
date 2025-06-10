extends Control

const ALL_MOVE_BLOCK = preload("res://Images/action_icons/all_move_block.png")
const ALL_SIDES_ATTACK = preload("res://Images/action_icons/all_sides_attack.png")
const ATTACK = preload("res://Images/action_icons/attack.png")
const ATTACK_ALL_SIDES = preload("res://Images/action_icons/attack_all_sides.png")
const ATTACK_ALL_SIDES_BLOCK = preload("res://Images/action_icons/attack_all_sides_block.png")
const ATTACK_BACK_AND_FRONT_BLOCK = preload("res://Images/action_icons/attack_back_and_front_block.png")
const ATTACK_BACK_AND_SIDES_BLOCK = preload("res://Images/action_icons/attack_back_and_sides_block.png")
const ATTACK_BACK_BLOCK = preload("res://Images/action_icons/attack_back_block.png")
const ATTACK_FRONT_AND_SIDES_BLOCK = preload("res://Images/action_icons/attack_front_and_sides_block.png")
const ATTACK_FRONT_BLOCK = preload("res://Images/action_icons/attack_front_block.png")
const ATTACK_SIDE_BLOCK = preload("res://Images/action_icons/attack_side_block.png")
const A_SIDE = preload("res://Images/action_icons/a_side.png")
const BACK = preload("res://Images/action_icons/back.png")
const BACK_AND_FRONT = preload("res://Images/action_icons/back_and_front.png")
const BURN_ICON = preload("res://Images/action_icons/burn icon.png")
const B_SIDE = preload("res://Images/action_icons/b_side.png")
const CONDITION = preload("res://Images/action_icons/condition.png")
const DEFENCE = preload("res://Images/action_icons/defence.png")
const DISCARD = preload("res://Images/action_icons/discard.png")
const FRONT = preload("res://Images/action_icons/front.png")
const INFINITE = preload("res://Images/action_icons/infinite.png")
const INFINITE_VERSUS = preload("res://Images/action_icons/infinite_versus.png")
const LINE_UP_BLOCK = preload("res://Images/action_icons/line up block.png")
const LINE_UP = preload("res://Images/action_icons/line_up.png")
const NEXT_TURN = preload("res://Images/action_icons/next turn.png")
const NEXT_TURN_VERSUS = preload("res://Images/action_icons/next_turn_versus.png")
const OVERTAKE = preload("res://Images/action_icons/overtake.png")
const OVERTAKE_BLOCK = preload("res://Images/action_icons/overtake_block.png")
const REFLECT_DAMAGE = preload("res://Images/action_icons/reflect_damage.png")
const SIDE = preload("res://Images/action_icons/side.png")
const SIDE_AND_FRONT = preload("res://Images/action_icons/side_and_front.png")
const SLOW_DOWN = preload("res://Images/action_icons/slow_down.png")
const SLOW_DOWN_BLOCK = preload("res://Images/action_icons/slow_down_block.png")
const SPECIAL = preload("res://Images/action_icons/special.png")
const STOP = preload("res://Images/action_icons/stop.png")
const THIS_TURN = preload("res://Images/action_icons/this_turn.png")
const THIS_TURN_VERSUS = preload("res://Images/action_icons/this_turn_versus.png")
const VERSUS = preload("res://Images/action_icons/versus.png")

var ICON_LOOKUP := {
	"ALL_MOVE_BLOCK" : ALL_MOVE_BLOCK,
	"ALL_SIDES_ATTACK" : ALL_SIDES_ATTACK,
	"ATTACK" : ATTACK,
	"ATTACK_ALL_SIDES" : ATTACK_ALL_SIDES,
	"ATTACK_ALL_SIDES_BLOCK" : ATTACK_ALL_SIDES_BLOCK,
	"ATTACK_BACK_AND_FRONT_BLOCK" : ATTACK_BACK_AND_FRONT_BLOCK,
	"ATTACK_BACK_AND_SIDES_BLOCK" : ATTACK_BACK_AND_SIDES_BLOCK,
	"ATTACK_BACK_BLOCK" : ATTACK_BACK_BLOCK,
	"ATTACK_FRONT_AND_SIDES_BLOCK" : ATTACK_FRONT_AND_SIDES_BLOCK,
	"ATTACK_FRONT_BLOCK" : ATTACK_FRONT_BLOCK,
	"ATTACK_SIDE_BLOCK" : ATTACK_SIDE_BLOCK,
	"A_SIDE" : A_SIDE,
	"BACK" : BACK,
	"BACK_AND_FRONT" : BACK_AND_FRONT,
	"BURN_ICON" : BURN_ICON,
	"B_SIDE" : B_SIDE,
	"CONDITION" : CONDITION,
	"DEFENCE" : DEFENCE,
	"DISCARD" : DISCARD,
	"FRONT" : FRONT,
	"INFINITE" : INFINITE,
	"INFINITE_VERSUS" : INFINITE_VERSUS,
	"LINE_UP_BLOCK" : LINE_UP_BLOCK,
	"LINE_UP" : LINE_UP,
	"NEXT_TURN" : NEXT_TURN,
	"NEXT_TURN_VERSUS" : NEXT_TURN_VERSUS,
	"OVERTAKE" : OVERTAKE,
	"OVERTAKE_BLOCK" : OVERTAKE_BLOCK,
	"REFLECT_DAMAGE" : REFLECT_DAMAGE,
	"SIDE" : SIDE,
	"SIDE_AND_FRONT" : SIDE_AND_FRONT,
	"SLOW_DOWN" : SLOW_DOWN,
	"SLOW_DOWN_BLOCK" : SLOW_DOWN_BLOCK,
	"SPECIAL" : SPECIAL,
	"STOP" : STOP,
	"THIS_TURN" : THIS_TURN,
	"THIS_TURN_VERSUS" : THIS_TURN_VERSUS,
	"VERSUS" : VERSUS,
	}

func prepare_icon(icons: Array[Dictionary]):
	for icon in icons:
		if ICON_LOOKUP.has(icon):
			var tex : Texture2D = ICON_LOOKUP[icon]
			# Now you can do something with “tex” (e.g. assign it to a TextureRect)
			print("Found texture for '%s': %s" % [icon, tex])
		else:
			push_error("'%s' is not in ICON_LOOKUP!" % icon)
		
