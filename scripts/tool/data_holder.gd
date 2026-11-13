extends Resource
class_name DataHolder

@export var value : String
## Paths such as world_time.hour need to be expressed as world_time:hour to be
## correctly read by get_indexed().
@export_multiline() var data_type : String
@export_enum("Greater Than:1", "Less Than:2", "Equals:3", "Greater Than/Equals:4
", "Less Than/Equals:5", "Length Greater Than/Equals (Arrays Only):6") var comparator = 1
@export_multiline var description : String

func check_value():
	var global_data = Global.game_data.get_indexed(data_type)
	var value_check = value
	
	match typeof(global_data):
		TYPE_INT:
			value_check = value_check.to_int()
			return compare_values(global_data, value_check)
		TYPE_FLOAT:
			value_check = value_check.to_float()
			return compare_values(global_data, value_check)
		TYPE_BOOL:
			value_check = bool(value.to_int())
			if global_data == value_check:
				return true
			else:
				return false
		TYPE_ARRAY:
			if comparator == 6: # Length check
				var length = str(len(global_data))
				if length >= value_check:
					return true
				else:
					return false
			else: # Do stuff normally
				for item in global_data:
					if not compare_values(item, value_check):
						return false
				return true
	
	if global_data == value_check:
		return true
	else:
		return false

func compare_values(this, that):
	if comparator:
		match comparator:
			1: # Greater Than
				if this > that:
					return true
				else:
					return false
			2: # Less than
				if this < that:
					return true
				else:
					return false
			3: # Equals
				if this == that:
					return true
				else:
					return false
			4: # Greater Than / Equals
				if this >= that:
					return true
				else:
					return false
			5: # Less Than / Equals
				if this <= that:
					return true
				else:
					return false
			_:
				if this == that:
					return true
				else:
					return false

func apply():
	if data_type:
		var global_data = Global.game_data.get_indexed(data_type)
		match typeof(global_data):
			TYPE_STRING:
				Global.game_data.set_indexed(data_type, value)
			TYPE_INT:
				Global.game_data.set_indexed(data_type, global_data + value.to_int())
			TYPE_FLOAT:
				Global.game_data.set_indexed(data_type, global_data + value.to_float())
			TYPE_BOOL:
				var result : bool = bool(value.to_int())
				Global.game_data.set_indexed(data_type, result)
			_:
				print("!Unhandled data type applied in data_holder.gd! Type given: " + str(typeof(global_data)))
				Global.game_data.set_indexed(data_type, value)
