GLOBAL_LIST_INIT(department_radio_prefixes, list(":", "."))

GLOBAL_LIST_INIT(department_radio_keys, list(
	// Location
	MODE_KEY_R_HAND = MODE_R_HAND,
	MODE_KEY_L_HAND = MODE_L_HAND,
	MODE_KEY_INTERCOM = MODE_INTERCOM,

	// Department
	MODE_KEY_DEPARTMENT = MODE_DEPARTMENT,
	RADIO_KEY_COMMAND = RADIO_CHANNEL_COMMAND,
	RADIO_KEY_SCIENCE = RADIO_CHANNEL_SCIENCE,
	RADIO_KEY_MEDICAL = RADIO_CHANNEL_MEDICAL,
	RADIO_KEY_ENGINEERING = RADIO_CHANNEL_ENGINEERING,
	RADIO_KEY_SECURITY = RADIO_CHANNEL_SECURITY,
	RADIO_KEY_SUPPLY = RADIO_CHANNEL_SUPPLY,
	RADIO_KEY_EXPLORATION = RADIO_CHANNEL_EXPLORATION,
	RADIO_KEY_SERVICE = RADIO_CHANNEL_SERVICE,

	// Faction
	RADIO_KEY_SYNDICATE = RADIO_CHANNEL_SYNDICATE,
	RADIO_KEY_UPLINK = RADIO_CHANNEL_UPLINK,
	RADIO_KEY_CENTCOM = RADIO_CHANNEL_CENTCOM,

	// Misc
	RADIO_KEY_AI_PRIVATE = RADIO_CHANNEL_AI_PRIVATE, // AI Upload channel


	//kinda localization -- rastaf0
	//same keys as above, but on russian keyboard layout.
	// Location
	"к" = MODE_R_HAND,
	"л" = MODE_L_HAND,
	"ш" = MODE_INTERCOM,

	// Department
	"р" = MODE_DEPARTMENT,
	"с" = RADIO_CHANNEL_COMMAND,
	"т" = RADIO_CHANNEL_SCIENCE,
	"ь" = RADIO_CHANNEL_MEDICAL,
	"у" = RADIO_CHANNEL_ENGINEERING,
	"ы" = RADIO_CHANNEL_SECURITY,
	"г" = RADIO_CHANNEL_SUPPLY,
	"м" = RADIO_CHANNEL_SERVICE,
	"ю" = RADIO_CHANNEL_EXPLORATION,

	// Faction
	"е" = RADIO_CHANNEL_SYNDICATE,
	"н" = RADIO_CHANNEL_CENTCOM,

	// Misc
	"щ" = RADIO_CHANNEL_AI_PRIVATE
))

/mob/living/proc/Ellipsis(original_msg, chance = 50, keep_words)
	if(chance <= 0)
		return "..."
	if(chance >= 100)
		return original_msg

	var/list/words = splittext(original_msg," ")
	var/list/new_words = list()

	var/new_msg = ""

	for(var/w in words)
		if(prob(chance))
			new_words += "..."
			if(!keep_words)
				continue
		new_words += w

	new_msg = jointext(new_words," ")

	return new_msg

