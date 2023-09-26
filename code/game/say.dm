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
	"[FREQ_CENTCOM]" = "centcomradio",
	"[FREQ_CTF_RED]" = "redteamradio",
	"[FREQ_CTF_BLUE]" = "blueteamradio"
	))

/atom/movable/proc/say(message, bubble_type, var/list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null, atom/source=src)
	if(!can_speak())
		return
	if(message == "" || !message)
		return
	spans |= speech_span
	if(!language)
		language = get_selected_language()
	send_speech(message, 7, source, , spans, message_language=language)

/atom/movable/proc/Hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, list/message_mods = list())
	SEND_SIGNAL(src, COMSIG_MOVABLE_HEAR, args)

/atom/movable/proc/can_speak()
	//SHOULD_BE_PURE(TRUE) // TODO: Make calls to this actually pure. Its a lot of work, best done in its own PR.
	return TRUE

/atom/movable/proc/send_speech(message, range = 7, obj/source = src, bubble_type, list/spans, datum/language/message_language = null, list/message_mods = list())
	var/rendered = compose_message(src, message_language, message, , spans, message_mods)
	var/list/show_overhead_message_to = list()
	for(var/atom/movable/AM as() in get_hearers_in_view(range, source, SEE_INVISIBLE_MAXIMUM))
		if(ismob(AM))
			var/mob/M = AM
			if(M.should_show_chat_message(source, message_language, FALSE, is_heard = TRUE))
				show_overhead_message_to += M
		AM.Hear(rendered, src, message_language, message, , spans, message_mods)
	if(length(show_overhead_message_to))
		create_chat_message(src, message_language, show_overhead_message_to, message, spans, message_mods)

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
	var/spanpart1 = "<span class='[radio_freq ? get_radio_span(radio_freq) : "game say"]'>"
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

	//Message
	var/messagepart

	var/languageicon = ""
	if(message_mods[MODE_CUSTOM_SAY_ERASE_INPUT])
		messagepart = message_mods[MODE_CUSTOM_SAY_EMOTE]
	else
		messagepart = lang_treat(speaker, message_language, raw_message, spans, message_mods)

		var/datum/language/D = GLOB.language_datum_instances[message_language]
		if(istype(D) && D.display_icon(src))
			languageicon = "[D.get_icon()] "

	messagepart = " <span class='message'>[say_emphasis(messagepart)]</span></span>"

	return "[spanpart1][spanpart2][freqpart][languageicon][compose_track_href(speaker, namepart)][namepart][compose_job(speaker, message_language, raw_message, radio_freq)][endspanpart][messagepart]"

/atom/movable/proc/compose_track_href(atom/movable/speaker, message_langs, raw_message, radio_freq)
	return ""

/atom/movable/proc/compose_job(atom/movable/speaker, message_langs, raw_message, radio_freq)
	return ""

/atom/movable/proc/say_mod(input, list/message_mods = list())
	var/ending = copytext_char(input, -1)
	if(copytext_char(input, -2) == "!!")
		return verb_yell
	else if(ending == "?")
		return verb_ask
	else if(ending == "!")
		return verb_exclaim
	else
		return verb_say

/atom/movable/proc/say_quote(input, list/spans=list(speech_span), list/message_mods = list())
	if(!input)
		input = "..."

	if(copytext_char(input, -2) == "!!")
		spans |= SPAN_YELL

	var/say_mod = message_mods[MODE_CUSTOM_SAY_EMOTE]
	if(!say_mod)
		say_mod = say_mod(input, message_mods)

	var/spanned = attach_spans(input, spans)
	return "[say_mod], \"[spanned]\""

/// Scans the input sentence for speech emphasis modifiers, notably _italics_ and **bold**
/atom/proc/say_emphasis(message, var/list/ignore = list())
	var/regex/markup
	for(var/tag in (GLOB.markup_tags - ignore))
		markup = GLOB.markup_regex[tag]
		message = markup.Replace_char(message, "$2[GLOB.markup_tags[tag][1]]$3[GLOB.markup_tags[tag][2]]$5")

	return message

/atom/movable/proc/lang_treat(atom/movable/speaker, datum/language/language, raw_message, list/spans, list/message_mods = list(), no_quote = FALSE)
	var/atom/movable/source = speaker.GetSource() || speaker //is the speaker virtual
	if(has_language(language))
		return no_quote ? raw_message : source.say_quote(raw_message, spans, message_mods)
	else if(language)
		var/datum/language/D = GLOB.language_datum_instances[language]
		raw_message = D.scramble(raw_message)
		return no_quote ? raw_message : source.say_quote(raw_message, spans, message_mods)
	else
		return "makes a strange sound."

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

/atom/movable/proc/IsVocal()
	return 1

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
/atom/movable/virtualspeaker/Initialize(mapload, atom/movable/M, _radio)
	. = ..()
	radio = _radio
	source = M
	if(istype(M))
		name = radio.anonymize ? "Unknown" : M.GetVoice()
		verb_say = M.verb_say
		verb_ask = M.verb_ask
		verb_exclaim = M.verb_exclaim
		verb_yell = M.verb_yell

	// The mob's job identity
	if(ishuman(M))
		// Humans use their job as seen on the crew manifest. This is so the AI
		// can know their job even if they don't carry an ID.
		var/datum/data/record/findjob = find_record("name", name, GLOB.data_core.general)
		if(findjob)
			job = findjob.fields["rank"]
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
