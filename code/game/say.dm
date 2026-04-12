/*
	Miauw's big Say() rewrite.
	This file has the basic atom/movable level speech procs.
	And the base of the send_speech() proc, which is the core of saycode.
*/
GLOBAL_LIST_INIT(freqtospan, list(
	"[FREQ_SCIENCE]" = "sciradio",
	"[FREQ_MEDICAL]" = "medradio",
	"[FREQ_ENGINEERING]" = "engradio",
	"[FREQ_SUPPLY]" = "suppradio",
	"[FREQ_EXPLORATION]" = "explradio",
	"[FREQ_SERVICE]" = "servradio",
	"[FREQ_SECURITY]" = "secradio",
	"[FREQ_COMMAND]" = "comradio",
	"[FREQ_AI_PRIVATE]" = "aiprivradio",
	"[FREQ_SYNDICATE]" = "syndradio",
	"[FREQ_UPLINK]" = "syndradio", //snowflake uplink radio freq
	"[FREQ_CENTCOM]" = "centcomradio",
	"[FREQ_CTF_RED]" = "redteamradio",
	"[FREQ_CTF_BLUE]" = "blueteamradio"
	))

/**
 * What makes things... talk.
 *
 * * message - The message to say.
 * * bubble_type - The type of speech bubble to use when talking
 * * spans - A list of spans to attach to the message. Includes the atom's speech span by default
 * * sanitize - Should we sanitize the message? Only set to FALSE if you have ALREADY sanitized it
 * * language - The language to speak in. Defaults to the atom's selected language
 * * ignore_spam - Should we ignore spam checks?
 * * forced - What was it forced by? null if voluntary. (NOT a boolean!)
 * * filterproof - Do we bypass the filter when checking the message?
 * * message_range - The range of the message. Defaults to 7
 * * saymode - Saymode passed to the speech
 * This is usually set automatically and is only relevant for living mobs.
 * * message_mods - A list of message modifiers, i.e. whispering/singing.
 * Most of these are set automatically but you can pass in your own pre-say.
 */
/atom/movable/proc/say(
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
	atom/source = src,
)
	if(!try_speak(message, ignore_spam, forced, filterproof))
		return
	if(sanitize)
		message = trim(copytext_char(sanitize(message), 1, MAX_MESSAGE_LEN))
	if(!message || message == "")
		return
	spans |= speech_span
	if(!language)
		language = get_selected_language()
	if(!message_mods[SAY_MOD_VERB])
		message_mods[SAY_MOD_VERB] = say_mod(message, message_mods)
	send_speech(message_raw = message,  message_range = message_range,  source = source, bubble_type = bubble_type, spans = spans, message_language = language, message_mods = message_mods, forced = forced)

/atom/movable/proc/Hear(atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, list/message_mods = list(), message_range=0)
	SEND_SIGNAL(src, COMSIG_MOVABLE_HEAR, args)
	return TRUE

/**
 * Checks if our movable can speak the provided message, passing it through filters
 * and spam detection. Does not call can_speak. CAN include feedback messages about
 * why someone can or can't speak
 *
 * Used in [proc/say] and other methods of speech (radios) after a movable has inputted some message.
 * If you just want to check if the movable is able to speak in character, use [proc/can_speak] instead.
 *
 * Parameters:
 * - message (string): the original message
 * - ignore_spam (bool): should we ignore spam?
 * - forced (null|string): what was it forced by? null if voluntary
 * - filterproof (bool): are we filterproof?
 *
 * Returns:
 * 	TRUE or FALSE depending on if our movable can speak
 */
/atom/movable/proc/try_speak(message, ignore_spam = FALSE, forced = null, filterproof = FALSE)
	return can_speak()

/**
 * Checks if our movable can currently speak, vocally, in general.
 * Should NOT include feedback messages about why someone can or can't speak
 * Used in various places to check if a movable is simply able to speak in general,
 * regardless of OOC status (being muted) and regardless of what they're actually saying.
 *
 * Checked AFTER handling of xeno channels.
 * (I'm not sure what this comment means, but it was here in the past, so I'll maintain it here.)
 *
 * allow_mimes - Determines if this check should skip over mimes. (Only matters for living mobs and up.)
 * If FALSE, this check will always fail if the movable has a mind and is miming.
 * if TRUE, we will check if the movable can speak REGARDLESS of if they have an active mime vow.
 */
/atom/movable/proc/can_speak(allow_mimes = FALSE)
	SHOULD_BE_PURE(TRUE)
	return !HAS_TRAIT(src, TRAIT_MUTE)

/atom/movable/proc/send_speech(message_raw, message_range = 7, obj/source = src, bubble_type, list/spans, datum/language/message_language, list/message_mods = list(), forced = FALSE)
	var/list/show_overhead_message_to = list()
	var/list/listeners = get_hearers_in_view(message_range, source, SEE_INVISIBLE_MAXIMUM)
	for(var/atom/movable/hearing_movable as anything in listeners)
		if(!hearing_movable)//theoretically this should use as anything because it shouldnt be able to get nulls but there are reports that it does.
			stack_trace("somehow theres a null returned from get_hearers_in_view() in send_speech!")
			continue
		if(ismob(hearing_movable))
			var/mob/M = hearing_movable
			if(M.should_show_chat_message(source, message_language, FALSE, is_heard = TRUE))
				show_overhead_message_to += M
		hearing_movable.Hear(src, message_language, message_raw, null, spans, message_mods, message_range)
	if(length(show_overhead_message_to))
		create_chat_message(src, message_language, show_overhead_message_to, message_raw, spans, message_mods)

