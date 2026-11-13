extends Control

## NOTE - As of 6/16/2026, the CEF guy when visible stops other buttons :(

func close_window():
	%Window.hide()
	%InternetBridge.url = ""

func _ready():
	await get_tree().create_timer(1.0).timeout
	var beginning_cutscene = Cutscene.new()
	beginning_cutscene.cutscene_id = "day_" + str(Global.game_data.day) + "/begin_work"
	$CutscenePlayer.start_cutscene(null, beginning_cutscene, true)
