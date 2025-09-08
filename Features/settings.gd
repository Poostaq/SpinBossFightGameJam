extends Node

class_name Settings
@export
var master_volume: float = 1.0
@export
var music_volume: float = 1.0
@export
var sfx_volume: float = 1.0
@export
var skip_fuel_comparison: bool = false
@export
var battle_speed: float = 2.0
@export
var show_tooltip: bool = true


var temp_master_volume: float = 1.0
var temp_music_volume: float = 1.0
var temp_sfx_volume: float = 1.0
var temp_skip_fuel_comparison: bool = false
var temp_battle_speed: float = 2.0
var temp_show_tooltip: bool = true

func set_setting(key: String, value, use_temp: bool = false) -> void:
    if use_temp:
        match key:
            "master_volume":
                temp_master_volume = value
            "music_volume":
                temp_music_volume = value
            "sfx_volume":
                temp_sfx_volume = value
            "skip_fuel_comparison":
                temp_skip_fuel_comparison = value
            "battle_speed":
                temp_battle_speed = value
            "show_tooltip":
                temp_show_tooltip = value
            _:
                print("Invalid setting key: %s" % key)
    else:
        match key:
            "master_volume":
                master_volume = value
            "music_volume":
                music_volume = value
            "sfx_volume":
                sfx_volume = value
            "skip_fuel_comparison":
                skip_fuel_comparison = value
            "battle_speed":
                battle_speed = value
            "show_tooltip":
                show_tooltip = value
            _:
                print("Invalid setting key: %s" % key)

func get_setting(key: String, use_temp: bool = false):
    if use_temp:
        match key:
            "master_volume":
                return temp_master_volume
            "music_volume":
                return temp_music_volume
            "sfx_volume":
                return temp_sfx_volume
            "skip_fuel_comparison":
                return temp_skip_fuel_comparison
            "battle_speed":
                return temp_battle_speed
            "show_tooltip":
                return temp_show_tooltip
            _:
                print("Invalid setting key: %s" % key)
                return null
    else:
        match key:
            "master_volume":
                return master_volume
            "music_volume":
                return music_volume
            "sfx_volume":
                return sfx_volume
            "skip_fuel_comparison":
                return skip_fuel_comparison
            "battle_speed":
                return battle_speed
            "show_tooltip":
                return show_tooltip
            _:
                print("Invalid setting key: %s" % key)
                return null

func save_settings(file_path: String = "user://settings.cfg") -> void:
    master_volume = temp_master_volume
    music_volume = temp_music_volume
    sfx_volume = temp_sfx_volume
    skip_fuel_comparison = temp_skip_fuel_comparison
    battle_speed = temp_battle_speed
    show_tooltip = temp_show_tooltip

    var config = ConfigFile.new()
    config.set_value("settings", "master_volume", master_volume)
    config.set_value("settings", "music_volume", music_volume)
    config.set_value("settings", "sfx_volume", sfx_volume)
    config.set_value("settings", "skip_fuel_comparison", skip_fuel_comparison)
    config.set_value("settings", "battle_speed", battle_speed)
    config.set_value("settings", "show_tooltip", show_tooltip)
    config.save(file_path)

func load_settings(file_path: String = "user://settings.cfg") -> void:
    var config = ConfigFile.new()
    if config.load(file_path) == OK:
        master_volume = config.get_value("settings", "master_volume", master_volume)
        music_volume = config.get_value("settings", "music_volume", music_volume)
        sfx_volume = config.get_value("settings", "sfx_volume", sfx_volume)
        skip_fuel_comparison = config.get_value("settings", "skip_fuel_comparison", skip_fuel_comparison)
        battle_speed = config.get_value("settings", "battle_speed", battle_speed)
        show_tooltip = config.get_value("settings", "show_tooltip", show_tooltip)

        temp_master_volume = master_volume
        temp_music_volume = music_volume
        temp_sfx_volume = sfx_volume
        temp_skip_fuel_comparison = skip_fuel_comparison
        temp_battle_speed = battle_speed
        temp_show_tooltip = show_tooltip
    else:
        print("Failed to load settings file.")

func revert_temp_settings() -> void:
    temp_master_volume = master_volume
    temp_music_volume = music_volume
    temp_sfx_volume = sfx_volume
    temp_skip_fuel_comparison = skip_fuel_comparison
    temp_battle_speed = battle_speed
    temp_show_tooltip = show_tooltip