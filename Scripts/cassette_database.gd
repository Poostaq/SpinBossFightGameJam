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
	"EMP" = [3, "Attak to the front. Disable enemy's next action.",[["attack",2,"front","shoot"],["special","","front", "next_cassette_wont_work"]], "burn", "attack_special"],#DONE
	"Nitro" = [5, "Attack to the back.",[["attack",4,"back","ram"]], "discard", "attack"],#DONE
	"Emergency Brake" = [3, "Attack to the back.",[["attack",2,"back","ram"]], "discard", "attack"],#DONE
	"Ram" = [6, "Attack to the front or side.",[["attack", 4, "side and front","ram"]], "discard", "attack"],#DONE
	"Shoot'em up" = [5, "Attack in any direction.",[["attack",2,"all sides","shoot"]], "discard", "attack"],#DONE
	"Explosive Maneouver" = [14, "A devastating attack to the side and back. BURN.",[["attack",12,"side and back","shoot"]], "burn", "attack"],#DONE
	"Honk Honk" = [2, "+1 damage to the next attack and hit all directions.",[["special",1,"all sides","buff_next_attack"],["special","","all sides","next_attack_all_direction"]], "discard", "special"],
	"Launcher Gallery" = [7, "Attack to the side.+2 damage to the next attack.",[["attack",5,"side","shoot"],["special",2,"all sides","buff_next_attack"]], "discard", "attack_special"],
	"Hook, line and sinker" = [3, "LINE UP. Damage reduction this turn. Enemy can't move during their next action.",[["move","","line_up"],["special",1,"reduced_damage_taken_this_turn"],["special","", "all sides", "next_move_action_wont_work"]], "discard", "defence_special"],
	"Pew Pew" = [2, "Attack to the side.",[["attack",1,"side","shoot"]], "discard", "attack"],#DONE
	"Letter D" = [3, "LINE UP. Avoid next enemy action against you",[["move","","line_up"],["special","","all sides","next_attack_or_debuff_wont_work"]], "discard", "special"],
	"Whatever" = [1, "Get a random buff: +2 damage, -2 fuel cost or +2 damage reduction.",[["special",2,"all sides","random_buff_attack_fuel_defence"]], "discard", "special"],
	"Big Refill" = [1, "Reduce all fuel costs by 1 permanently.",[["special",1,"all sides","permanent_buff_fuel_cost_reduction"]], "burn", "special"],
	"Gimme Fuel" = [7, "Attack to the front or side. Increase enemy fuel cost by 2 next turn.",[["attack",3,"side and front","shoot"],["special",2,"all sides","next_turn_enemy_actions_cost_more_fuel"]], "discard", "attack_special"],
	"Oil Spill" = [1, "OVERTAKE. Enemy can't move during their next action.",[["move","","overtake",""],["special","","all sides","next_move_action_wont_work"]], "discard", "special"],
	"Gimme Fire" = [5, "Attack to the back. Enemy suffers +1 extra damage until they overtake.",[["attack",2,"back","shoot"],["special",1,"side and back","damage_behind_and_line_up_every_cassette_this_turn"]], "discard", "attack_special"],
	"My name is Spike" = [4, "At the end of this turn reflect half of the damage taken back to the enemy.",[["special","","reflect_half_damage_at_the_end"]], "discard", "special"],
	"Rail the Tail" = [6, "Attack to the front. Enemy's next OVERTAKE becomes LINE UP or the next LINE UP is ignored",[["attack",4,"front","ram"],["special","","less_movement_to_back"]], "discard", "attack_special"],
	"Another One" = [3, "SLOW DOWN. Avoid attacks to the back this turn.",[["move","","slow_down"], ["special","","back","this_turn_target_attacks_behind_wont_work"]], "burn", "special"],#DONE
	"Pit Maneouver" = [6, "OVERTAKE. Damage reduction this turn. Enemy's next action fuel cost is increased by 2",[["move","","overtake"],["special",2,"next_enemy_cassette_cost_more"]], "discard", "defence_special"],
	"Bites the Dust" = [2, "SLOW DOWN. Permanent +2 damage to attacks to the front. BURN.",[["move","","slow_down"],["special",2,"all sides","buff_all_attacks_2"]], "burn", "special"],#DONE
	"Road Rage" = [8, "Attack in any direction. Damage reduction this turn.",[["attack",4,"all sides","ram"],["special",2,"all sides","+2_to_damage_reduction"]], "discard", "attack_defence"],#DONE
	"Burning Rubber" = [3, "Attack to the back.",[["attack",5,"back","shoot"]], "burn", "attack"],
	"Kickdown" = [3, "OVERTAKE. Increase fuel cost and damage by 3 this turn.",[["move","","overtake"],["special","3","all sides","debuff_this_turn_more_fuel_cost_you"],["special",3,"+3_to_all_attacks"]], "discard", "special"],
	"Hit me baby" = [3, "LINE UP. Damage reduction from all side attacks this turn.",[["move","","line_up"],["special",2,"side","this_turn_damage_reduction_side_2"]], "discard", "defence"],#DONE
	"Roadslinger" = [5, "Attack to the front or back.",[["attack",3,"back and front","ram"]], "discard", "attack"],#DONE
	"Drafting" = [2, "SLOW DOWN. All actions cost 1 fuel if you begin the turn on a SLOW DOWN position.",[["move","","slow_down"],["special",1,"behind","next_turn_cassettes_cost_less_if_you_stay_in_slow_down"]], "burn", "special"],#DONE
	"Offence is Defence" = [5, "Attack to the side or back.",[["attack",2,"side and back","shoot"]], "discard", "attack"],#DONE
	"Run to Live" = [4, "OVERTAKE. Damage reduction from attacks to the front this turn.",[["move","","overtake"],["special",3,"back","this_turn_damage_reduction_back_3"]], "discard", "defence"],#DONE
	"Perfectly Balanced" = [6, "Attack to the side. Damage reduction",[["attack",3,"side","ram"],["special",3, "side","this_turn_reduce_damage_from_sides"]], "discard", "attack_defence"],
	
	
	
	
	
	"Quick Attack" = [1, "Attack to the side.",[["attack",1,"side", "shoot"]],"discard", "attack"],
	"Regular Attack" = [2, "Attack to the side.",[["attack",2,"side", "shoot"]], "discard", "attack"],
	"Heavy Attack" = [4, "Attack to the side",[["attack",4,"side", "shoot"]], "burn", "attack"],
}

