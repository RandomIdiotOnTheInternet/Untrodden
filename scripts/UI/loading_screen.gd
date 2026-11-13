extends Control

var next_scene = Global.next_scene

func _ready():
	# Resetting Globals
	if Global.old_control_state:
		Global.change_control_state(Global.old_control_state)
	Global.current_gamestate = Global.GAMESTATE.InGame
	
	ResourceLoader.load_threaded_request(next_scene)

func _process(delta):
	var progress = []
	ResourceLoader.load_threaded_get_status(next_scene, progress)
#	$ProgressBar.value = progress[0] * 100
	
	if progress[0] == 1:
		var packedScene = ResourceLoader.load_threaded_get(next_scene)
		Global.save_game()
		get_tree().change_scene_to_packed(packedScene)
