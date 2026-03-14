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

/mob/living/say(
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
	if(sanitize)
		message = trim(copytext_char(sanitize(message), 1, MAX_MESSAGE_LEN))
	if(!message || message == "")
		return

	if(language) // if a language is specified already, the language is added into the list
		message_mods[LANGUAGE_EXTENSION] = istype(language) ? language.type : language
	var/original_message = message
	message = get_message_mods(message, message_mods)
	saymode = SSradio.get_available_say_mode(src, message_mods[RADIO_KEY])
	if(!forced && (isnull(saymode) || saymode.allows_custom_say_emotes))
		message = check_for_custom_say_emote(message, message_mods)

	if(!message)
		return

	// dead is the only state you can never emote
	if(stat != DEAD && check_emote(original_message, forced))
		return

	if (HAS_TRAIT(src, TRAIT_WHISPER_ONLY))
		message_mods[WHISPER_MODE] = MODE_WHISPER
		message_mods[MODE_HEADSET] = FALSE

	switch(stat)
		if(SOFT_CRIT)
			message_mods[WHISPER_MODE] = MODE_WHISPER
		if(UNCONSCIOUS)
			if(!(message_mods[MODE_ALIEN]))
				return
		if(HARD_CRIT)
			if(!(message_mods[WHISPER_MODE] || message_mods[MODE_ALIEN]))
				return
		if(DEAD)
			say_dead(original_message)
			return

	if(!try_speak(original_message, ignore_spam, forced, filterproof))
		return

	if(!language) // get_message_mods() proc finds a language key, and add the language to LANGUAGE_EXTENSION
		language = message_mods[LANGUAGE_EXTENSION] || get_selected_language()

	// if you add a new language that works like everyone doesn't understand (i.e. anti-metalanguage), add an additional condition after this
	// i.e.) if(!language) language = /datum/language/nobody_understands
	// This works as an additional failsafe for get_selected_language() has no language to return

	var/succumbed = FALSE

	// If it's not erasing the input portion, then something is being said and this isn't a pure custom say emote.
	if(!message_mods[MODE_CUSTOM_SAY_ERASE_INPUT])
		if(message_mods[WHISPER_MODE] == MODE_WHISPER)
			if(saymode || message_mods[RADIO_EXTENSION]) //no radio while in crit
				saymode = null
				message_mods -= RADIO_EXTENSION
			message_range = 1
			if(stat == HARD_CRIT)
				var/health_diff = round(-HEALTH_THRESHOLD_DEAD + health)
				// If we cut our message short, abruptly end it with a-..
				var/message_len = length_char(message)
				message = copytext_char(message, 1, health_diff) + "[message_len > health_diff ? "-.." : "..."]"
				message = Ellipsis(message, 10, 1)
				last_words = message
				message_mods[WHISPER_MODE] = MODE_WHISPER_CRIT
				succumbed = TRUE

	log_sayverb_talk(message, message_mods, forced_by = forced)

	if(message_mods[RADIO_KEY] == RADIO_KEY_UPLINK) // only uplink needs this
		message_mods[MODE_UNTREATED_MESSAGE] = message // let's store the original message before treating those

	var/list/message_data = treat_message(message) // unfortunately we still need this
	message = message_data["message"]

#ifdef UNIT_TESTS
	// Saves a ref() to our arglist specifically.
	// We do this because we need to check that COMSIG_MOB_SAY is getting EXACTLY this list.
	last_say_args_ref = REF(args)
#endif

	// Make sure the arglist is passed exactly - don't pass a copy of it. Say signal handlers will modify some of the parameters.
	var/sigreturn = SEND_SIGNAL(src, COMSIG_MOB_SAY, args)
	if(sigreturn & COMPONENT_UPPERCASE_SPEECH)
		message = uppertext(message)

	spans |= speech_span

	var/datum/language/spoken_lang = GLOB.language_datum_instances[language]
	if(LAZYLEN(spoken_lang?.spans))
		spans |= spoken_lang.spans

	if(message_mods[MODE_SING])
		var/randomnote = pick("\u2669", "\u266A", "\u266B")
		message = "[randomnote] [message] [randomnote]"
		spans |= SPAN_SINGING

	if(message_mods[WHISPER_MODE]) // whisper away
		spans |= SPAN_ITALICS

	if(!message)
		if(succumbed)
			succumb()
		return

	//Get which verb is prefixed to the message before radio but after most modifications
	message_mods[SAY_MOD_VERB] = say_mod(message, message_mods)

	//This is before anything that sends say a radio message, and after all important message type modifications, so you can scumb in alien chat or something
	if(saymode && (saymode.handle_message(src, message, spans, language, message_mods) & SAYMODE_MESSAGE_HANDLED))
		return

	var/radio_return = radio(message, message_mods, spans, language)//roughly 27% of living/say()'s total cost
	if(radio_return & NOPASS)
		return TRUE

	if(radio_return & ITALICS)
		spans |= SPAN_ITALICS
	if(radio_return & REDUCE_RANGE)
		message_range = 1
		message_mods[MODE_RADIO_MESSAGE] = MODE_RADIO_MESSAGE

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

	send_speech(message, message_range, src, bubble_type, spans, language, message_mods, forced = forced)//roughly 58% of living/say()'s total cost
	if(succumbed)
		succumb(TRUE)
		to_chat(src, compose_message(src, language, message, null, spans, message_mods))

	return TRUE

/mob/living/Hear(atom/movable/speaker, datum/language/message_language, raw_message, radio_freq, list/spans, list/message_mods = list(), message_range=0)
	if(!GET_CLIENT(src))
		return FALSE

	var/deaf_message
	var/deaf_type

	if(speaker != src)
		deaf_type = !radio_freq ? MSG_VISUAL : null
	else
		deaf_type = MSG_AUDIBLE

	var/atom/movable/virtualspeaker/holopad_speaker = speaker
	var/avoid_highlight = src == (istype(holopad_speaker) ? holopad_speaker.source : speaker)

	var/is_custom_emote = message_mods[MODE_CUSTOM_SAY_ERASE_INPUT]
	var/understood = TRUE
	if(!is_custom_emote) // we do not translate emotes
		var/untranslated_raw_message = raw_message
		raw_message = translate_language(speaker, message_language, raw_message, spans, message_mods) // translate
		if(raw_message != untranslated_raw_message)
			understood = FALSE

	var/message = ""
	// if someone is whispering we make an extra type of message that is obfuscated for people out of range
	// Less than or equal to 0 means normal hearing. More than 0 and less than or equal to EAVESDROP_EXTRA_RANGE means
	// partial hearing. More than EAVESDROP_EXTRA_RANGE means no hearing. Exception for GOOD_HEARING trait
	var/dist = get_dist(speaker, src) - message_range
	if(dist > 0 && dist <= EAVESDROP_EXTRA_RANGE && !HAS_TRAIT(src, TRAIT_GOOD_HEARING))
		raw_message = stars(raw_message)
	if(message_range != INFINITY && dist > EAVESDROP_EXTRA_RANGE && !HAS_TRAIT(src, TRAIT_GOOD_HEARING))
		// Too far away and don't have good hearing, you can't hear anything
		if(is_blind()) // Can't see them speak either
			return FALSE
		if(!isturf(speaker.loc)) // If they're inside of something, probably can't see them speak
			return FALSE

		if(can_hear()) // If we can't hear we want to continue to the default deaf message
			var/mob/living/living_speaker = speaker
			if(istype(living_speaker) && living_speaker.is_mouth_covered()) // Can't see them speak if their mouth is covered
				return FALSE
			deaf_message = span_subtle("[span_name("[speaker]")] [speaker.verb_whisper] something, but you are too far away to hear [speaker.p_them()].")

		if(deaf_message)
			deaf_type = MSG_VISUAL
			message = deaf_message
			show_message(message, MSG_VISUAL, deaf_message, deaf_type, avoid_highlight)
			return FALSE

	// we need to send this signal before compose_message() is used since other signals need to modify
	// the raw_message first. After the raw_message is passed through the various signals, it's ready to be formatted
	// by compose_message() to be displayed in chat boxes for to_chat or runechat
	SEND_SIGNAL(src, COMSIG_MOVABLE_HEAR, args)

	if(speaker != src)
		if(!radio_freq) //These checks have to be separate, else people talking on the radio will make "You can't hear yourself!" appear when hearing people over the radio while deaf.
			deaf_message = span_subtle("[span_name("[speaker]")] [speaker.get_default_say_verb()] something but you cannot hear [speaker.p_them()].")
			deaf_type = MSG_VISUAL
	else
		deaf_message = span_notice("You can't hear yourself!")
		deaf_type = MSG_AUDIBLE // Since you should be able to hear yourself without looking

	// Recompose message for AI hrefs, language incomprehension.
	message = compose_message(speaker, message_language, raw_message, radio_freq, spans, message_mods)
	var/show_message_success = show_message(message, MSG_AUDIBLE, deaf_message, deaf_type, avoid_highlight)
	return understood && show_message_success

/mob/living/send_speech(message_raw, message_range = 6, obj/source = src, bubble_type = bubble_icon, list/spans, datum/language/message_language = null, list/message_mods = list(), forced = null)
	var/whisper_range = 0
	var/is_speaker_whispering = FALSE
	if(message_mods[WHISPER_MODE]) //If we're whispering
		// Needed for good hearing trait. The actual filtering for whispers happens at the /mob/living/Hear proc
		whisper_range = MESSAGE_RANGE - WHISPER_RANGE
		is_speaker_whispering = TRUE

	var/list/in_view = get_hearers_in_view(message_range + whisper_range, source, SEE_INVISIBLE_MAXIMUM)
	var/list/listening = get_hearers_in_range(message_range + whisper_range, source)

	// Pre-process listeners to account for line-of-sight
	for(var/atom/movable/listening_movable as anything in listening)
		if(!(listening_movable in in_view) && !HAS_TRAIT(listening_movable, TRAIT_XRAY_HEARING))
			listening.Remove(listening_movable)

	if(client) //client is so that ghosts don't have to listen to mice
		for(var/mob/player_mob as anything in GLOB.player_list)
			if(QDELETED(player_mob)) //Some times nulls and deleteds stay in this list. This is a workaround to prevent ic chat breaking for everyone when they do.
				continue //Remove if underlying cause (likely byond issue) is fixed.
			if(player_mob.stat != DEAD) //not dead, not important
				continue
			if(player_mob.get_virtual_z_level() != get_virtual_z_level() || get_dist(player_mob, src) > 7 ) //they're out of range of normal hearing
				if(player_mob.client?.prefs && is_speaker_whispering && !player_mob.client.prefs.read_player_preference(/datum/preference/toggle/chat_ghostwhisper)) //they're whispering and we have hearing whispers at any range off
					listening -= player_mob // remove (added by SEE_INVISIBLE_MAXIMUM)
					continue
				if(player_mob.client?.prefs && !player_mob.client.prefs.read_player_preference(/datum/preference/toggle/chat_ghostears)) //they're talking normally and we have hearing at any range off
					listening -= player_mob // remove (added by SEE_INVISIBLE_MAXIMUM)
					continue
			listening |= player_mob

	// this signal ignores whispers or language translations (only used by beetlejuice component)
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_LIVING_SAY_SPECIAL, src, message_raw)

	var/list/show_overhead_message_to = list()
	var/list/show_overhead_message_to_eavesdrop = list()
	for(var/atom/movable/listening_movable as anything in listening)
		if(!listening_movable)
			stack_trace("somehow theres a null returned from get_hearers_in_view() in send_speech!")
			continue

		if(ismob(listening_movable))
			var/mob/M = listening_movable
			if(M.should_show_chat_message(src, message_language, FALSE, is_heard = TRUE))
				// separate hearers into close (clear) and far (distorted) for runechat
				if(is_speaker_whispering && !HAS_TRAIT(M, TRAIT_GOOD_HEARING))
					var/dist = get_dist(source, M) - message_range
					if(dist > 0 && dist <= EAVESDROP_EXTRA_RANGE)
						show_overhead_message_to_eavesdrop += M
					else if(dist <= 0)
						show_overhead_message_to += M
					// If dist > EAVESDROP_EXTRA_RANGE, too far for runechat
				else
					show_overhead_message_to += M
		listening_movable.Hear(speaker = src, message_language = message_language, raw_message = message_raw, radio_freq = null, spans = spans, message_mods = message_mods, message_range = message_range)
	if(length(show_overhead_message_to))
		create_chat_message(src, message_language, hearers = show_overhead_message_to, raw_message = message_raw, spans = spans)
	if(length(show_overhead_message_to_eavesdrop))
		create_chat_message(src, message_language, hearers = show_overhead_message_to_eavesdrop, raw_message = stars(message_raw), spans = spans)

	//speech bubble
	var/list/speech_bubble_recipients = list()
	var/talk_icon_state = say_test(message_raw)
	for(var/mob/M in listening)
		if(M.client?.prefs && !M.client.prefs.read_player_preference(/datum/preference/toggle/enable_runechat))
			speech_bubble_recipients.Add(M.client)

	var/image/say_popup = image('icons/mob/talk.dmi', src, "[bubble_type][talk_icon_state]", (-TYPING_LAYER))
	say_popup.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
	INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(animate_speechbubble), say_popup, speech_bubble_recipients, 30)

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

