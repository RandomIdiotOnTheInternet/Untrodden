extends Control

@export var startup_cutscene : Cutscene

func _ready():
	$CutscenePlayer.start_cutscene(null, startup_cutscene, true)

func _on_exit_pressed():
	get_tree().quit()


func _on_play_pressed():
	Global.load_game(1, true)

func fade_in():
	$AnimationPlayer.play("title_screen_fade_in")
