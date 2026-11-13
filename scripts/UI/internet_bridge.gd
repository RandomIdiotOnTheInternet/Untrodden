extends CefTexture

@onready var bmail_lock_screen = %BmailLockScreen

## NOTE - As of 8/19/2026, this has been disabled until I can find a workaround.
## It keeps causing issues :(

## REMINDER - To make the buttons work to close this window, use
## Input.is_action_just_pressed() and whatnot to emulate the clicking of a button :D

var list_of_allowed_sites : Array = ["https://cluesbysam.com/",
"https://bloonstowerdefense.io/bloons-tower-defense-3",
"https://www.coolmathgames.com/0-idle-breakout",
"https://www.keyboardtester.com/tester.html", "https://www.google.com/"]

var last_url : String

func _on_url_changed(new_url):
	print(new_url)
	if new_url not in list_of_allowed_sites:
		hide()
		if last_url:
			url = last_url # This is done now to make things easier
		bmail_lock_screen.show()
	else:
		if new_url != last_url:
			last_url = new_url
			show()

func _on_cookie_timer_timeout():
	get_all_cookies()


func _on_cookies_received(cookies):
	pass
	#for cookie in cookies:
	#	print(cookie.name, " = ", cookie.value)


func _on_return_button_pressed():
	bmail_lock_screen.hide()
	$"../BmailScreen".show()