/// this creates runechat, so that they can communicate better
/atom/movable/proc/create_private_chat_message(message, datum/language/message_language=/datum/language/metalanguage, list/hearers, includes_ghosts=TRUE)
	if(!hearers || !islist(hearers))
		return
	if(includes_ghosts)
		hearers += GLOB.dead_mob_list.Copy()
	var/list/runechat_readers = list()
	for(var/mob/each_mob in hearers)
		if(!each_mob.should_show_chat_message(src, message_language))
			continue
		runechat_readers += each_mob
	create_chat_message(src,
		message_language = message_language,
		hearers = runechat_readers, // only you and your target sees the runechat (+ghosts)
		raw_message = message)
	// Note for troubleshooting: if a spell doesn't show runechat, it's because the spell is object, and src is spell. you should call this proc from the mob.

/atom/movable/proc/compose_message(atom/movable/speaker, datum/language/message_language, raw_message, radio_freq, list/spans, list/message_mods = list(), face_name = FALSE)
	//Basic span
	var/spanpart1 = "<span class='[radio_freq ? "srt_radio [get_radio_span(radio_freq)]" : "game say"]'>"
	//Start name span.
	var/spanpart2 = "<span class='name'>"
	//Radio freq/name display
	var/freqpart = radio_freq ? "\[[get_radio_name(radio_freq)]\] " : ""
	//Speaker name
	var/namepart = "[speaker.GetVoice()][speaker.get_alt_name()]"

	if(ishuman(speaker))
		var/mob/living/carbon/human/H = speaker
		if(face_name)
			namepart = "[H.get_face_name()]" //So "fake" speaking like in hallucinations does not give the speaker away if disguised
		if(!radio_freq)
			if(H.wear_id?.GetID())
				var/obj/item/card/id/idcard = H.wear_id.GetID()
				if(idcard.hud_state == JOB_HUD_UNKNOWN)
					spanpart2 = "<span class='name unassigned'>"
				else
					spanpart2 = "<span class='name [idcard.hud_state]'>"
			else
				spanpart2 = "<span class='name unknown'>"
	else if(isliving(speaker) && !radio_freq)
		var/mob/living/L = speaker
		spanpart2 = "<span class='name [L.mobchatspan]'>"

	//End name span.
	var/endspanpart = "</span>"

	// Language icon.
	var/languageicon = ""
	var/space = " "
	if(message_mods[MODE_CUSTOM_SAY_EMOTE])
		if(!should_have_space_before_emote(html_decode(message_mods[MODE_CUSTOM_SAY_EMOTE])[1]))
			space = null
	if(!message_mods[MODE_CUSTOM_SAY_ERASE_INPUT])
		var/datum/language/dialect = GLOB.language_datum_instances[message_language]
		if(istype(dialect) && dialect.display_icon(src))
			languageicon = "[dialect.get_icon()] "

	// The actual message part.
	var/messagepart = speaker.generate_messagepart(raw_message, spans, message_mods)
	messagepart = "[space][span_message("[apply_message_emphasis(messagepart)]")]</span>"

	return "[spanpart1][spanpart2][freqpart][languageicon][compose_track_href(speaker, namepart)][namepart][compose_job(speaker, message_language, raw_message, radio_freq)][endspanpart][messagepart]"

/atom/movable/proc/compose_track_href(atom/movable/speaker, message_language, raw_message, radio_freq)
	return ""

/atom/movable/proc/compose_job(atom/movable/speaker, message_language, raw_message, radio_freq)
	return ""

/**
 * Works out and returns which prefix verb the passed message should use.
 *
 * input - The message for which we want the verb.
 * message_mods - A list of message modifiers, i.e. whispering/singing.
 */
/atom/movable/proc/say_mod(input, list/message_mods = list())
	var/ending = copytext_char(input, -1)
	if(copytext_char(input, -2) == "!!")
		return get_default_yell_verb()
	else if(ending == "?")
		return get_default_ask_verb()
	else if(ending == "!")
		return get_default_exclaim_verb()
	else
		return get_default_say_verb()

/**
 * Gets the say verb we default to if no special verb is chosen.
 * This is primarily a hook for inheritors,
 * like human_say.dm's tongue-based verb_say changes.
 */
/atom/movable/proc/get_default_say_verb()
	return verb_say

/atom/movable/proc/get_default_ask_verb()
	return verb_ask

/atom/movable/proc/get_default_yell_verb()
	return verb_yell

/atom/movable/proc/get_default_exclaim_verb()
	return verb_exclaim


