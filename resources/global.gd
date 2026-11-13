extends Node

var debug = true ## For testing only :)

var save_path = "res://save_files/untrodden_save_slot_BACKUP.json"
var selected_save_slot = 1

var loading_screen = preload("res://scenes/UI/loading_screen.tscn")
var next_scene : StringName = "res://scenes/world/test_world.tscn"

var game_data : SaveFile
# This exists beause the game_data file should only be updated after
# cutscene it'll just revert :)
var current_interacted_interactions : Array[StringName]

enum GAMESTATE {Paused, InGame, InCutscene, Menu}
var current_gamestate = GAMESTATE.InGame

## This variable will store all the controls available to the player.
enum CONTROL_STATE {NoControl, Cutscene, CutsceneAdvance, HasControl}
var current_control_state = CONTROL_STATE.NoControl
var old_control_state : CONTROL_STATE


## This is used to globally access the text box.
var player_ui : Node

var world_timer : Timer # Currently started in main_character... although needs work

## -----------------------------
## GAME SETTINGS
## -----------------------------
var text_speed = 0.5 # Smaller = faster
var flashing_lights = true

func _ready():
	Input.set_custom_mouse_cursor(load("res://assets/images/UI/Keyboard & Mouse/Default/cursorArrow.png"), Input.CURSOR_ARROW)
	Input.set_custom_mouse_cursor(load("res://assets/images/UI/Keyboard & Mouse/Default/cursorIBeam.png"), Input.CURSOR_IBEAM)
	Input.set_custom_mouse_cursor(load("res://assets/images/UI/Keyboard & Mouse/Default/cursorPointingHand.png"), Input.CURSOR_POINTING_HAND)
	Input.set_custom_mouse_cursor(load("res://assets/images/UI/Keyboard & Mouse/Default/cursorForbidden.png"), Input.CURSOR_FORBIDDEN)
	Input.set_custom_mouse_cursor(load("res://assets/images/UI/Keyboard & Mouse/Default/cursorDrag.png"), Input.CURSOR_DRAG)
	Input.set_custom_mouse_cursor(load("res://assets/images/UI/Keyboard & Mouse/Default/cursorThreeBar.png"), Input.CURSOR_CAN_DROP)
	
	world_timer = Timer.new()
	add_child(world_timer)
	world_timer.timeout.connect(tick_time)
	
	if debug:
		
		load_game(1, false)
		print("GLOBAL - DEBUG - Loaded save slot 1.")

func change_control_state(new_state):
	current_control_state = new_state

func change_scene(new_next_scene : StringName):
	next_scene = new_next_scene
	game_data.current_scene = next_scene
	game_data.interacted_interactions.append_array(current_interacted_interactions)
	current_interacted_interactions.clear()
	get_tree().change_scene_to_packed(loading_screen)

# For the world timer :)
func tick_time():
	advance_time(1)

func advance_time(value : int):
	game_data.world_time.advance_time(1)

func save_game():
	if game_data:
		var error_check = ResourceSaver.save(game_data, save_path)
		if error_check == OK:
			print("Game saved :D")
		else:
			print("ERROR SAVING: " + str(error_check))
	else:
		print("ERROR SAVING: No game data detected.")

func load_game(slot : int, change_scene_now : bool):
	save_path = "res://save_files/untrodden_save_slot_" + str(slot) + ".tres"
	if ResourceLoader.exists(save_path):
		print("Save slot " + str(slot) + " loaded.")
		game_data = ResourceLoader.load(save_path)
	else:
		print("New save created for slot " + str(slot) + ".")
		game_data = SaveFile.new() # Loads a new boi
	if change_scene_now:
		change_scene(game_data.current_scene)
