/mob/living/silicon/pai/say(message, bubble_type, list/spans, sanitize, datum/language/language, ignore_spam, forced, filterproof, message_range, datum/saymode/saymode, list/message_mods)
	if(silent)
		to_chat(src, span_warning("Communication circuits remain unitialized."))
	else
		..()

/mob/living/silicon/pai/binarycheck()
	return radio?.translate_binary
