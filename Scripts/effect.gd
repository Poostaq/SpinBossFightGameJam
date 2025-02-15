extends Resource
class_name Effect


enum DurationType {
	UNTIL_NEXT_TURN,
	UNTIL_NEXT_CARD,
	UNTIL_NEXT_ACTION,
	UNTIL_NEXT_ATTACK, 
	PERMANENT
}

var duration_type : DurationType
var effect_identifier : String
var is_active: bool
var value: int
var description

func _init(duration_type: DurationType, effect_identifier: String = "", value: int = 0):
	self.duration_type = duration_type
	self.value = value
	self.effect_identifier = effect_identifier
