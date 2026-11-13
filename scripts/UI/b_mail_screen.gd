extends Control
@onready var draft_text = %DraftText

@export var selected_bmail : Node

const CHOICE_CUTSCENE_ID = "bmail_choice"
const COMPOSE_CUTSCENE_ID = "bmail_compose"
const BMAIL_SCENE = preload("res://scenes/UI/Bmail.tscn")

var selected_bmail_data : BmailData

func _ready():
	$"Mail Pannel/BmailContainer/Bmail"._on_pressed()
	check_for_new_bmails(false)
	for bmail in Global.game_data.current_bmails:
		var new_bmail = BMAIL_SCENE.instantiate()
		new_bmail.data = bmail
		%BmailContainer.add_child(new_bmail)

func _on_delete_button_pressed():
	if selected_bmail:
		$"Draft Pannel".hide()
		selected_bmail.queue_free()
		%TopBmailText.text = ""
		%BottomBmailText.text = ""

func _on_reply_button_pressed():
	%SendButton.disabled = true
	var cutscene = Cutscene.new()
	cutscene.cutscene_id = CHOICE_CUTSCENE_ID
	%CutscenePlayer.start_cutscene(null, cutscene, true)

func _on_send_button_pressed():
	$"Draft Pannel".hide()

func start_new_bmail(option_picked : DecisionOption):
	selected_bmail_data = selected_bmail.data
	$"Draft Pannel".show()
	var new_subject = selected_bmail_data.subject
	%TopDraftText.text = ("From: You\nTo: " + selected_bmail_data.author + "\n\nRE: " + new_subject)
	draft_text.text = option_picked.decision_result
	draft_text.visible_characters = 0
	draft_text.revealing = true # Starts it off since it's typing


func _on_reply_text_finished_revealing():
	%SendButton.disabled = false

func new_bmail_decision():
	%CutscenePlayer.new_decision(selected_bmail_data.decision)


func _on_compose_pressed():
	%SendButton.disabled = true
	var cutscene = Cutscene.new()
	cutscene.cutscene_id = COMPOSE_CUTSCENE_ID
	%CutscenePlayer.start_cutscene(null, cutscene, true)

# Adds future bmails to the list of current bmails. add_to_scene is for
# adding them during the day.
func check_for_new_bmails(add_to_scene : bool = false):
	for bmail in Global.game_data.future_incoming_bmails:
		if bmail.arrival_time:
			if bmail.arrival_time.is_greater_than(Global.game_data.world_time):
				Global.game_data.future_incoming_bmails.erase(bmail)
				Global.game_data.current_bmails.append(bmail)
				if add_to_scene:
					var new_bmail = BMAIL_SCENE.instantiate()
					new_bmail.data = bmail
					%BmailContainer.add_child(new_bmail)
		else:
			print("ERROR - Bmail without an arrival time detected! Bmail subject: " + str(bmail.subject))