/**
 * Treats the passed message with things that may modify speech (stuttering, slurring etc).
 *
 * message - The message to treat.
 * capitalize_message - Whether we run capitalize() on the message after we're done.
 *
 * Returns a list, which is a packet of information corresponding to the message that has been treated, which
 * contains the new message.
 */
/mob/living/proc/treat_message(message, capitalize_message = TRUE)
	RETURN_TYPE(/list)

	if(HAS_TRAIT(src, TRAIT_UNINTELLIGIBLE_SPEECH))
		message = unintelligize(message)

	var/list/data = list(message)
	SEND_SIGNAL(src, COMSIG_LIVING_TREAT_MESSAGE, args)
	message = data[TREAT_MESSAGE_ARG]

	return treat_message_min(message, capitalize_message)

/mob/proc/treat_message_min(message, capitalize_message = TRUE)
	message = punctuate(message)
	if(capitalize_message)
		message = capitalize(message)
	return list("message" = message)

/mob/living/proc/radio(message, list/message_mods = list(), list/spans, language)
	var/obj/item/implant/radio/imp = locate() in src
	if(imp?.radio.is_on())
		if(message_mods[MODE_HEADSET])
			imp.radio.talk_into(src, message, , spans, language, message_mods)
			return ITALICS | REDUCE_RANGE
		if(message_mods[RADIO_EXTENSION] == MODE_DEPARTMENT || (message_mods[RADIO_EXTENSION] in imp.radio.channels))
			imp.radio.talk_into(src, message, message_mods[RADIO_EXTENSION], spans, language, message_mods)
			return ITALICS | REDUCE_RANGE

	switch(message_mods[RADIO_EXTENSION])
		if(MODE_R_HAND)
			for(var/obj/item/r_hand in get_held_items_for_side(RIGHT_HANDS, all = TRUE))
				if (r_hand)
					return r_hand.talk_into(src, message, , spans, language, message_mods)
				return ITALICS | REDUCE_RANGE

		if(MODE_L_HAND)
			for(var/obj/item/l_hand in get_held_items_for_side(LEFT_HANDS, all = TRUE))
				if (l_hand)
					return l_hand.talk_into(src, message, , spans, language, message_mods)
				return ITALICS | REDUCE_RANGE

		if(MODE_INTERCOM)
			for (var/obj/item/radio/intercom/I in view(MODE_RANGE_INTERCOM, src))
				I.talk_into(src, message, , spans, language, message_mods)
			return ITALICS | REDUCE_RANGE

	return NONE

