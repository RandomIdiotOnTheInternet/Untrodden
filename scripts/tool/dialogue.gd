extends Resource
class_name Dialogue

@export_multiline() var text : String
@export var left_portrait : CompressedTexture2D
@export var right_portrait : CompressedTexture2D
@export var text_sound : AudioStream
@export var waits : bool = true
@export var reset_text : bool = true
# A value of -1 meats that the alignment should be unchanged.
@export_enum("No Change:-1", "Left:0", "Center:1", "Right:2") var horizontal_alignment : int = -1

@export_group("Revealing Modifiers")
@export var reveal_speed_modifier : float = 1.0
@export var pitch_scale : float = 1.0

@export_group("Gated")
@export var gate : DataHolder
@export var deeper_dialogue : Dialogue

func apply_self():
	if len(text) > 0:
		Global.player_ui.text_box.new_dialogue(self)