const SIDE_B = {
	"EMP" = [4, "Attack to the back. Enemy can't overtake next turn.",[["attack",1,"back", "shoot"], ["special", "","back", "next_turn_target_debuff_no_position_change"]], "discard", "attack_special"],#DONE
	"Nitro" = [3, "Overtake. Enemy can't overtake next turn.",[["move","","overtake"], ["special","","all sides", "next_turn_target_debuff_no_position_change"]], "discard", "special"],#DONE
	"Emergency Brake" = [4,"Avoid an attack to the side.", [["special", "","side", "this_turn_you_avoid_side_attacks"]], "discard", "special"],#DONE
	"Ram" = [4, "LINE UP. Damage reduction this turn.",[["move","","line_up"],["special",3,"side","this_turn_damage_reduction_side_3"],], "discard", "defence"],#DONE
	"Shoot'em up" = [3, "+1 damage to all attacks premanently. BURN",[["special",1,"all sides","buff_all_attacks"]], "burn", "special"],#DONE
	"Explosive Maneouver" = [3, "OVERTAKE. +2 to the next attack",[["move","","overtake"],["special",2,"all sides","buff_next_attack"]], "discard", "special"],
	"Honk Honk" = [4, "OVERTAKE. Attack to the back",[["move","","overtake"],["attack",1,"back"]], "discard", "attack_special"],
	"Launcher Gallery" = [6, "Attack to the back. +1 damage to the next attack",[["attack",4,"back","shoot"],["special",1,"all sides","buff_next_attack"]], "discard", "attack_special"],
	"Hook, line and sinker" = [4, "OVERTAKE. Your next action will not change your position.",[["move","","overtake"],["special","","all sides","next_action_target_debuff_no_position_change"]], "discard", "defence_special"],
	"Pew Pew" = [2, "Attack to the front.",[["attack",1,"front","shoot"]], "discard", "attack"],#DONE
	"Letter D" = [1, "OVERTAKE. Avoid all enemy actions next turn and educe your damage by 2. BURN.",[["move","","overtake"],["special","","all sides","next_turn_avoid_all_actions"],["special",2,"all sides","next_turn_debuff_player_less_damage"]], "burn", "special"],
	"Whatever" = [1, "Give a random debuff: enemy damage reduced by 2, fuel cost increased by 2.",[["special","","all sides","random_debuff_attack_fuel"]], "discard", "special"],
	"Big Refill" = [1, "Reduce the fuel cost of the next action by 3.",[["special",3,"all sides","next_card_reduce_fuel"]], "discard", "special"],
	"Gimme Fuel" = [5, "Attack to the front or side. Increase the fuel cost of the next enemy action by 5.",[["attack",2,"side and front","shoot"],["special",5,"all sides","next_card_target_costs_more_fuel"]], "discard", "attack_special"],#DONE
	"Oil Spill" = [3, "OVERTAKE. Damage reduction this turn.",[["move","","overtake"],["special",2,"all sides","this_turn_damage_reduction"]], "discard", "defence"],
	"Gimme Fire" = [1, "Next turn your actions cost less per point of damage received this turn. BURN.",[["special","","all sides","next_turn_player_cassettes_cost_less_per_damage"]], "burn", "special"],
	"My name is Spike" = [3, "SLOW DOWN. Damage reduction from the attacks to the back this turn. Reflect 1 damage from enemy's next attack back to them.",[["move","","slow_down"],["special",1,"front","this_turn_damage_reduction_front"],["special",1,"all sides","reflect_damage_on_next_attack"]], "discard", "defence_special"],
	"Rail the Tail" = [3, "Attack to the front. Fuel cost of enemy actions increased by 1 permanently. BURN",[["attack",1,"front","ram"],["special",1,"all sides","until_end_all_cards_cost_more_fuel"]], "burn", "attack_special"],
	"Another One" = [5, "Damage reduction from attacks from front.",[["special","3","front","this_turn_attacks_from_front_wont_work"]], "discard", "defence"],#DONE
	"Pit Maneouver" = [7, "Attack to the side. Increase the fuel cost of the next enemy action by 2.",[["attack",5,"side","ram"],["special",2,"all sides","next_enemy_cassette_cost_more"]], "discard", "attack_special"],
	"Bites the Dust" = [4, "Attack in any direction. Add fuel spent so far as additional damage to this attack.",[["special",1,"all sides","attack_deals_damage_plus_spent_fuel_as_bonus_damage_all sides"]], "discard", "attack_special"],#DONE
	"Road Rage" = [8, "Attack in any direction. Damage reduction this turn.",[["attack",2,"all sides","ram"],["special",4,"all sides","next_attack_damage_reduction_any_side_4"]], "discard", "attack_defence"],#DONE
	"Burning Rubber" = [1, "OVERTAKE. Avoid next enemy attack. BURN.",[["move","","overtake"],["special","","all sides","next_attack_wont_work"]], "burn", "special"],
	"Kickdown" = [3, "LINE UP. Stay on the position this turn",[["move","","line_up"],["special","","all sides","this_turn_enemy_move_skills_don't_work"]], "discard", "special"],
	"Hit me baby" = [1, "SLOW DOWN. Damage reduction from the attacks to the back this turn.",[["move","","slow_down"],["special",2,"all sides","this_turn_damage_reduction_front_2"]], "discard", "defence"],
	"Roadslinger" = [5, "Attack to the side or back.",[["attack",3,"side and back","shoot"]], "discard", "attack"],#DONE
	"Drafting" = [2, "SLOW DOWN. Fuel cost of the next action reduced by 1 if you start on SLOW DOWN.",[["move","","slow_down"],["special",1,"all sides","next_turn_first_action_cost_less_if_you_start_in_slow_down"]], "discard", "special"],#DONE
	"Offence is Defence" = [2, "LINE UP. Damage reduction form attacks to the side this turn.",[["move","","line_up"],["special",2,"side","this_turn_damage_reduction_side_2"]], "discard", "defence"],#DONE
	"Run to Live" = [4, "SLOW DOWN. Damage reduction from attacks to the back this turn.",[["move","","slow_down"],["special",3,"front","this_turn_damage_reduction_front_3"]], "discard", "defence"],#DONE	
	"Perfectly Balanced" = [3, "LINE UP. Reduce fuel cost of the action by 1 when you LINE UP.",[["move","","line_up"],["side",1,"all sides","this_turn_reduce_fuel_cost_while_in_line_up"]], "discard", "special"],
	
	
	
	
	
	"Quick Attack" = [2, "Quick move to the next lane",[["move","","slow_down"]],"discard", "defence"],
	"Regular Attack" = [4, "Regular move that moves that lines up",[["move","","line_up"]],"discard", "defence"],
	"Heavy Attack" = [6, "Long move in front of enemy",[["move","","overtake"]],"discard", "defence"],
}
#[NAME, ICON_NAME, WHEN_HAPPENS, ANIMATION, DESCRIPTION,VALUE]
const BUFFS = {
	"this_turn_you_avoid_side_attacks" = ["this_turn_you_avoid_side_attacks","defence buff", "this_turn", "getting_buff", "Avoid Side Attacks this turn", ""],
	"buff_all_attacks" = ["buff_all_attacks","attack buff", "permanent", "getting_buff", "+1 to Attack Damage",1],
	"buff_all_attacks_2" = ["buff_all_attacks_2","attack buff", "permanent", "getting_buff", "+2 to Attack Damage",2],
	"buff_next_attack" = ["buff_next_attack","attack buff", "next_attack", "getting_buff", "+2 to Next Attack Damage", 2],
	"this_turn_attacks_from_front_wont_work" = ["this_turn_attacks_from_front_wont_work", "defence buff", "this_turn", "getting_buff", "This Turn attacks enemy attacks from front won't work", ""],
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