/mob/living/say(message, bubble_type, var/list/spans = list(), sanitize = TRUE, datum/language/language, ignore_spam = FALSE, forced)
	var/static/list/crit_allowed_modes = list(WHISPER_MODE = TRUE, MODE_ALIEN = TRUE)
	var/static/list/unconscious_allowed_modes = list(MODE_ALIEN = TRUE)

	var/ic_blocked = FALSE
	if(client && !forced && CHAT_FILTER_CHECK(message))
		//The filter doesn't act on the sanitized message, but the raw message.
		ic_blocked = TRUE

	if(sanitize)
		message = trim(copytext_char(sanitize(message), 1, MAX_MESSAGE_LEN))
	if(!message || message == "")
		return

	if(ic_blocked)
		//The filter warning message shows the sanitized message though.
		to_chat(src, "<span class='warning'>That message contained a word prohibited in IC chat! Consider reviewing the server rules.\n<span replaceRegex='show_filtered_ic_chat'>\"[message]\"</span></span>")
		return

	var/list/message_mods = list()
	var/original_message = message
	message = get_message_mods(message, message_mods)
	var/datum/saymode/saymode = SSradio.saymodes[message_mods[RADIO_KEY]]
	var/in_critical = InCritical()

	if(!message)
		return

	message = check_for_custom_say_emote(message, message_mods)

	if(stat == DEAD)
		say_dead(original_message)
		return

	if(is_muted(original_message, ignore_spam, forced) || check_emote(original_message, forced))
		return

	if(in_critical) //There are cheaper ways to do this, but they're less flexible, and this isn't ran all that often
		var/end = TRUE
		for(var/index in message_mods)
			if(crit_allowed_modes[index])
				end = FALSE
				break
		if(end)
			return
	else if(stat == UNCONSCIOUS)
		var/end = TRUE
		for(var/index in message_mods)
			if(unconscious_allowed_modes[index])
				end = FALSE
				break
		if(end)
			return

	language = message_mods[LANGUAGE_EXTENSION]

	if(!language)
		language = get_selected_language()

	if(!can_speak_vocal(message))
		to_chat(src, "<span class='warning'>You find yourself unable to speak!</span>")
		return

	var/message_range = 7

	var/succumbed = FALSE

	if(message_mods[MODE_CUSTOM_SAY_EMOTE])
		log_message(message_mods[MODE_CUSTOM_SAY_EMOTE], LOG_RADIO_EMOTE)

	if(!message_mods[MODE_CUSTOM_SAY_ERASE_INPUT])
		var/fullcrit = InFullCritical()
		if((in_critical && !fullcrit) || message_mods[WHISPER_MODE] == MODE_WHISPER)
			if(saymode || message_mods[RADIO_EXTENSION]) //no radio while in crit
				saymode = null
				message_mods -= RADIO_EXTENSION
			message_range = 1
			message_mods[WHISPER_MODE] = MODE_WHISPER
			log_talk(message, LOG_WHISPER, custom_say_emote = message_mods[MODE_CUSTOM_SAY_EMOTE])
			if(fullcrit)
				var/health_diff = round(-HEALTH_THRESHOLD_DEAD + health)
				// If we cut our message short, abruptly end it with a-..
				var/message_len = length_char(message)
				message = copytext_char(message, 1, health_diff) + "[message_len > health_diff ? "-.." : "..."]"
				message = Ellipsis(message, 10, 1)
				last_words = message
				message_mods[WHISPER_MODE] = MODE_WHISPER_CRIT
				succumbed = TRUE
		else
			log_talk(message, LOG_SAY, forced_by = forced, custom_say_emote = message_mods[MODE_CUSTOM_SAY_EMOTE])

	message = treat_message(message) // unfortunately we still need this
	var/sigreturn = SEND_SIGNAL(src, COMSIG_MOB_SAY, args)
	if(sigreturn & COMPONENT_UPPERCASE_SPEECH)
		message = uppertext(message)
	if(!message)
		return

	spans |= speech_span

	if(language)
		var/datum/language/L = GLOB.language_datum_instances[language]
		spans |= L.spans

	if(message_mods[MODE_SING])
		var/randomnote = pick("\u2669", "\u266A", "\u266B")
		message = "[randomnote] [message] [randomnote]"
		spans |= SPAN_SINGING

	//This is before anything that sends say a radio message, and after all important message type modifications, so you can scumb in alien chat or something
	if(saymode && !saymode.handle_message(src, message, language))
		return
	var/radio_message = message
	if(message_mods[WHISPER_MODE])
		// radios don't pick up whispers very well
		radio_message = stars(radio_message)
		spans |= SPAN_ITALICS
	var/radio_return = radio(radio_message, message_mods, spans, language)
	if(radio_return & ITALICS)
		spans |= SPAN_ITALICS
	if(radio_return & REDUCE_RANGE)
		message_range = 1
		message_mods[MODE_RADIO_MESSAGE] = MODE_RADIO_MESSAGE
	if(radio_return & NOPASS)
		return TRUE

	//now that the radio message is sent, if the custom say message was just an emote we return
	if (message_mods[MODE_CUSTOM_SAY_ERASE_INPUT] && message_mods[MODE_CUSTOM_SAY_EMOTE])
		emote("me", 1, message_mods[MODE_CUSTOM_SAY_EMOTE], TRUE)
		return

	//No screams in space, unless you're next to someone.
	var/turf/T = get_turf(src)
	var/datum/gas_mixture/environment = T.return_air()
	var/pressure = environment ? environment.return_pressure() : 0
	if(pressure < SOUND_MINIMUM_PRESSURE)
		message_range = 1

	if(pressure < ONE_ATMOSPHERE*0.4) //Thin air, let's italicise the message
		spans |= SPAN_ITALICS

	send_speech(message, message_range, src, bubble_type, spans, language, message_mods)

	if(succumbed)
		succumb(TRUE)
		to_chat(src, compose_message(src, language, message, , spans, message_mods))

	return TRUE

