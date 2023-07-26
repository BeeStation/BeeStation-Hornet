/datum/smite/forcesay
	name = "Forcesay"

/datum/smite/forcesay/effect(client/user, mob/living/target)
	. = ..()
	var/forced_speech = tgui_input_text(usr, "What will they say?")
	if(isnull(forced_speech)) //The user pressed "Cancel"
		return

	target.say(forced_speech, forced = "admin speech")
