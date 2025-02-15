extends Node

# [NAME, SIDE_A_DATA, SIDE_B_DATA]
var CASSETTES = {
	"Regular Attack" = ["Regular Attack", SIDE_A["Regular Attack"], SIDE_B["Regular Attack"]],
	"Quick Attack" = ["Quick Attack", SIDE_A["Quick Attack"], SIDE_B["Quick Attack"]],
	"Heavy Attack" = ["Heavy Attack", SIDE_A["Heavy Attack"], SIDE_B["Heavy Attack"]],
	"EMP" = ["EMP", SIDE_A["EMP"], SIDE_B["EMP"]],
	"Nitro" = ["Nitro", SIDE_A["Nitro"], SIDE_B["Nitro"]],
	"Emergency Brake" = ["Emergency Brake", SIDE_A["Emergency Brake"], SIDE_B["Emergency Brake"]],
	"Ram" = ["Ram", SIDE_A["Ram"], SIDE_B["Ram"]],
	"Shoot'em up" = ["Shoot'em up", SIDE_A["Shoot'em up"], SIDE_B["Shoot'em up"]],
	"Explosive Maneouver" = ["Explosive Maneouver", SIDE_A["Explosive Maneouver"], SIDE_B["Explosive Maneouver"]],
	"Honk Honk" = ["Honk Honk", SIDE_A["Honk Honk"], SIDE_B["Honk Honk"]],
	"Launcher Gallery" = ["Launcher Gallery", SIDE_A["Launcher Gallery"], SIDE_B["Launcher Gallery"]],
	"Hook, line and sinker" = ["Hook, line and sinker", SIDE_A["Hook, line and sinker"], SIDE_B["Hook, line and sinker"]],
	"Pew Pew" = ["Pew Pew", SIDE_A["Pew Pew"], SIDE_B["Pew Pew"]],
	"Letter D" = ["Letter D", SIDE_A["Letter D"], SIDE_B["Letter D"]],
	"Whatever" = ["Whatever", SIDE_A["Whatever"], SIDE_B["Whatever"]],
	"Big Refill" = ["Big Refill", SIDE_A["Big Refill"], SIDE_B["Big Refill"]],
	"Gimme Fuel" = ["Gimme Fuel", SIDE_A["Gimme Fuel"], SIDE_B["Gimme Fuel"]],
	"Oil Spill" = ["Oil Spill", SIDE_A["Oil Spill"], SIDE_B["Oil Spill"]],
	"Gimme Fire" = ["Gimme Fire", SIDE_A["Gimme Fire"], SIDE_B["Gimme Fire"]],
	"My name is Spike" = ["My name is Spike", SIDE_A["My name is Spike"], SIDE_B["My name is Spike"]],
	"Rail the Tail" = ["Rail the Tail", SIDE_A["Rail the Tail"], SIDE_B["Rail the Tail"]],
	"Another One" = ["Another One", SIDE_A["Another One"], SIDE_B["Another One"]],
	"Pit Maneouver" = ["Pit Maneouver", SIDE_A["Pit Maneouver"], SIDE_B["Pit Maneouver"]],
	"Bites the Dust" = ["Bites the Dust", SIDE_A["Bites the Dust"], SIDE_B["Bites the Dust"]],
	"Road Rage" = ["Road Rage", SIDE_A["Road Rage"], SIDE_B["Road Rage"]],
	"Burning Rubber" = ["Burning Rubber", SIDE_A["Burning Rubber"], SIDE_B["Burning Rubber"]],
	"Kickdown" = ["Kickdown", SIDE_A["Kickdown"], SIDE_B["Kickdown"]],
	"Hit me baby" = ["Hit me baby", SIDE_A["Hit me baby"], SIDE_B["Hit me baby"]],
	"Roadslinger" = ["Roadslinger", SIDE_A["Roadslinger"], SIDE_B["Roadslinger"]],
	"Drafting" = ["Drafting", SIDE_A["Drafting"], SIDE_B["Drafting"]],
	"Offence is Defence" = ["Offence is Defence", SIDE_A["Offence is Defence"], SIDE_B["Offence is Defence"]],
	"Run to Live" = ["Run to Live", SIDE_A["Run to Live"], SIDE_B["Run to Live"]],
	"Perfectly Balanced" = ["Perfectly Balanced", SIDE_A["Perfectly Balanced"], SIDE_B["Perfectly Balanced"]],
}
# [FUEL_COST, DESCRIPTION, [[MOVE_TYPE, VALUE, MOVE_TARGET_AREA, (optional)MOVE_INFO], TARGET], AFTER_PLAY, ACTION_ICON]
var SIDE_A = {
	
	"EMP" = [3, "Attak to the front. Disable enemy's next action.",
	[[GlobalEnums.ACTION_TYPE.ATTACK,2,"front","shoot"],
	[GlobalEnums.ACTION_TYPE.SPECIAL,"","front", "next_cassette_wont_work", GlobalEnums.AFFECTED_TARGET.TARGET]], 
	"burn", 
	"attack_special"],#DONE
	
	"Nitro" = [5, "Attack to the back.",
	[[GlobalEnums.ACTION_TYPE.ATTACK,4,"back","ram"]],
	"discard", 
	"attack"],#DONE
	
	"Emergency Brake" = [3, "Attack to the back.",
	[[GlobalEnums.ACTION_TYPE.ATTACK,2,"back","ram"]], 
	"discard", 
	"attack"],#DONE
	
	"Ram" = [6, "Attack to the front or side.",
	[[GlobalEnums.ACTION_TYPE.ATTACK, 4, "side and front","ram"]], 
	"discard", 
	"attack"],#DONE
	
	"Shoot'em up" = [5, "Attack in any direction.",
	[[GlobalEnums.ACTION_TYPE.ATTACK,2,"all sides","shoot"]], 
	"discard", 
	"attack"],#DONE
	
	"Explosive Maneouver" = [14, "A devastating attack to the side and back. BURN.",
	[[GlobalEnums.ACTION_TYPE.ATTACK,12,"side and back","shoot"]], 
	"burn", 
	"attack"],#DONE
	
	"Honk Honk" = [2, "+1 damage to the next attack and hit all directions.",
	[[GlobalEnums.ACTION_TYPE.SPECIAL,1,"all sides","buff_next_attack", GlobalEnums.AFFECTED_TARGET.ACTING_ACTOR],
	[GlobalEnums.ACTION_TYPE.SPECIAL,"","all sides","next_attack_all_direction", GlobalEnums.AFFECTED_TARGET.ACTING_ACTOR]], 
	"discard", 
	"special"],
	
	"Launcher Gallery" = [7, "Attack to the side.+2 damage to the next attack.",
	[[GlobalEnums.ACTION_TYPE.ATTACK,5,"side","shoot"],
	[GlobalEnums.ACTION_TYPE.SPECIAL,2,"all sides","buff_next_attack", GlobalEnums.AFFECTED_TARGET.ACTING_ACTOR]], 
	"discard", 
	"attack_special"],
	
	"Hook, line and sinker" = [3, "LINE UP. Damage reduction this turn. Enemy can't move during their next action.",
	[[GlobalEnums.ACTION_TYPE.MOVE,"line_up"],
	[GlobalEnums.ACTION_TYPE.SPECIAL,1,"reduced_damage_taken_this_turn", "acting_actor"],
	[GlobalEnums.ACTION_TYPE.SPECIAL,"", "all sides", "next_move_action_wont_work", GlobalEnums.AFFECTED_TARGET.TARGET]], 
	"discard", 
	"defence_special"],
	
	"Pew Pew" = [2, "Attack to the side.",
	[[GlobalEnums.ACTION_TYPE.ATTACK,1,"side","shoot"]], 
	"discard", 
	GlobalEnums.ACTION_TYPE.ATTACK],#DONE
	"Letter D" = [3, "LINE UP. Avoid next enemy action against you",
	[[GlobalEnums.ACTION_TYPE.MOVE,"line_up"],
	[GlobalEnums.ACTION_TYPE.SPECIAL,"","all sides","next_attack_or_debuff_wont_work", GlobalEnums.AFFECTED_TARGET.TARGET]], 
	"discard", 
	"special"],
	
	"Whatever" = [1, "Get a random buff: +2 damage, -2 fuel cost or +2 damage reduction.",
	[[GlobalEnums.ACTION_TYPE.SPECIAL,2,"all sides","random_buff_attack_fuel_defence", GlobalEnums.AFFECTED_TARGET.ACTING_ACTOR]], 
	"discard", 
	"special"],
	
	"Big Refill" = [1, "Reduce all fuel costs by 1 permanently.",
	[[GlobalEnums.ACTION_TYPE.SPECIAL,1,"all sides","permanent_buff_fuel_cost_reduction", GlobalEnums.AFFECTED_TARGET.ACTING_ACTOR]], 
	"burn", 
	"special"],
	
	"Gimme Fuel" = [7, "Attack to the front or side. Increase enemy fuel cost by 2 next turn.",
	[[GlobalEnums.ACTION_TYPE.ATTACK,3,"side and front","shoot"],
	[GlobalEnums.ACTION_TYPE.SPECIAL,2,"all sides","next_turn_actions_cost_more_fuel", GlobalEnums.AFFECTED_TARGET.TARGET]], 
	"discard", 
	"attack_special"],
	
	"Oil Spill" = [1, "OVERTAKE. Enemy can't move during their next action.",
	[[GlobalEnums.ACTION_TYPE.MOVE,"","overtake",""],
	[GlobalEnums.ACTION_TYPE.SPECIAL,"","all sides","next_move_action_wont_work", GlobalEnums.AFFECTED_TARGET.TARGET]], 
	"discard", 
	"special"],
	
	"Gimme Fire" = [5, "Attack to the back. Enemy suffers +1 extra damage until they overtake.",
	[[GlobalEnums.ACTION_TYPE.ATTACK,2,"back","shoot"],
	[GlobalEnums.ACTION_TYPE.SPECIAL,1,"side and back","damage_behind_and_line_up_every_cassette_this_turn",GlobalEnums.AFFECTED_TARGET.ACTING_ACTOR]], 
	"discard", 
	"attack_special"],
	
	"My name is Spike" = [4, "At the end of this turn reflect half of the damage taken back to the enemy.",
	[[GlobalEnums.ACTION_TYPE.SPECIAL,"","side and back","reflect_half_damage_at_the_end", GlobalEnums.AFFECTED_TARGET.TARGET]], 
	"discard", 
	"special"],
	
	"Rail the Tail" = [6, "Attack to the front. Enemy's next OVERTAKE becomes LINE UP or the next LINE UP is ignored",
	[[GlobalEnums.ACTION_TYPE.ATTACK,4,"front","ram"],
	[GlobalEnums.ACTION_TYPE.SPECIAL,"","less_movement_to_back", GlobalEnums.AFFECTED_TARGET.TARGET]], 
	"discard", 
	"attack_special"],
	
	"Another One" = [3, "SLOW DOWN. Avoid attacks to the back this turn.",
	[[GlobalEnums.ACTION_TYPE.MOVE,"","slow_down"], 
	[GlobalEnums.ACTION_TYPE.SPECIAL,"","back","this_turn_target_attacks_behind_wont_work", GlobalEnums.AFFECTED_TARGET.TARGET]], 
	"burn", 
	"special"],#DONE
	
	"Pit Maneouver" = [6, "OVERTAKE. Damage reduction this turn. Enemy's next action fuel cost is increased by 2",
	[[GlobalEnums.ACTION_TYPE.MOVE,"","overtake"],
	[GlobalEnums.ACTION_TYPE.SPECIAL,2, "all sides","next_enemy_cassette_cost_more", GlobalEnums.AFFECTED_TARGET.TARGET]], 
	"discard", 
	"defence_special"],
	
	"Bites the Dust" = [2, "SLOW DOWN. Permanent +2 damage to attacks to the front. BURN.",
	[[GlobalEnums.ACTION_TYPE.MOVE,"","slow_down"],
	[GlobalEnums.ACTION_TYPE.SPECIAL,2,"all sides","permanent_buff_all_attacks"]], 
	"burn", 
	"special"],#DONE
	
	"Road Rage" = [8, "Attack in any direction. Damage reduction this turn.",
	[[GlobalEnums.ACTION_TYPE.ATTACK,4,"all sides","ram"],
	[GlobalEnums.ACTION_TYPE.SPECIAL,2,"all sides","next_attack_damage_reduction_any_side"]], 
	"discard", 
	"attack_defence"],#DONE
	
	"Burning Rubber" = [3, "Attack to the back.",
	[[GlobalEnums.ACTION_TYPE.ATTACK,5,"back","shoot"]], 
	"burn", 
	"attack"],
	
	"Kickdown" = [3, "OVERTAKE. Increase fuel cost and damage by 3 this turn.",
	[[GlobalEnums.ACTION_TYPE.MOVE,"","overtake"],
	[GlobalEnums.ACTION_TYPE.SPECIAL,"3","all sides","debuff_this_turn_more_fuel_cost_you"],
	[GlobalEnums.ACTION_TYPE.SPECIAL,3,"+3_to_all_attacks"]], 
	"discard", 
	"special"],
	
	"Hit me baby" = [3, "LINE UP. Damage reduction from all side attacks this turn.",
	[[GlobalEnums.ACTION_TYPE.MOVE,"","line_up"],
	[GlobalEnums.ACTION_TYPE.SPECIAL,2,"side","this_turn_damage_reduction_side"]], 
	"discard", 
	"special"],#DONE
	
	"Roadslinger" = [5, "Attack to the front or back.",
	[[GlobalEnums.ACTION_TYPE.ATTACK,3,"back and front","ram"]], 
	"discard", 
	"attack"],#DONE
	
	"Drafting" = [2, "SLOW DOWN. All actions cost 1 fuel if you begin the turn on a SLOW DOWN position.",
	[[GlobalEnums.ACTION_TYPE.MOVE,"","slow_down"],
	[GlobalEnums.ACTION_TYPE.SPECIAL,1,"behind","next_turn_cassettes_cost_less_if_you_stay_in_slow_down"]], 
	"burn", 
	"special"],#DONE
	
	"Offence is Defence" = [5, "Attack to the side or back.",
	[[GlobalEnums.ACTION_TYPE.ATTACK,2,"side and back","shoot"]], 
	"discard", 
	"attack"],#DONE
	
	"Run to Live" = [4, "OVERTAKE. Damage reduction from attacks to the front this turn.",
	[[GlobalEnums.ACTION_TYPE.MOVE,"","overtake"],
	[GlobalEnums.ACTION_TYPE.SPECIAL,3,"back","this_turn_damage_reduction_back"]], 
	"discard", 
	"special"],#DONE
	
	"Perfectly Balanced" = [6, "Attack to the side. Damage reduction",
	[[GlobalEnums.ACTION_TYPE.ATTACK,3,"side","ram"],
	[GlobalEnums.ACTION_TYPE.SPECIAL,3, "side","this_turn_reduce_damage_from_sides"]], 
	"discard", 
	"attack_defence"],
	
	"Quick Attack" = [1, "Attack to the side.",[[GlobalEnums.ACTION_TYPE.ATTACK,1,"side", "shoot"]],"discard", "attack"],
	"Regular Attack" = [2, "Attack to the side.",[[GlobalEnums.ACTION_TYPE.ATTACK,2,"side", "shoot"]], "discard", "attack"],
	"Heavy Attack" = [4, "Attack to the side",[[GlobalEnums.ACTION_TYPE.ATTACK,4,"side", "shoot"]], "burn", "attack"],
}

