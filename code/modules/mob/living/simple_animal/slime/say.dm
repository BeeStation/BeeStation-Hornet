/mob/living/simple_animal/slime/Hear(atom/movable/speaker, message_language, raw_message, radio_freq, spans, list/message_mods = list(), message_range)
	. = ..()
	if(speaker != src && !radio_freq && !stat)
		if (speaker in Friends)
			speech_buffer = list()
			speech_buffer += speaker
			speech_buffer += LOWER_TEXT(html_decode(raw_message))
