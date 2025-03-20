extends Node2D

func _ready() -> void:
	Database.load_all_data()
	
	print(Database.cassettes)
