extends Button

@export var data : BmailData

func _ready():
	text = data.author + "\n" + data.subject

func _on_pressed():
	%TopBmailText.text = ("From: " + data.author + "\nTo: " + 
	data.recipients + "\n\n" + data.subject)
	%BottomBmailText.text = data.inbound_body
	owner.selected_bmail = self
	owner.selected_bmail_data = data

func deleted():
	queue_free()