var SIDE_B = {
	"EMP" = [4, "Attack to the back. Enemy can't overtake next turn.",
	[[GlobalEnums.ACTION_TYPE.ATTACK,1,"back", "shoot"], 
	[GlobalEnums.ACTION_TYPE.SPECIAL, "","back", "next_turn_target_debuff_no_position_change"]], 
	"discard", 
	"attack_special"],#DONE
	
	"Nitro" = [3, "Overtake. Enemy can't overtake next turn.",
	[[GlobalEnums.ACTION_TYPE.MOVE,"","overtake"], 
	[GlobalEnums.ACTION_TYPE.SPECIAL,"","all sides", "next_turn_target_debuff_no_position_change"]], 
	"discard", 
	"special"],#DONE
	
	"Emergency Brake" = [4,"Avoid an attack to the side.", 
	[[GlobalEnums.ACTION_TYPE.SPECIAL, "","side", "this_turn_you_avoid_side_attacks"]], 
	"discard", 
	"special"],#DONE
	
	"Ram" = [4, "LINE UP. Damage reduction this turn.",
	[[GlobalEnums.ACTION_TYPE.MOVE,"","line_up"],
	[GlobalEnums.ACTION_TYPE.SPECIAL,3,"side","this_turn_damage_reduction_side"]], 
	"discard", 
	"defence"],#DONE
	
	"Shoot'em up" = [3, "+1 damage to all attacks premanently. BURN",
	[[GlobalEnums.ACTION_TYPE.SPECIAL,1,"all sides","permanent_buff_all_attacks"]], 
	"burn", 
	"special"],#DONE
	
	"Explosive Maneouver" = [3, "OVERTAKE. +2 to the next attack",
	[[GlobalEnums.ACTION_TYPE.MOVE,"","overtake"],
	[GlobalEnums.ACTION_TYPE.SPECIAL,2,"all sides","buff_next_attack"]], 
	"discard", 
	GlobalEnums.ACTION_TYPE.SPECIAL],
	
	"Honk Honk" = [4, "OVERTAKE. Attack to the back",
	[[GlobalEnums.ACTION_TYPE.MOVE,"","overtake"],[GlobalEnums.ACTION_TYPE.ATTACK,1,"back"]], 
	"discard", 
	"attack_special"],
	
	"Launcher Gallery" = [6, "Attack to the back. +1 damage to the next attack",
	[[GlobalEnums.ACTION_TYPE.ATTACK,4,"back","shoot"],
	[GlobalEnums.ACTION_TYPE.SPECIAL,1,"all sides","buff_next_attack"]], 
	"discard", 
	"attack_special"],
	
	"Hook, line and sinker" = [4, "OVERTAKE. Your next action will not change your position.",
	[[GlobalEnums.ACTION_TYPE.MOVE,"","overtake"],
	[GlobalEnums.ACTION_TYPE.SPECIAL,"","all sides","next_action_target_debuff_no_position_change"]], 
	"discard", 
	"defence_special"],
	
	"Pew Pew" = [2, "Attack to the front.",
	[[GlobalEnums.ACTION_TYPE.ATTACK,1,"front","shoot"]], 
	"discard", 
	"attack"],#DONE
	
	"Letter D" = [1, "OVERTAKE. Avoid all enemy actions next turn and educe your damage by 2. BURN.",
	[[GlobalEnums.ACTION_TYPE.MOVE,"","overtake"],
	[GlobalEnums.ACTION_TYPE.SPECIAL,"","all sides","next_turn_avoid_all_actions"],
	[GlobalEnums.ACTION_TYPE.SPECIAL,2,"all sides","next_turn_debuff_player_less_damage"]], 
	"burn", 
	"special"],
	
	"Whatever" = [1, "Give a random debuff: enemy damage reduced by 2, fuel cost increased by 2.",
	[[GlobalEnums.ACTION_TYPE.SPECIAL,"","all sides","random_debuff_attack_fuel"]], 
	"discard", 
	"special"],
	
	"Big Refill" = [1, "Reduce the fuel cost of the next action by 3.",
	[[GlobalEnums.ACTION_TYPE.SPECIAL,3,"all sides","next_card_reduce_fuel"]], 
	"discard", 
	"special"],
	
	"Gimme Fuel" = [5, "Attack to the front or side. Increase the fuel cost of the next enemy action by 5.",
	[[GlobalEnums.ACTION_TYPE.ATTACK,2,"side and front","shoot"],
	[GlobalEnums.ACTION_TYPE.SPECIAL,5,"all sides","next_card_target_costs_more_fuel"]], 
	"discard", 
	"attack_special"],#DONE
	
	"Oil Spill" = [3, "OVERTAKE. Damage reduction this turn.",
	[[GlobalEnums.ACTION_TYPE.MOVE,"","overtake"],
	[GlobalEnums.ACTION_TYPE.SPECIAL,2,"all sides","this_turn_damage_reduction"]], 
	"discard", 
	"defence"],
	
	"Gimme Fire" = [1, "Next turn your actions cost less per point of damage received this turn. BURN.",
	[[GlobalEnums.ACTION_TYPE.SPECIAL,"","all sides","next_turn_player_cassettes_cost_less_per_damage"]], 
	"burn", 
	"special"],
	
	"My name is Spike" = [3, "SLOW DOWN. Damage reduction from the attacks to the back this turn. Reflect 1 damage from enemy's next attack back to them.",
	[[GlobalEnums.ACTION_TYPE.MOVE,"","slow_down"],
	[GlobalEnums.ACTION_TYPE.SPECIAL,1,"front","this_turn_damage_reduction_front"],
	[GlobalEnums.ACTION_TYPE.SPECIAL,1,"all sides","reflect_damage_on_next_attack"]], 
	"discard", 
	"defence_special"],
	
	"Rail the Tail" = [3, "Attack to the front. Fuel cost of enemy actions increased by 1 permanently. BURN",
	[[GlobalEnums.ACTION_TYPE.ATTACK,1,"front","ram"],[GlobalEnums.ACTION_TYPE.SPECIAL,1,"all sides","until_end_all_cards_cost_more_fuel"]], 
	"burn",
	"attack_special"],
	
	"Another One" = [5, "Damage reduction from attacks from front.",
	[[GlobalEnums.ACTION_TYPE.SPECIAL,"3","front","this_turn_attacks_from_front_wont_work"]], 
	"discard", 
	"defence"],#DONE
	
	"Pit Maneouver" = [7, "Attack to the side. Increase the fuel cost of the next enemy action by 2.",
	[[GlobalEnums.ACTION_TYPE.ATTACK,5,"side","ram"],[GlobalEnums.ACTION_TYPE.SPECIAL,2,"all sides","next_enemy_cassette_cost_more"]], 
	"discard", 
	"attack_special"],
	
	"Bites the Dust" = [4, "Attack in any direction. Add fuel spent so far as additional damage to this attack.",
	[[GlobalEnums.ACTION_TYPE.SPECIAL,1,"all sides","attack_deals_damage_plus_spent_fuel_as_bonus_damage_all sides"]], 
	"discard", 
	"attack_special"],#DONE
	
	"Road Rage" = [8, "Attack in any direction. Damage reduction this turn.",
	[[GlobalEnums.ACTION_TYPE.ATTACK,2,"all sides","ram"],
	[GlobalEnums.ACTION_TYPE.SPECIAL,4,"all sides","next_attack_damage_reduction_any_side"]], 
	"discard", 
	"attack_defence"],#DONE
	
	"Burning Rubber" = [1, "OVERTAKE. Avoid next enemy attack. BURN.",[[GlobalEnums.ACTION_TYPE.MOVE,"","overtake"],
	[GlobalEnums.ACTION_TYPE.SPECIAL,"","all sides","next_attack_wont_work"]], 
	"burn", 
	"special"],
	
	"Kickdown" = [3, "LINE UP. Stay on the position this turn",
	[[GlobalEnums.ACTION_TYPE.MOVE,"","line_up"],
	[GlobalEnums.ACTION_TYPE.SPECIAL,"","all sides","this_turn_enemy_move_skills_don't_work"]], 
	"discard", 
	"special"],
	
	"Hit me baby" = [1, "SLOW DOWN. Damage reduction from the attacks to the back this turn.",
	[[GlobalEnums.ACTION_TYPE.MOVE,"","slow_down"]
	,[GlobalEnums.ACTION_TYPE.SPECIAL,2,"all sides","this_turn_damage_reduction_front"]], 
	"discard", 
	"special"],
	
	"Roadslinger" = [5, "Attack to the side or back.",
	[[GlobalEnums.ACTION_TYPE.ATTACK,3,"side and back","shoot"]], 
	"discard", 
	GlobalEnums.ACTION_TYPE.ATTACK],#DONE
	
	"Drafting" = [2, "SLOW DOWN. Fuel cost of the next action reduced by 1 if you start on SLOW DOWN.",
	[[GlobalEnums.ACTION_TYPE.MOVE,"","slow_down"],
	[GlobalEnums.ACTION_TYPE.SPECIAL,1,"all sides","next_turn_first_action_cost_less_if_you_start_in_slow_down"]], 
	"discard", 
	GlobalEnums.ACTION_TYPE.SPECIAL],#DONE
	
	"Offence is Defence" = [2, "LINE UP. Damage reduction form attacks to the side this turn.",
	[[GlobalEnums.ACTION_TYPE.MOVE,"","line_up"],
	[GlobalEnums.ACTION_TYPE.SPECIAL,2,"side","this_turn_damage_reduction_side"]], 
	"discard", 
	"defence"],#DONE
	
	"Run to Live" = [4, "SLOW DOWN. Damage reduction from attacks to the back this turn.",
	[[GlobalEnums.ACTION_TYPE.MOVE,"","slow_down"],
	[GlobalEnums.ACTION_TYPE.SPECIAL,3,"front","this_turn_damage_reduction_front"]], 
	"discard", 
	"defence"],#DONE

	"Perfectly Balanced" = [3, "LINE UP. Reduce fuel cost of the action by 1 when you LINE UP.",
	[[GlobalEnums.ACTION_TYPE.MOVE,"","line_up"],
	["side",1,"all sides","this_turn_reduce_fuel_cost_while_in_line_up"]], 
	"discard", 
	"special"],
	
	"Quick Attack" = [2, "Quick move to the next lane",[[GlobalEnums.ACTION_TYPE.MOVE,"","slow_down"]],"discard", "defence"],
	"Regular Attack" = [4, "Regular move that moves that lines up",[[GlobalEnums.ACTION_TYPE.MOVE,"","line_up"]],"discard", "defence"],
	"Heavy Attack" = [6, "Long move in front of enemy",[[GlobalEnums.ACTION_TYPE.MOVE,"","overtake"]],"discard", "defence"],
}
#[NAME, ICON_NAME, WHEN_HAPPENS, ANIMATION, DESCRIPTION]
const EFFECTS = {
	"this_turn_avoid_side_attacks" = ["this_turn_you_avoid_side_attacks","defence buff", "this_turn", "getting_buff", "Avoid Side Attacks this turn", ""],
	"permanent_buff_all_attacks" = ["permanent_buff_all_attacks","attack buff", "permanent", "getting_buff", "%s to Attack Damage"],
	"buff_next_attack" = ["buff_next_attack","attack buff", "next_attack", "getting_buff", "+2 to Next Attack Damage", 2],
	"this_turn_attacks_from_front_wont_work" = ["this_turn_attacks_from_front_wont_work", "defence buff", "this_turn", "getting_buff", "This Turn attacks enemy attacks from front won't work", ""],
	"next_turn_first_action_cost_less_if_you_start_in_slow_down" = ["next_turn_first_action_cost_less_if_you_start_in_slow_down", "special buff","next_turn", "getting_buff", "Next Turn first action cost less if you start turn in SLOW DOWN", 1],
	"next_cassette_cost_less" = ["next_cassette_cost_less", "fuel buff","next_cassette", "getting_buff", "Next cassette cost less", 1],
	"next_turn_cassettes_cost_less_if_you_stay_in_slow_down" = ["next_turn_cassettes_cost_less_if_you_start_in_slow_down","special buff","next_turn", "getting_buff", "Next Turn actions cost less if you start turn in SLOW DOWN", 1],
	"this_turn_cassettes_cost_less" = ["this_turn_cassettes_cost_less", "fuel buff", "getting_buff", "This turn Cassettes cost less", 1],
	"this_turn_damage_reduction_back" = ["this_turn_damage_reduction_back","defence buff", "this turn", "getting_buff", "Reduce damage from Back attacks by %s"],
	"this_turn_damage_reduction_front" = ["this_turn_damage_reduction_front","defence buff", "this_turn", "getting_buff", "Reduce damage from Front attacks by %s"],
	"this_turn_damage_reduction_side" = ["this_turn_damage_reduction_side","defence buff", "this_turn", "getting_buff", "Reduce damage from Side attacks by %s"],
	"next_attack_damage_reduction_any_side" = ["next_attack_damage_reduction_any_side", "defence buff","next_attack", "getting_buff", "Reduce next attack damage by %s"],
	"next_cassette_wont_work" = ["next_cassette_wont_work","cassette debuff", "next_cassette", "getting_debuff", "Next Cassette wont work."],
	"next_turn_target_debuff_no_position_change" = ["next_turn_target_debuff_no_position_change","cassette debuff", "next_turn", "getting_debuff", "Next Turn move actions won't work"],
	"this_turn_target_attacks_behind_wont_work" = ["this_turn_target_attacks_behind_wont_work", "attack block", "this_turn", "getting_debuff", "This Turn attacks behind won't work"],
	"next_card_target_costs_more_fuel" = ["next_card_target_costs_more_fuel","fuel debuff", "next_cassette", "getting_debuff", "Next Cassette actions costs %s more fuel."],
	"next_turn_actions_cost_more_fuel" = ["next_turn_actions_cost_more_fuel","fuel debuff", "next_turn", "getting_debuff", "Next Turn actions cost more fuel"]
}

