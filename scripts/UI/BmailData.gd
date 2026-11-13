extends Resource
class_name BmailData

@export var author : String = "(Unknkown Address)"
@export var recipients : String = "You"
@export var subject : String = "-New Subject-"
@export var arrival_time : DateTime
@export_multiline("Write silly stuff here") var inbound_body = ""
@export var decision : Decision
# Unused yet as of 7/28/2026
@export var starting_cutscene : StringName
# Unused yet as of 7/28/2026
@export var ending_cutscene : StringName
