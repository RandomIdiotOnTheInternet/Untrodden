extends Resource
class_name DateTime

@export var year : int = 2147 # The year the game takes place
# NOTICE - Any values of count as non-existant for chacking stuff
@export var day : int = 1
@export var hour : int = 0
@export var minute : int = 0
@export var second : int = 0

func is_equal_to(other_time : DateTime):
	if (other_time.year == year) or (year == -1):
		if (other_time.day == day) or (day == -1):
			if (other_time.hour == hour) or (hour == -1):
				if (other_time.minute == minute) or (minute == -1):
					if (other_time.second == second) or (second == -1):
						return true
	return false

func is_greater_than(other_time : DateTime):
	if (other_time.year <= year) or (year == -1):
		if (other_time.day <= day) or (day == -1):
			if (other_time.hour <= hour) or (hour == -1):
				if (other_time.minute <= minute) or (minute == -1):
					if (other_time.second <= second) or (second == -1):
						return true
	return false

func advance_time(seconds : int = 0, minutes : int = 0, hours : int = 0, days : int = 0):
	second += seconds
	minute += minutes
	hour += hours
	if second >= 60:
		second -= 60
		advance_time(0, 1)
		return
	if minute >= 60:
		minute -= 60
		advance_time(0, 0, 1)
		return
	if hour >= 24:
		hour -= 24
		advance_time(0,0,0,1)
		return