var player_base_available_cards = [
"Nitro",
"Emergency Brake",
"Whatever",
"Big Refill",
"Oil Spill",
"Burning Rubber",
"Gimme Fire",
"Drafting",
"Hit me baby",
"Ram",
"Gimme Fuel",
"Road Rage",
"Roadslinger",
"Run to Live",
"Letter D",
"Kickdown",
"Offence is Defence",
"Pew Pew",
"Shoot'em up",
"Perfectly Balanced"]

var player_default_deck = [
"Nitro",
"Ram",
"Shoot'em up",
"Pew Pew",
"Letter D",
"Big Refill",
"Road Rage",
"Run to Live",
"Road Slinger",
"Gimme Fire",
]

var hound_deck = [
"Another One",
"Bites the Dust",
"Drafting",
"Hit me baby",
"Ram",
"Pew Pew",
"Gimme Fuel",
"Road Rage",
"Roadslinger",
"Run to Live"
]

var boner_deck = [
"My name is spike",
"Rail the tail",
"Ram",
"Letter D",
"Kickdown",
"Hit me baby",
"Offence is Defence",
"Perfectly balanced",
"Pew Pew",
"Road Rage"
]

var evans_deck = [
"Explosive Maneouver",
"EMP",
"Launcher Gallery",
"Hooker, Line and Sinker",
"Run to live",
"Pew Pew",
"Roadslinger",
"Offence is Defence",
"Perfectly balanced",
"Shoot'em up",
]


var railgrinder_deck = [
"Explosive Maneouver",
"Honk Honk",
"Launcher Gallery",
"Hooker, Line and Sinker",
"Run to live",
"Pew Pew",
"Roadslinger",
"Offence is Defence",
"Perfectly balanced",
"Shoot'em up",
]

var boss_decks = {
	"hound" = hound_deck,
	"boner" = boner_deck,
	"evans" = evans_deck,
	"railgrinder" = railgrinder_deck,
}
