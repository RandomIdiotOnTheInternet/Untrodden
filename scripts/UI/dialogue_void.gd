extends Control

func _ready():
	$CutscenePlayer.start_cutscene(null, Global.game_data.current_cutscene, true)