/mob/living/Hear(message, atom/movable/speaker, datum/language/message_language, raw_message, radio_freq, list/spans, list/message_mods = list())
	SEND_SIGNAL(src, COMSIG_MOVABLE_HEAR, args)
	if(!client)
		return
	var/deaf_message
	var/deaf_type
	var/avoid_highlight
	if(istype(speaker, /atom/movable/virtualspeaker))
		var/atom/movable/virtualspeaker/virt = speaker
		avoid_highlight = src == virt.source
	else
		avoid_highlight = src == speaker

	if(speaker != src)
		if(!radio_freq) //These checks have to be separate, else people talking on the radio will make "You can't hear yourself!" appear when hearing people over the radio while deaf.
			deaf_message = "<span class='name'>[speaker]</span> [speaker.verb_say] something but you cannot hear [speaker.p_them()]."
			deaf_type = 1
	else
		deaf_message = "<span class='notice'>You can't hear yourself!</span>"
		deaf_type = 2 // Since you should be able to hear yourself without looking

	// Recompose message for AI hrefs, language incomprehension.
	message = compose_message(speaker, message_language, raw_message, radio_freq, spans, message_mods)

	show_message(message, MSG_AUDIBLE, deaf_message, deaf_type, avoid_highlight)
	return message

/mob/living/send_speech(message, message_range = 6, obj/source = src, bubble_type = bubble_icon, list/spans, datum/language/message_language=null, list/message_mods = list())
	var/static/list/eavesdropping_modes = list(MODE_WHISPER = TRUE, MODE_WHISPER_CRIT = TRUE)
	var/eavesdrop_range = 0
	if(message_mods[WHISPER_MODE]) //If we're whispering
		eavesdrop_range = EAVESDROP_EXTRA_RANGE
	var/list/listening = get_hearers_in_view(message_range+eavesdrop_range, source, SEE_INVISIBLE_MAXIMUM)
	var/list/the_dead = list()
	for(var/mob/M as() in GLOB.player_list)
		if(!M)				//yogs
			continue		//yogs | null in player_list for whatever reason :shrug:
		if(M.stat != DEAD) //not dead, not important
			continue
		if(!M.client || !client) //client is so that ghosts don't have to listen to mice
			listening -= M // remove (added by SEE_INVISIBLE_MAXIMUM)
			continue
		if(get_dist(M, src) > 7 || M.get_virtual_z_level() != get_virtual_z_level()) //they're out of range of normal hearing
			if(eavesdrop_range && !(M.client.prefs.chat_toggles & CHAT_GHOSTWHISPER)) //they're whispering and we have hearing whispers at any range off
				listening -= M // remove (added by SEE_INVISIBLE_MAXIMUM)
				continue
			if(!(M.client.prefs.chat_toggles & CHAT_GHOSTEARS)) //they're talking normally and we have hearing at any range off
				listening -= M // remove (added by SEE_INVISIBLE_MAXIMUM)
				continue
		listening |= M
		the_dead[M] = TRUE

	var/eavesdropping
	var/eavesrendered
	if(eavesdrop_range)
		eavesdropping = stars(message)
		eavesrendered = compose_message(src, message_language, eavesdropping, , spans, message_mods)

	var/list/show_overhead_message_to = list()
	var/list/show_overhead_message_to_eavesdrop = list()
	var/rendered = compose_message(src, message_language, message, , spans, message_mods)
	for(var/atom/movable/AM as() in listening)
		if(eavesdrop_range && get_dist(source, AM) > message_range && !(the_dead[AM]))
			if(ismob(AM))
				var/mob/M = AM
				if(M.should_show_chat_message(src, message_language, FALSE, is_heard = TRUE))
					show_overhead_message_to_eavesdrop += M
			AM.Hear(eavesrendered, src, message_language, eavesdropping, , spans, message_mods)
		else
			if(ismob(AM))
				var/mob/M = AM
				if(M.should_show_chat_message(src, message_language, FALSE, is_heard = TRUE))
					show_overhead_message_to += M
			AM.Hear(rendered, src, message_language, message, , spans, message_mods)
	if(length(show_overhead_message_to))
		create_chat_message(src, message_language, show_overhead_message_to, message, spans)
	if(length(show_overhead_message_to_eavesdrop))
		create_chat_message(src, message_language, show_overhead_message_to_eavesdrop, eavesdropping, spans)
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_LIVING_SAY_SPECIAL, src, message)

	//speech bubble
	var/list/speech_bubble_recipients = list()
	for(var/mob/M in listening)
		if(M.client && !(M.client.prefs.toggles & PREFTOGGLE_RUNECHAT_GLOBAL))
			speech_bubble_recipients.Add(M.client)
	var/image/I = image('icons/mob/talk.dmi', src, "[bubble_type][say_test(message)]", FLY_LAYER)
	I.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
	INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(animate_speechbubble), I, speech_bubble_recipients, 30)

