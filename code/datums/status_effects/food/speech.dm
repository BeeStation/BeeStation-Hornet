///Temporary modifies the speech using the /datum/component/speechmod
/datum/status_effect/food/speech

/datum/status_effect/food/speech/italian
	alert_type = /atom/movable/screen/alert/status_effect/italian_speech

/datum/status_effect/food/speech/italian/on_apply()
	RegisterSignal(owner, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/status_effect/food/speech/italian/on_remove()
	. = ..()
	UnregisterSignal(owner, COMSIG_MOB_SAY)

/datum/status_effect/food/speech/italian/proc/handle_speech(datum/source, list/speech_args)	//Did not change this due to the ridiculous append that is perhaps okay? (I dislike it personally)
	var/message = speech_args[SPEECH_MESSAGE]
	if(message[1] != "*")
		message = " [message]"
		var/list/italian_words = strings(ITALIAN_TALK_FILE, "words")

		for(var/key in italian_words)
			var/value = italian_words[key]
			if(islist(value))
				value = pick(value)

			message = replacetextEx(message, " [uppertext(key)]", " [uppertext(value)]")
			message = replacetextEx(message, " [capitalize(key)]", " [capitalize(value)]")
			message = replacetextEx(message, " [key]", " [value]")

		if(prob(3))
			message += pick(" Ravioli, ravioli, give me the formuoli!"," Mamma-mia!"," Mamma-mia! That's a spicy meat-ball!", " La la la la la funiculi funicula!")
	speech_args[SPEECH_MESSAGE] = trim(message)

/atom/movable/screen/alert/status_effect/italian_speech
	name = "Linguini Embrace"
	desc = "You feel a sudden urge to gesticulate wildly."
	icon_state = "food_italian"


/// fr*nch
/datum/status_effect/food/speech/french
	alert_type = /atom/movable/screen/alert/status_effect/french_speech

/datum/status_effect/food/speech/french/on_apply()
	RegisterSignal(owner, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/status_effect/food/speech/french/on_remove()
	. = ..()
	UnregisterSignal(owner, COMSIG_MOB_SAY)

/datum/status_effect/food/speech/french/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER
	var/message = speech_args[SPEECH_MESSAGE]
	if(message[1] != "*")
		message = " [message]"
		var/list/french_words = strings(FRENCH_TALK_FILE, "french")

		for(var/key in french_words)
			var/value = french_words[key]
			if(islist(value))
				value = pick(value)

			message = replacetextEx(message, " [uppertext(key)]", " [uppertext(value)]")
			message = replacetextEx(message, " [capitalize(key)]", " [capitalize(value)]")
			message = replacetextEx(message, " [key]", " [value]")

		if(prob(3))
			message += pick(" Honh honh honh!"," Honh!"," Zut Alors!")
	speech_args[SPEECH_MESSAGE] = trim(message)

/atom/movable/screen/alert/status_effect/french_speech
	name = "Café Chic"
	desc = "Suddenly, everything seems worthy of a passionate debate."
	icon_state = "food_french"
