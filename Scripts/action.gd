extends Resource
class_name Action



#enum ATTACK {MOVE_TYPE, VALUE, TARGET_AREA, ANIMATION_TYPE}
#enum MOVE {MOVE_TYPE, DESTINATION}
#enum SPECIAL {MOVE_TYPE, VALUE, TARGET_AREA, EFFECT_NAME, AFFECTED_TARGET}
#{MOVE_TYPE, VALUE, MOVE_AREA, MOVE_INFO}

var action_type: int
var value: int
var target_area: int
var animation_type: String
var animation_name: String
var effect_name: String
var affected_target: int


func _init(action_type: int, kwargs: Dictionary = {}) -> void:
	self.action_type = action_type
	var allowed_fields = ["value", "target_area", "animation_type", "animation_name", "effect_name", "affected_target"]
	for key in kwargs.keys():
		if key in allowed_fields:
			self.set(key, kwargs[key])
		else:
			print("Unknown param:", key)