/proc/animate_speechbubble(image/I, list/show_to, duration)
	var/matrix/M = matrix()
	M.Scale(0,0)
	I.transform = M
	I.alpha = 0
	for(var/client/C in show_to)
		C.images += I
	animate(I, transform = 0, alpha = 255, time = 5, easing = ELASTIC_EASING)
	spawn(duration-5)
		animate(I, alpha = 0, time = 5, easing = EASE_IN)
		spawn(5)
			for(var/client/C in show_to)
				C.images -= I

/mob/proc/binarycheck()
	return FALSE

/mob/living/can_speak(message) //For use outside of Say()
	if(!is_muted(message) && can_speak_vocal(message))
		return TRUE

/mob/living/proc/is_muted(message, ignore_spam = FALSE, forced = FALSE) //Check BEFORE handling of xeno and ling channels
	if(client)
		if(client.prefs.muted & MUTE_IC)
			to_chat(src, "<span class='danger'>You cannot speak in IC (muted).</span>")
			return TRUE
		if(!ignore_spam && !forced && client.handle_spam_prevention(message, MUTE_IC))
			return TRUE

	return FALSE

/mob/living/proc/can_speak_vocal(message) //Check AFTER handling of xeno and ling channels
	if(HAS_TRAIT(src, TRAIT_MUTE))
		return FALSE

	if(is_muzzled())
		return FALSE

	if(!IsVocal())
		return FALSE

	return TRUE

/mob/living/proc/treat_message(message)

	if(HAS_TRAIT(src, TRAIT_UNINTELLIGIBLE_SPEECH))
		message = unintelligize(message)

	if(derpspeech)
		message = derpspeech(message, stuttering)

	if(stuttering)
		message = stutter(message)

	if(slurring)
		message = slur(message)

	if(cultslurring)
		message = cultslur(message)

	if(clockslurring)
		message = clockslur(message)

	return treat_message_min(message)

/mob/proc/treat_message_min(message)
	message = punctuate(message)
	message = capitalize(message)
	return message

/mob/living/proc/radio(message, list/message_mods = list(), list/spans, language)
	var/obj/item/implant/radio/imp = locate() in src
	if(imp && imp.radio.on)
		if(message_mods[MODE_HEADSET])
			imp.radio.talk_into(src, message, , spans, language, message_mods)
			return ITALICS | REDUCE_RANGE
		if(message_mods[RADIO_EXTENSION] == MODE_DEPARTMENT || (message_mods[RADIO_EXTENSION] in imp.radio.channels))
			imp.radio.talk_into(src, message, message_mods[RADIO_EXTENSION], spans, language, message_mods)
			return ITALICS | REDUCE_RANGE

	switch(message_mods[RADIO_EXTENSION])
		if(MODE_R_HAND)
			for(var/obj/item/r_hand in get_held_items_for_side("r", all = TRUE))
				if (r_hand)
					return r_hand.talk_into(src, message, , spans, language, message_mods)
				return ITALICS | REDUCE_RANGE
		if(MODE_L_HAND)
			for(var/obj/item/l_hand in get_held_items_for_side("l", all = TRUE))
				if (l_hand)
					return l_hand.talk_into(src, message, , spans, language, message_mods)
				return ITALICS | REDUCE_RANGE

		if(MODE_INTERCOM)
			for (var/obj/item/radio/intercom/I in view(MODE_RANGE_INTERCOM, src))
				I.talk_into(src, message, , spans, language, message_mods)
			return ITALICS | REDUCE_RANGE

	return 0

/mob/living/say_mod(input, list/message_mods = list())
	if(message_mods[WHISPER_MODE] == MODE_WHISPER)
		. = verb_whisper
	else if(message_mods[WHISPER_MODE] == MODE_WHISPER_CRIT)
		. = "[verb_whisper] in [p_their()] last breath"
	else if(message_mods[MODE_SING])
		. = verb_sing
	else if(stuttering)
		. = "stammers"
	else if(derpspeech)
		. = "gibbers"
	else
		. = ..()

/mob/living/whisper(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	say("#[message]", bubble_type, spans, sanitize, language, ignore_spam, forced)

/mob/living/get_language_holder(shadow=TRUE)
	if(mind && shadow)
		// Mind language holders shadow mob holders.
		. = mind.get_language_holder()
		if(.)
			return .

	. = ..()
