class_name StatusEffect
extends Node2D

var effect_name: String
var icon_name: String
var when_active: String
var animation_to_play: String
var description: String
var duration: int
var value: int
var affected_target: int

func _init(
	_name: String,
	_icon: String,
	_when: String,
	_anim: String,
	_desc: String,
	_duration: int,
	_value: int,
	_target: int
):
	effect_name = _name
	icon_name = _icon
	when_active = _when
	animation_to_play = _anim
	description = _desc
	duration = _duration
	value = _value
	affected_target = _target
