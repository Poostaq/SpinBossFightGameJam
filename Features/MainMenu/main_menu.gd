class_name MainMenu
extends Node2D

signal start_game

func _ready():
	show_main_menu()

func show_main_menu():
	$MainMenuButtons.visible = true
	$OptionsMenu.visible = false

func show_options_menu():
	$MainMenuButtons.visible = false
	$OptionsMenu.visible = true

func _on_options_button_pressed():
	show_options_menu()

func _on_back_button_pressed():
	show_main_menu()


func _on_start_pressed() -> void:
	start_game.emit()


func _on_exit_pressed() -> void:
	get_tree().quit()
