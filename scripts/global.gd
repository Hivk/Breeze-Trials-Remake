extends Node

# SCENES
var save_dir
var map_dir
var music_dir

# SETTINGS VARIABLES
var sens = 0.1

func _ready() -> void:
	paths()
	fix_paths()

func paths() -> void:
	if OS.has_feature("editor"): save_dir = "res://save_data"
	else: save_dir = OS.get_executable_path().get_base_dir().path_join("save_data")
	
	map_dir = save_dir.path_join("maps")
	music_dir = save_dir.path_join("music")

func fix_paths(): # Deepseek Code
	# Create directories if they don't exist
	var dir = DirAccess.open(save_dir)
	if not dir.dir_exists(map_dir):
		dir.make_dir_recursive(map_dir)
	if not dir.dir_exists(music_dir):
		dir.make_dir_recursive(music_dir)
