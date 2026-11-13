extends ConfirmationDialog
signal decisionMade(ID : StringName)

var decisionID : StringName

func _on_decision_button_pressed(ID : StringName):
	show()
	decisionID = ID


func _on_confirmed():
	match decisionID:
		"INSERT_ID_THAT_MAKES_YOU_CLICK_ALOT":
			change_text("[wave]Are you reeeeeally sure???")
			ok_button_text = "Yes..?"
			cancel_button_text = "Nah"
		_:
			hide()
			emit_signal("decisionMade", decisionID)
			# Add the deed to Global
			pass

func change_text(text : String):
	$ConfirmationLabel.text = text
