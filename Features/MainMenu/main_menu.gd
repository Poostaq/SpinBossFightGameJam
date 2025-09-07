class_name MainMenu
extends Node2D

const SETTINGS_FILE_PATH = "user://settings.cfg"

@onready var settings: Settings = $Settings

signal start_game

func _ready():
    settings.load_settings(SETTINGS_FILE_PATH)
    show_main_menu()

func show_main_menu():
    $MainMenuButtons.visible = true
    $OptionsMenu.visible = false

func show_options_menu():
    $MainMenuButtons.visible = false
    $OptionsMenu.visible = true
    $OptionsMenu/MasterSlider.value = settings.get_setting("master_volume", true)
    $OptionsMenu/MusicSlider.value = settings.get_setting("music_volume", true)
    $OptionsMenu/SFXSlider.value = settings.get_setting("sfx_volume", true)
    $OptionsMenu/SkipFuelComparisonToggle.pressed = settings.get_setting("skip_fuel_comparison", true)
    $OptionsMenu/SpinBox.value = settings.get_setting("battle_speed", true)
    $OptionsMenu/ShowTooltipsToggle.pressed = settings.get_setting("show_tooltip", true)  # Load tooltip setting

func _on_options_button_pressed():
    show_options_menu()

func _on_back_button_pressed():
    # Revert temporary settings
    settings.revert_temp_settings()
    show_main_menu()

func _on_start_pressed() -> void:
    start_game.emit()

func _on_exit_pressed() -> void:
    get_tree().quit()

func _on_save_button_pressed():
    # Save temporary settings as actual settings
    settings.save_settings(SETTINGS_FILE_PATH)
    show_main_menu()

func _on_master_slider_value_changed(value: float) -> void:
    settings.set_setting("master_volume", value, true)

func _on_music_slider_value_changed(value: float) -> void:
    settings.set_setting("music_volume", value, true)

func _on_sfx_slider_value_changed(value: float) -> void:
    settings.set_setting("sfx_volume", value, true)

func _on_skip_fuel_comparison_toggle_toggled(toggled_on: bool) -> void:
    settings.set_setting("skip_fuel_comparison", toggled_on, true)

func _on_spin_box_value_changed(value: float) -> void:
    settings.set_setting("battle_speed", value, true)

func _on_show_tooltips_toggle_toggled(toggled_on: bool) -> void:
    settings.set_setting("show_tooltip", toggled_on, true)