/mob/living/say_mod(input, list/message_mods = list())
	if(message_mods[WHISPER_MODE] == MODE_WHISPER)
		. = verb_whisper
	else if(message_mods[WHISPER_MODE] == MODE_WHISPER_CRIT)
		. = "[verb_whisper] in [p_their()] last breath"
	else if(message_mods[MODE_SING])
		. = verb_sing
	else if(message_mods[WHISPER_MODE])
		. = verb_whisper
	// Any subtype of slurring in our status effects make us "slur"
	else if(locate(/datum/status_effect/speech/slurring) in status_effects)
		. = "slurs"
	else if(has_status_effect(/datum/status_effect/speech/stutter))
		. = "stammers"
	else if(has_status_effect(/datum/status_effect/speech/stutter/derpspeech))
		. = "gibbers"
	else
		. = ..()

/**
 * Living level whisper.
 *
 * Living mobs which whisper have their message only appear to people very close.
 *
 * message - the message to display
 * bubble_type - the type of speech bubble that shows up when they speak (currently does nothing)
 * spans - a list of spans to apply around the message
 * sanitize - whether we sanitize the message
 * language - typepath language to force them to speak / whisper in
 * ignore_spam - whether we ignore the spam filter
 * forced - string source of what forced this speech to happen, also bypasses spam filter / mutes if supplied
 * filterproof - whether we ignore the word filter
 */
/mob/living/whisper(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language, ignore_spam = FALSE, forced, filterproof)
	if(!message)
		return
	say("#[message]", bubble_type, spans, sanitize, language, ignore_spam, forced, filterproof)
