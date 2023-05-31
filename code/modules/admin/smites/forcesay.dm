/datum/smite/forcesay
	name = "Forcesay"

/datum/smite/forcesay/effect(client/user, mob/living/target)
	. = ..()
	var/forced_speech = input(usr, "What will they say?") as null|text
	if(isnull(forced_speech)) //The user pressed "Cancel"
		return

	target.say(forced_speech, forced = "admin speech")
