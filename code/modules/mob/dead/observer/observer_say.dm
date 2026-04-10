/mob/dead/observer/check_emote(message, forced)
	return emote(copytext(message, length(message[1]) + 1), intentional = !forced, force_silence = TRUE)

/mob/dead/observer/say(
	message,
	bubble_type,
	list/spans = list(),
	sanitize = TRUE,
	datum/language/language,
	ignore_spam = FALSE,
	forced,
	filterproof = FALSE,
	message_range = 7,
	datum/saymode/saymode,
	list/message_mods = list(),
)
	message = trim(message)

	if (!message)
		return

	if(OOC_FILTER_CHECK(message))
		to_chat(src, span_warning("That message contained a word prohibited in OOC chat! Consider reviewing the server rules.") + "\n<span replaceRegex='show_filtered_ooc_chat'>\"[message]\"")
		return

	message = copytext_char(sanitize(message), 1, MAX_MESSAGE_LEN)
	if(message[1] == "*" && check_emote(message, forced))
		return

	. = say_dead(message)

/mob/dead/observer/Hear(atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, list/message_mods = list(), message_range)
	. = ..()
	var/atom/movable/to_follow = speaker
	if(radio_freq)
		var/atom/movable/virtualspeaker/V = speaker

		if(isAI(V.source))
			var/mob/living/silicon/ai/S = V.source
			to_follow = S.eyeobj
		else
			to_follow = V.source
	var/link = FOLLOW_LINK(src, to_follow)
	// Recompose the message, because it's scrambled by default
	var/message = compose_message(speaker, message_language, raw_message, radio_freq, spans, message_mods)
	to_chat(src,
		html = "[link] [message]",
		avoid_highlighting = speaker == src)
	return TRUE
