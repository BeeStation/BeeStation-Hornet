/mob/living/proc/robot_talk(message, list/spans = list(), list/message_mods = list())
	//Cannot transmit wireless messages while jammed
	if(is_jammed(JAMMER_PROTECTION_SILICON_COMMS))
		return
	if(CHAT_FILTER_CHECK(message))
		to_chat(usr, span_warning("Your message contains forbidden words."))
		return
	log_sayverb_talk(message, message_mods, tag="binary")

	var/designation = "Default Cyborg"
	spans |= SPAN_ROBOT

	if(issilicon(src))
		var/mob/living/silicon/player = src
		designation = trim_left(player.designation + " " + player.job)

	if(isAI(src))
		// AIs are loud and ugly
		spans |= SPAN_COMMAND

	var/messagepart = generate_messagepart(
		message,
		spans,
		message_mods,
	)

	var/namepart = name
	// If carbon, use voice to account for voice changers
	if(iscarbon(src))
		namepart = GetVoice()

	for(var/mob/hearing_mob in GLOB.player_list)
		if(hearing_mob.binarycheck())
			if(isAI(hearing_mob))
				to_chat(
					hearing_mob,
					span_binarysay("\
						Robotic Talk, \
						<a href='byond://?src=[REF(hearing_mob)];track=[html_encode(namepart)]'>[span_name("[namepart] ([designation])")]</a> \
						<span class='message'>[messagepart]</span>\
					"),
					type = MESSAGE_TYPE_RADIO,
					avoid_highlighting = (src == hearing_mob)
				)
			else
				to_chat(
					hearing_mob,
					span_binarysay("\
						Robotic Talk, \
						[span_name("[namepart]")] <span class='message'>[messagepart]</span>\
					"),
					type = MESSAGE_TYPE_RADIO,
					avoid_highlighting = (src == hearing_mob)
				)

		if(isobserver(hearing_mob))
			var/following = src

			// If the AI talks on binary chat, we still want to follow
			// its camera eye, like if it talked on the radio

			if(isAI(src))
				var/mob/living/silicon/ai/ai = src
				following = ai.eyeobj

			var/follow_link = FOLLOW_LINK(hearing_mob, following)

			to_chat(
				hearing_mob,
				span_binarysay("\
					[follow_link] \
					Robotic Talk, \
					[span_name("[namepart]")] <span class='message'>[messagepart]</span>\
				"),
				type = MESSAGE_TYPE_RADIO,
				avoid_highlighting = (src == hearing_mob)
			)

/mob/living/silicon/binarycheck()
	return 1

/mob/living/silicon/radio(message, list/message_mods = list(), list/spans, language)
	. = ..()
	if(. != 0)
		return .

	if(message_mods[MODE_HEADSET])
		if(radio)
			radio.talk_into(src, message, , spans, language, message_mods)
		return REDUCE_RANGE

	else if(message_mods[RADIO_EXTENSION] in GLOB.radiochannels)
		if(radio)
			radio.talk_into(src, message, message_mods[RADIO_EXTENSION], spans, language, message_mods)
			return ITALICS | REDUCE_RANGE

	return 0
