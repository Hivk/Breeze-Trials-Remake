extends Control

var exitjuice = 0

@onready var scene = $"main_menu"

@onready var main = $"main_menu"
@onready var maps = $"maps"
@onready var credits = $"credits"
@onready var settings = $"settings"
@onready var custom = $"custom"


func _process(delta: float) -> void:
	# Exit
	
	if Input.is_action_pressed("esc"): exitjuice += delta
	else: exitjuice = 0
	
	if exitjuice > 0.5:
		exitjuice = -9999
		
		if scene == main: pass # get_tree().quit()
		else: menu(main)

# MENU BUTTONS
# Syntax: _oldmenu_newmenu():
# menu() argument is the node of the new menu.

func menu(new: Node):
	scene.hide()
	new.show()
	scene = new
	
# From Main Menu

func _main_maps() -> void: menu(maps)
func _main_custom() -> void: menu(custom)
func _main_settings() -> void: menu(settings)
func _main_credits() -> void: menu(credits)
#func _main_quit() -> void: get_tree().quit()

# Returns
func _maps_main() -> void:menu(main)
func _cm_main() -> void: menu(main)
func _settings_exit() -> void: menu(main)
func _credits_exit() -> void: menu(main)

# --- # --- # --- # --- # --- # --- # --- #


func _main_maps_list_click(index: int, _at_position: Vector2, _mouse_button_index: int) -> void:
	if index == 3: get_tree().change_scene_to_file("res://scenes/ingame/ingame.tscn")
