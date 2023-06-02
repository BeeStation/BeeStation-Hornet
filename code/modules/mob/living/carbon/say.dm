/mob/living/carbon/proc/handle_tongueless_speech(mob/living/carbon/speaker, list/speech_args)
	SIGNAL_HANDLER

	var/obj/item/organ/tongue/tongue = speaker.getorganslot(ORGAN_SLOT_TONGUE)
	if(tongue && !CHECK_BITFIELD(tongue.organ_flags, ORGAN_FAILING))
		speaker.UnregisterSignal(speaker, COMSIG_MOB_SAY)
		return
	var/message = speech_args[SPEECH_MESSAGE]
	var/static/regex/tongueless_lower = new("\[gdntke]+", "g")
	var/static/regex/tongueless_upper = new("\[GDNTKE]+", "g")
	if(message[1] != "*")
		message = tongueless_lower.Replace(message, pick("aa","oo","'"))
		message = tongueless_upper.Replace(message, pick("AA","OO","'"))
		speech_args[SPEECH_MESSAGE] = message

/mob/living/carbon/can_speak_vocal(message)
	if(silent)
		return FALSE
	return ..()

/mob/living/carbon/could_speak_language(datum/language/dt)
	if(CHECK_BITFIELD(initial(dt.flags), TONGUELESS_SPEECH))
		return TRUE
	var/obj/item/organ/tongue/T = getorganslot(ORGAN_SLOT_TONGUE)
	if(T)
		return T.could_speak_language(dt)
	return FALSE
