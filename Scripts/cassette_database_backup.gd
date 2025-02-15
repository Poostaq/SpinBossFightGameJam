extends Node

# [NAME, SIDE_A_DATA, SIDE_B_DATA]
const CASSETTES = {
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
# [FUEL_COST, DESCRIPTION, [[MOVE_TYPE, VALUE, MOVE_TARGET_AREA, (optional)MOVE_INFO]], AFTER_PLAY, ACTION_ICON]
const SIDE_A = {
	"EMP" = [3, "Deal damage in front. Target next cassette won't work.",[["attack",2,"front","shoot"],["special","","front", "next_cassette_wont_work"]], "burn", "attack_special"],#DONE
	"Nitro" = [5, "Deal damage in front.",[["attack",4,"front","ram"]], "discard", "attack"],#DONE
	"Emergency Brake" = [3, "Deal damage behind.",[["attack",2,"behind","ram"]], "discard", "attack"],#DONE
	"Ram" = [6, "Deal damage in front or side.",[["attack", 4, "side_front","ram"]], "discard", "attack"],#DONE
	"Shoot'em up" = [5, "Deal damage on any side.",[["attack",2,"all_sides","shoot"]], "discard", "attack"],#DONE
	"Explosive Maneouver" = [14, "Deal massive damage behind or on side. BURN.",[["attack",12,"back_sides","shoot"]], "burn", "attack"],#DONE
	"Honk Honk" = [2, "Next attack will deal more damage and target all directions.",[["special",1,"all_sides","buff_next_attack"],["special","","all_sides","next_attack_all_direction"]], "discard", "special"],
	"Launcher Gallery" = [7, "Deal damage to side. Next attack deals more damage.",[["attack",5,"side","shoot"],["special",2,"all_sides","buff_next_attack"]], "discard", "attack_special"],
	"Hook, line and sinker" = [3, "LINE UP. Reduce damage taken this turn. Target next move won't work. ",[["move","","line_up"],["defence",1,"reduced_damage_taken_this_turn"],["special","", "all_sides", "next_move_action_wont_work"]], "discard", "defence_special"],
	"Pew Pew" = [2, "Deal damage to sides.",[["attack",1,"side","shoot"]], "discard", "attack"],#DONE
	"Letter D" = [3, "LINE UP. Target next attack or debuff won't work",[["move","","line_up"],["special","","all_sides","next_attack_or_debuff_wont_work"]], "discard", "special"],
	"Whatever" = [1, "Random buff to damage, fuel cost or damage reduction.",[["special",2,"all_sides","random_buff_attack_fuel_defence"]], "discard", "special"],
	"Big Refill" = [1, "Permanently reduce fuel costs.",[["special",1,"all_sides","permanent_buff_fuel_cost_reduction"]], "burn", "special"],
	"Gimme Fuel" = [7, "Deal damage to sides or front. Next turn target actions cost more.",[["attack",3,"side_front","shoot"],["special",2,"all_sides","next_turn_enemy_actions_cost_more_fuel"]], "discard", "attack_special"],
	"Oil Spill" = [1, "OVERTAKE. Target next move action won't work.",[["move","","overtake",""],["special","","all_sides","next_move_action_wont_work"]], "discard", "special"],
	"Gimme Fire" = [5, "Deal damage behind. Target receives damage every played cassette while in SLOWDOWN or LINE UP position.",[["attack",2,"back","shoot"],["special",1,"back_side","damage_behind_and_line_up_every_cassette_this_turn"]], "discard", "attack_special"],
	"My name is Spike" = [4, "Reflect half of damage taken this turn at the end of this turn.",[["special","","reflect_half_damage_at_the_end"]], "discard", "special"],
	"Rail the Tail" = [6, "Deal damage in front. Target next OVERTAKE",[["attack",4,"front","ram"],["special","","less_movement_to_back"]], "discard", "attack_special"],
	"Another One" = [3, "SLOW DOWN. This turn target attacks behind won't work.",[["move","","slow_down"], ["special","","behind","this_turn_target_attacks_behind_wont_work"]], "burn", "special"],#DONE
	"Pit Maneouver" = [6, "OVERTAKE. Target next cassette costs more",[["move","","overtake"],["special",2,"next_enemy_cassette_cost_more"]], "discard", "defence_special"],
	"Bites the Dust" = [2, "SLOW DOWN. All attacks deal bonus damage until the end of battle. BURN.",[["move","","slow_down"],["special",2,"all_sides","buff_all_attacks_2"]], "burn", "special"],#DONE
	"Road Rage" = [8, "Deal damage on any side. Reduce damage from next attack on any side.",[["attack",4,"all_sides","ram"],["special",2,"all_sides","next_attack_damage_reduction_any_side_2"]], "discard", "attack_defence"],#DONE
	"Burning Rubber" = [3, "Deal damage behind.",[["attack",5,"behind","shoot"]], "burn", "attack"],
	"Kickdown" = [3, "OVERTAKE. This turn your actions cost more fuel. This turn your attacks deal more damage ",[["move","","overtake"],["special","3","all_sides","debuff_this_turn_more_fuel_cost_you"],["special",3,"buff_this_turn_attack"]], "discard", "special"],
	"Hit me baby" = [3, "LINE UP. Reduce all damage taken from side this turn.",[["move","","line_up"],["special",2,"side","this_turn_damage_reduction_side_2"]], "discard", "defence"],#DONE
	"Roadslinger" = [5, "Deal damage in front or behind.",[["attack",3,"front_back","ram"]], "discard", "attack"],#DONE
	"Drafting" = [2, "SLOW DOWN. Next turn cards cost less while in SLOW DOWN position.",[["move","","slow_down"],["special",1,"behind","next_turn_cassettes_cost_less_if_you_stay_in_slow_down"]], "burn", "special"],#DONE
	"Offence is Defence" = [5, "Deal damage behind or on side.",[["attack",2,"behind_sides","shoot"]], "discard", "attack"],#DONE
	"Run to Live" = [4, "OVERTAKE. Reduce all damage taken from behind this turn.",[["move","","overtake"],["special",3,"behind","this_turn_damage_reduction_back_3"]], "discard", "defence"],#DONE
	"Perfectly Balanced" = [6, "TODO",[["attack",3,"sides","ram"],["special",3, "side","this_turn_reduce_damage_from_sides"]], "discard", "attack_defence"],
	
	
	
	
	
	"Quick Attack" = [1, "Quick attack that deals 1 damage.",[["attack",1,"side", "shoot"]],"discard", "attack"],
	"Regular Attack" = [2, "Regular attack that deals 2 damage.",[["attack",2,"side", "shoot"]], "discard", "attack"],
	"Heavy Attack" = [4, "Slow attack that deals 4 damage",[["attack",4,"side", "shoot"]], "burn", "attack"],
}

const SIDE_B = {
	"EMP" = [4, "Deal damage to target behind. Next Turn target can't move.",[["attack",1,"back", "shoot"], ["special", "","behind", "next_turn_target_debuff_no_position_change"]], "discard", "attack_special"],#DONE
	"Nitro" = [3, "Overtake, Next Turn target can't move.",[["move","","overtake"], ["special","","all_sides", "next_turn_target_debuff_no_position_change"] ], "discard", "special"],#DONE
	"Emergency Brake" = [4,"Avoid all attacks when in LINE UP position.", [["special", "","side", "this_turn_you_avoid_side_attacks"]], "discard", "special"],#DONE
	"Ram" = [4, "Line Up. Reduce all damage taken this turn.",[["move","","line_up"],["special",3,"side","this_turn_damage_reduction_side_3"],], "discard", "defence"],#DONE
	"Shoot'em up" = [3, "All attacks deal bonus damage until the end of battle. BURN",[["special",1,"all_sides","buff_all_attacks"]], "burn", "special"],#DONE
	"Explosive Maneouver" = [3, "OVERTAKE. Next attack deals bonus damage",[["move","","overtake"],["special",2,"all_sides","buff_next_attack"]], "discard", "special"],
	"Honk Honk" = [4, "OVERTAKE. Deal damage to target behind",[["move","","overtake"],["attack",1,"behind"]], "discard", "attack_special"],
	"Launcher Gallery" = [6, "Deal damage to target behind. Next attack deals bonus damage",[["attack",4,"behind","shoot"],["special",1,"all_sides","buff_next_attack"]], "discard", "attack_special"],
	"Hook, line and sinker" = [4, "OVERTAKE. Your next move action won't work.",[["move","","overtake"],["special","","all_sides","next_action_target_debuff_no_position_change"]], "discard", "defence_special"],
	"Pew Pew" = [2, "Deal damage to the target in front.",[["attack",2,"front","shoot"]], "discard", "attack"],#DONE
	"Letter D" = [1, "OVERTAKE. Next turn avoid all target actions. Next turn deal less damage. BURN.",[["move","","overtake"],["special","","all_sides","next_turn_avoid_all_actions"],["special",2,"all_sides","next_turn_debuff_player_less_damage"]], "burn", "special"],
	"Whatever" = [1, "Random debuff to target attack or fuel values.",[["special","","all_sides","random_debuff_attack_fuel"]], "discard", "special"],
	"Big Refill" = [1, "Next card costs less.",[["special",3,"all_sides","next_card_reduce_fuel"]], "discard", "special"],
	"Gimme Fuel" = [5, "Deal damage to the side or in front. Target next card costs more.",[["attack",2,"side_front","shoot"],["special",5,"all_sides","next_card_target_costs_more_fuel"]], "discard", "attack_special"],#DONE
	"Oil Spill" = [3, "OVERTAKE. Reduce all damage taken this turn.",[["move","","overtake"],["special",2,"all_sides","this_turn_damage_reduction"]], "discard", "defence"],
	"Gimme Fire" = [1, "Next turn player cassettes cost less per point of damage received this turn. BURN.",[["special","","all_sides","next_turn_player_cassettes_cost_less_per_damage"]], "burn", "special"],
	"My name is Spike" = [3, "SLOW DOWN. Reduce damage taken from front this turn. Reflect 1 damage from enemy next attack back to him.",[["move","","slow_down"],["special",1,"front","this_turn_damage_reduction_front"],["special",1,"all_sides","reflect_damage_on_next_attack"]], "discard", "defence_special"],
	"Rail the Tail" = [3, "Deal damage to target in front. Targets all cards cost more until the end of battle. BURN",[["attack",1,"front","ram"],["special",1,"all_sides","until_end_all_cards_cost_more_fuel"]], "burn", "attack_special"],
	"Another One" = [5, "Avoid all attacks from the front this turn.",[["special","","front","this_turn_attacks_in_front_wont_work"]], "discard", "defence"],#DONE
	"Pit Maneouver" = [7, "Deal damage to the target on side. Next target cassette costs more.",[["attack",5,"side","ram"],["special",2,"all_sides","next_enemy_cassette_cost_more"]], "discard", "attack_special"],
	"Bites the Dust" = [4, "Deal damage to target anywhere. Added fuel spent as additional damage to that attack.",[["special",1,"all_sides","attack_deals_damage_plus_spent_fuel_as_bonus_damage_all_sides"]], "discard", "attack_special"],#DONE
	"Road Rage" = [8, "Deal damage anywhere. Reduce damage taken from next cassette.",[["attack",2,"all_sides","ram"],["special",4,"all_sides","next_attack_damage_reduction_any_side_4"]], "discard", "attack_defence"],#DONE
	"Burning Rubber" = [1, "OVERTAKE. Avoid next attack. BURN.",[["move","","overtake"],["special","","all_sides","next_attack_wont_work"]], "burn", "special"],
	"Kickdown" = [3, "LINE UP. This Turn target can't move.",[["move","","line_up"],["special","","all_sides","this_turn_enemy_move_skills_don't_work"]], "discard", "special"],
	"Hit me baby" = [1, "SLOW DOWN. Reduce all damage taken this turn from front.",[["move","","slow_down"],["special",2,"all_sides","this_turn_damage_reduction_front_2"]], "discard", "defence"],
	"Roadslinger" = [5, "Damage target behind you or on side.",[["attack",3,"behind_side","shoot"]], "discard", "attack"],#DONE
	"Drafting" = [2, "SLOW DOWN. Next turn one action cost less in SLOW DOWN position.",[["move","","slow_down"],["special",1,"all_sides","next_turn_first_action_cost_less_if_you_start_in_slow_down"]], "discard", "special"],#DONE
	"Offence is Defence" = [2, "LINE UP. Reduce damage from next action side damage.",[["move","","line_up"],["special",2,"side","this_turn_damage_reduction_side_2"]], "discard", "defence"],#DONE
	"Run to Live" = [4, "SLOW DOWN. Reduce all damage taken this turn from front.",[["move","","slow_down"],["special",3,"front","this_turn_damage_reduction_front"]], "discard", "defence"],#DONE
	"Perfectly Balanced" = [3, "LINE UP. This turn actions cost less in SLOW DOWN position.",[["move","","line_up"],["side",1,"all_sides","this_turn_reduce_fuel_cost_while_in_line_up"]], "discard", "special"],
	
	
	
	
	
	"Quick Attack" = [2, "Quick move to the next lane",[["move","","slow_down"]],"discard", "defence"],
	"Regular Attack" = [4, "Regular move that moves that lines up",[["move","","line_up"]],"discard", "defence"],
	"Heavy Attack" = [6, "Long move in front of enemy",[["move","","overtake"]],"discard", "defence"],
}
#[NAME, ICON_NAME, WHEN_HAPPENS, ANIMATION, DESCRIPTION,VALUE]
const BUFFS = {
	"this_turn_you_avoid_side_attacks" = ["this_turn_you_avoid_side_attacks","attack to the side block","defence buff", "this_turn", "getting_buff", "Avoid Side Attacks this turn", ""],
	"buff_all_attacks" = ["buff_all_attacks","attack buff", "permanent", "getting_buff", "+1 to Attack Damage",1],
	"buff_all_attacks_2" = ["buff_all_attacks","attack buff", "permanent", "getting_buff", "+2 to Attack Damage",2],
	"buff_next_attack" = ["buff_next_attack","attack buff", "next_attack", "getting_buff", "+2 to Next Attack Damage", 2],
	"this_turn_attacks_in_front_wont_work" = ["this_turn_target_attacks_behind_wont_work", "defence buff", "this_turn", "getting_buff", "This Turn attacks enemy attacks from front won't work", ""],
	"next_turn_first_action_cost_less_if_you_start_in_slow_down" = ["next_turn_first_action_cost_less_if_you_start_in_slow_down", "special buff","next_turn", "getting_buff", "Next Turn first action cost less if you start turn in SLOW DOWN", 1],
	"next_cassette_cost_less" = ["next_cassette_cost_less", "fuel buff","next_cassette", "getting_buff", "Next cassette cost less", 1],
	"next_turn_cassettes_cost_less_if_you_stay_in_slow_down" = ["next_turn_cassettes_cost_less_if_you_start_in_slow_down","special buff","next_turn", "getting_buff", "Next Turn actions cost less if you start turn in SLOW DOWN", 1],
	"this_turn_cassettes_cost_less" = ["this_turn_cassettes_cost_less", "fuel buff", "getting_buff", "This turn Cassettes cost less", 1],
	"this_turn_damage_reduction_back_3" = ["this_turn_damage_reduction_back_3","defence buff", "this turn", "getting_buff", "Reduce damage from Back attacks by 3", 3],
	"this_turn_damage_reduction_front_2" = ["this_turn_damage_reduction_front_2","defence buff", "this_turn", "getting_buff", "Reduce damage from Front attacks by 2", 2],
	"this_turn_damage_reduction_front_3" = ["this_turn_damage_reduction_front_3","defence buff", "this_turn", "getting_buff", "Reduce damage from Front attacks by 3", 3],
	"this_turn_damage_reduction_side_2" = ["this_turn_damage_reduction_side_2","defence buff", "this_turn", "getting_buff", "Reduce damage from Side attacks by 2", 2],
	"this_turn_damage_reduction_side_3" = ["this_turn_damage_reduction_side_3","defence buff", "this_turn", "getting_buff", "Reduce damage from Side attacks by 3", 3],
	"next_attack_damage_reduction_any_side_2" = ["next_attack_damage_reduction_any_side_2", "defence buff","next_attack", "getting_buff", "Reduce next attack damage by 2", 2],
	"next_attack_damage_reduction_any_side_4" = ["next_attack_damage_reduction_any_side_4", "defence buff","next_attack", "getting_buff", "Reduce next attack damage by 4", 4]
}

#[NAME, ICON_NAME, WHEN_HAPPENS, ANIMATION, DESCRIPTION,VALUE]
const DEBUFFS = {
	"next_cassette_wont_work" = ["next_cassette_wont_work","cassette debuff", "next_cassette", "getting_debuff", "Next Cassette wont work.",""],
	"next_turn_target_debuff_no_position_change" = ["next_turn_target_debuff_no_position_change","cassette debuff", "next_turn", "getting_debuff", "Next Turn move actions won't work",""],
	"this_turn_target_attacks_behind_wont_work" = ["this_turn_target_attacks_behind_wont_work", "attack block", "this_turn", "getting_debuff", "This Turn attacks behind won't work", ""],
	"next_card_target_costs_more_fuel" = ["next_card_target_costs_more_fuel","fuel debuff", "next_cassette", "getting_debuff", "Next Cassette actions costs more fuel.",5],
	"next_turn_enemy_actions_cost_more_fuel" = ["next_turn_enemy_actions_cost_more_fuel","fuel debuff", "next_turn", "getting_debuff", "Next Turn actions cost more fuel", 2]
}

var player_base_available_cards = ["EMP",
"Nitro",
"Emergency brake",
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
"Perfectly balanced"]

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

var railgrinder_deck = []
