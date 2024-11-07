/mob/living/proc/robot_talk(message)
	//Cannot transmit wireless messages while jammed
	if(is_jammed(JAMMER_PROTECTION_SILICON_COMMS))
		return
	if(CHAT_FILTER_CHECK(message))
		to_chat(usr, "<span class='warning'>Your message contains forbidden words.</span>")
		return
	log_talk(message, LOG_SAY, tag="binary")
	var/desig = "Default Cyborg" //ezmode for taters
	if(issilicon(src))
		var/mob/living/silicon/S = src
		desig = trim_left(S.designation + " " + S.job)
	var/large_message_a = say_quote(message, list("robot big"))
	var/message_a = say_quote(message, list("robot"))
	var/mob/living/silicon/ai/true_ai_core
	if(iscyborg(src))  // this detects if a borg is AI shell, so that they can be loud always
		var/mob/living/silicon/robot/ai_shell = src
		true_ai_core = ai_shell.mainframe
	for(var/mob/M in GLOB.player_list)
		if(M.binarycheck())
			if(isAI(M))
				var/loud = FALSE
				if(M == src) //AI hears only itself on loud mode.
					loud = TRUE
				var/rendered = "<span class='srt_radio binarysay'>Robotic Talk, <a href='?src=[REF(M)];track=[html_encode(name)]'><span class='name'>[name] ([desig])</span></a> [loud ? "[large_message_a]" : "[message_a]"]</span>"
				to_chat(M, rendered)
			else if(iscyborg(M))
				var/mob/living/silicon/robot/borg = M
				var/loud = FALSE
				if((src == borg.connected_ai) || (true_ai_core == borg.connected_ai)) //Cyborg only hears master AI on loud mode.
					loud = TRUE
				var/rendered = "<span class='srt_radio binarysay'>Robotic Talk, <span class='name'>[name]</span> [loud ? "[large_message_a]" : "[message_a]"]</span>"
				to_chat(M, rendered)
			else
				var/rendered = "<span class='srt_radio binarysay'>Robotic Talk, <span class='name'>[name]</span> [message_a]</span>"
				to_chat(M, rendered)
		if(isobserver(M))
			var/following = src
			var/loud = isAI(src) || true_ai_core
			// If the AI talks on binary chat, we still want to follow
			// it's camera eye, like if it talked on the radio
			if(isAI(src))
				var/mob/living/silicon/ai/ai = src
				following = ai.eyeobj
			var/link = FOLLOW_LINK(M, following)
			var/rendered = "<span class='srt_radio binarysay'>[link] Robotic Talk, <span class='name'>[name]</span> [loud ? "[large_message_a]" : "[message_a]"]</span>" //Observers hear all AI on loud mode.
			to_chat(M, rendered)

/mob/living/silicon/binarycheck()
	return 1

/mob/living/silicon/lingcheck()
	return 0 //Borged or AI'd lings can't speak on the ling channel.

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
