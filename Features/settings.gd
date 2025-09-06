extends Node

class_name Settings
@export
var master_volume: float = 1.0
@export
var music_volume: float = 1.0
@export
var sfx_volume: float = 1.0
@export
var skip_fuel_comparison: bool = true

# Temporary settings for changes
var temp_master_volume: float = 1.0
var temp_music_volume: float = 1.0
var temp_sfx_volume: float = 1.0
var temp_skip_fuel_comparison: bool = false

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
            _:
                print("Invalid setting key: %s" % key)
                return null

func save_settings(file_path: String = "user://settings.cfg") -> void:
    # Save the temporary settings as the actual settings
    master_volume = temp_master_volume
    music_volume = temp_music_volume
    sfx_volume = temp_sfx_volume
    skip_fuel_comparison = temp_skip_fuel_comparison

    var config = ConfigFile.new()
    config.set_value("settings", "master_volume", master_volume)
    config.set_value("settings", "music_volume", music_volume)
    config.set_value("settings", "sfx_volume", sfx_volume)
    config.set_value("settings", "skip_fuel_comparison", skip_fuel_comparison)
    config.save(file_path)

func load_settings(file_path: String = "user://settings.cfg") -> void:
    var config = ConfigFile.new()
    if config.load(file_path) == OK:
        master_volume = config.get_value("settings", "master_volume", master_volume)
        music_volume = config.get_value("settings", "music_volume", music_volume)
        sfx_volume = config.get_value("settings", "sfx_volume", sfx_volume)
        skip_fuel_comparison = config.get_value("settings", "skip_fuel_comparison", skip_fuel_comparison)

        # Initialize temporary settings with loaded values
        temp_master_volume = master_volume
        temp_music_volume = music_volume
        temp_sfx_volume = sfx_volume
        temp_skip_fuel_comparison = skip_fuel_comparison
    else:
        print("Failed to load settings file.")

func revert_temp_settings() -> void:
    # Revert temporary settings to the actual settings
    temp_master_volume = master_volume
    temp_music_volume = music_volume
    temp_sfx_volume = sfx_volume
    temp_skip_fuel_comparison = skip_fuel_comparison