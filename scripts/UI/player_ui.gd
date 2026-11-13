extends Control

signal decision_made(option_picked : DecisionOption)

const DIALOGUE_FRONT_INDEX = 3

@onready var text_box = $TextBox # Accessed by cutscenes and whatnot

func _ready():
	Global.player_ui = self

func _input(event):
	if Input.is_action_just_pressed("pause"):
		
		if get_tree().paused == true:
			$PauseMenu.visible = false
			get_tree().paused = false
		else:
			$PauseMenu.visible = true
			get_tree().paused = true

func end_cutscene(cutsceneID : StringName):
	$"UI Animations".play("cutscene_end")


func start_cutscene(cutsceneID : StringName):
	$"UI Animations".play("cutscene_start")

func enter_door():
	$"UI Animations".play("black_screen_fade_in")

func new_decision(new_decision : Decision):
	var index = 0
	$"UI Animations".play("decision_start")
	for option in new_decision.options:
		var decision_button = %DecisionContainer.get_children()[index]
		var decision_option = new_decision.options[index]
		
		var requirement_check : bool = true
		for reqirement in option.requirements:
			if not reqirement.check_value():
				requirement_check = false
		
		if requirement_check:
			decision_button.new_decision(decision_option)
		else:
			if option.requirements_hide:
				decision_button.hide()
		
		index += 1

func _on_decision_made(option_picked : DecisionOption):
	$"UI Animations".play("decision_end")
	emit_signal("decision_made", option_picked)

func dialogue_finished(waits_afterwards : bool):
	if waits_afterwards:
		%ScreenNoticeLabel.text = "[pulse freq=0.5](Click to continue...)"
		Global.change_control_state(Global.CONTROL_STATE.CutsceneAdvance)

func dialogue_resumed():
	Juicee.fade(%ScreenNoticeLabel, 0, 0.25)
