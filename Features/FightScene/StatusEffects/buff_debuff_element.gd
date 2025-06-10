extends TextureRect

enum DE_BUFF {DE_BUFF_NAME, ICON_NAME, WHEN_ACTIVIVE, ANIMATION_TO_PLAY, DESCRIPTION, VALUE}

var de_buff_data

func set_icon():
	self.texture = load("res://Images/vfx/Icons/"+de_buff_data[DE_BUFF.ICON_NAME]+".png")
	
func set_tooltip():
	self.tooltip_text = de_buff_data[DE_BUFF.DESCRIPTION]