/**
 * This proc is used to generate the 'message' part of a chat message.
 * Generates the `says, "<span class='red'>meme</span>"` part of the `Grey Tider says, "meme"`,
 * or the `taps their microphone.` part of `Grey Tider taps their microphone.`.
 *
 * input - The message to be said
 * spans - A list of spans to attach to the message. Includes the atom's speech span by default
 * message_mods - A list of message modifiers, i.e. whispering/singing
 */
/atom/movable/proc/generate_messagepart(input, list/spans = list(speech_span), list/message_mods = list())
	// If we only care about the emote part, early return.
	if(message_mods[MODE_CUSTOM_SAY_ERASE_INPUT])
		return apply_message_emphasis(message_mods[MODE_CUSTOM_SAY_EMOTE])

	// Otherwise, we format our full quoted message.
	if(!input)
		input = "..."

	var/say_mod = message_mods[MODE_CUSTOM_SAY_EMOTE] || message_mods[SAY_MOD_VERB] || say_mod(input, message_mods)

	SEND_SIGNAL(src, COMSIG_MOVABLE_SAY_QUOTE, args)

	if(copytext_char(input, -2) == "!!")
		spans |= SPAN_YELL

	var/spanned = attach_spans(input, spans)
	return "[say_mod], \"[spanned]\""

/// Scans the input sentence for speech emphasis modifiers, notably _italics_ and **bold**
/atom/proc/apply_message_emphasis(message, list/ignore = list())
	var/regex/markup
	for(var/tag in (GLOB.markup_tags - ignore))
		markup = GLOB.markup_regex[tag]
		message = markup.Replace_char(message, "$2[GLOB.markup_tags[tag][1]]$3[GLOB.markup_tags[tag][2]]$5")

	return message

///	Modifies the message by comparing the languages of the speaker with the languages of the hearer. Called on the hearer.
/atom/movable/proc/translate_language(atom/movable/speaker, datum/language/language, raw_message, list/spans, list/message_mods)
	if(!language)
		return "makes a strange sound."

	if(!has_language(language))
		var/datum/language/dialect = GLOB.language_datum_instances[language]
		raw_message = dialect.scramble(raw_message)

	return raw_message

/proc/get_radio_span(freq)
	var/returntext = GLOB.freqtospan["[freq]"]
	if(returntext)
		return returntext
	return "radio"

/proc/get_radio_name(freq)
	var/returntext = GLOB.reverseradiochannels["[freq]"]
	if(returntext)
		return returntext
	return "[copytext_char("[freq]", 1, 4)].[copytext_char("[freq]", 4, 5)]"

/proc/attach_spans(input, list/spans)
	return "[message_spans_start(spans)][input]</span>"

/proc/message_spans_start(list/spans)
	var/output = "<span class='"
	for(var/S in spans)
		output = "[output][S] "
	output = "[output]'>"
	return output

/proc/say_test(text)
	var/ending = copytext_char(text, -1)
	if (ending == "?")
		return "1"
	else if (ending == "!")
		return "2"
	return "0"

/atom/movable/proc/GetVoice()
	return "[src]"	//Returns the atom's name, prepended with 'The' if it's not a proper noun

/atom/movable/proc/get_alt_name()

//HACKY VIRTUALSPEAKER STUFF BEYOND THIS POINT
//these exist mostly to deal with the AIs hrefs and job stuff.

/atom/movable/proc/GetJob() //Get a job, you lazy butte

/atom/movable/proc/GetSource()

/atom/movable/proc/GetRadio()

//VIRTUALSPEAKERS
/atom/movable/virtualspeaker
	var/job
	var/atom/movable/source
	var/obj/item/radio/radio

INITIALIZE_IMMEDIATE(/atom/movable/virtualspeaker)
CREATION_TEST_IGNORE_SUBTYPES(/atom/movable/virtualspeaker)

/atom/movable/virtualspeaker/Initialize(mapload, atom/movable/M, _radio)
	. = ..()
	radio = _radio
	source = M
	if(istype(M))
		name = radio.anonymize ? "Unknown" : M.GetVoice()
		verb_say = M.get_default_say_verb()
		verb_ask = M.get_default_say_verb()
		verb_exclaim = M.get_default_say_verb()
		verb_yell = M.get_default_say_verb()

	// The mob's job identity
	if(ishuman(M))
		// Humans use their job as seen on the crew manifest. This is so the AI
		// can know their job even if they don't carry an ID.
		var/datum/record/crew/found_record = find_record(name, GLOB.manifest.general)
		if(found_record)
			job = found_record.rank
		else
			job = "Unknown"
	else if(iscarbon(M))  // Carbon nonhuman
		job = "No ID"
	else if(isAI(M))  // AI
		job = "AI"
	else if(iscyborg(M))  // Cyborg
		var/mob/living/silicon/robot/B = M
		job = "[B.designation] Cyborg"
	else if(istype(M, /mob/living/silicon/pai))  // Personal AI (pAI)
		job = "Personal AI"
	else if(isobj(M))  // Cold, emotionless machines
		job = "Machine"
	else  // Unidentifiable mob
		job = "Unknown"

/atom/movable/virtualspeaker/GetJob()
	return job

/atom/movable/virtualspeaker/GetSource()
	return source

/atom/movable/virtualspeaker/GetRadio()
	return radio
