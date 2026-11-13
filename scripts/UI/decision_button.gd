extends Button
class_name DecisionButton
signal decision_made(option_picked : DecisionOption)

@export var my_option : DecisionOption
@onready var button_label = %ButtonLabel # Used in player_ui

func new_decision(decision_option : DecisionOption):
	button_label.text = decision_option.decision_description
	my_option = decision_option
	
	
	%ReasoningText.text = decision_option.decision_reasoning
	for reqirement in decision_option.requirements:
		if not reqirement.check_value():
			if my_option.requirements_hide:
				hide()
				return false
			if reqirement.description:
				button_label.text = reqirement.description
				disabled = true
			else:
				visible = false
				return false
	#for cost in decision_option.costs:
	#	%CostText.text += cost.description + "\n"
	
	visible = true

func _on_pressed():
	$ReasoningPanel.hide()
	Juicee.button_punch(self, 1.1)
	emit_signal("decision_made", my_option)
	for cost in my_option.costs:
		cost.apply()
	
	# Note - this needs to happen last to prevent errors
	if my_option.deeper_option:
		print("Applied new option")
		my_option = my_option.deeper_option


func _on_mouse_entered():
	if len(%ReasoningText.text) > 0:
		$ReasoningPanel.show()


func _on_mouse_exited():
	$ReasoningPanel.hide()


func _on_reasoning_panel_mouse_entered():
	if len(%ReasoningText.text) > 0:
		$ReasoningPanel.show()


func _on_reasoning_panel_mouse_exited():
	$ReasoningPanel.hide()
