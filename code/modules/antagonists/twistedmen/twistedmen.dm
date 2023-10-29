/datum/team/twistedmen
	name = "Twisted Men"
	show_roundend_report = FALSE

/datum/antagonist/twistedmen
	name = "Twisted Men"
	show_in_antagpanel = FALSE
	show_to_ghosts = TRUE
	prevent_roundtype_conversion = FALSE
	antagpanel_category = "Twisted Men"
	delay_roundend = FALSE
	count_against_dynamic_roll_chance = FALSE
	antag_moodlet = /datum/mood_event/twisted_good
	ui_name = "AntagInfoTwisted"

/datum/antagonist/twistedmen/greet()
	to_chat(owner, "<span class='boldannounce'>Your primary goal is to raid the crew and abduct victims to sacrifice to Father. Do not go out randomly on your own to die alone. \
	Head West first and then through the other paths once the crew has progressed far enough. Go and scare the crew! Make the Unshaped proud!.</span>")

