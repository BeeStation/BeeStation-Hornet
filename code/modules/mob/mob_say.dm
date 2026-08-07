//Speech verbs.

///Say verb
/mob/verb/say_verb(message as text)
	set name = "Say"
	set category = "IC"
	if(isnewplayer(src))
		return

	if(GLOB.say_disabled) //This is here to try to identify lag problems
		to_chat(usr, span_danger("Speech is currently admin-disabled."))
		return
	if(message)
		say(message)

///Whisper verb
/mob/verb/whisper_verb(message as text)
	set name = "Whisper"
	set category = "IC"
	if(isnewplayer(src))
		return
	if(GLOB.say_disabled)	//This is here to try to identify lag problems
		to_chat(usr, span_danger("Speech is currently admin-disabled."))
		return
	whisper(message)

/**
 * Whisper a message.
 *
 * Basic level implementation just speaks the message, nothing else.
 */
/mob/proc/whisper(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language, ignore_spam = FALSE, forced, filterproof)
	if(!message)
		return
	say(message, language = language) //only living mobs actually whisper, everything else just talks

///The me emote verb
/mob/verb/me_verb(message as text)
	set name = "Me"
	set category = "IC"
	set desc = "Perform a custom emote. Leave blank to pick between an audible or a visible emote (Defaults to visible)."
	if(isnewplayer(src))
		return

	if(GLOB.say_disabled)	//This is here to try to identify lag problems
		to_chat(usr, span_danger("Speech is currently admin-disabled."))
		return

	message = trim(copytext_char(sanitize(message), 1, MAX_MESSAGE_LEN))

	usr.emote("me", NONE, message, TRUE)

/mob/try_speak(message, ignore_spam = FALSE, forced = null, filterproof = null)
	if((client && !forced && CHAT_FILTER_CHECK(message)) && filterproof != TRUE)
		//The filter warning message shows the sanitized message though.
		to_chat(src, span_warning("That message contained a word prohibited in IC chat! Consider reviewing the server rules.\n<span replaceRegex='show_filtered_ic_chat'>\"[message]\""))
		return

	if(client && !(ignore_spam || forced))
		if(client.prefs && (client.player_details.muted & MUTE_IC))
			to_chat(src, span_danger("You cannot speak IC (muted)."))
			return FALSE
		if(client.handle_spam_prevention(message, MUTE_IC))
			return FALSE

	var/sigreturn = SEND_SIGNAL(src, COMSIG_MOB_TRY_SPEECH, message, ignore_spam, forced)
	if(sigreturn & COMPONENT_IGNORE_CAN_SPEAK)
		return TRUE
	if(sigreturn & COMPONENT_CANNOT_SPEAK)
		return FALSE

	if(!..()) // the can_speak check
		if(HAS_MIND_TRAIT(src, TRAIT_MIMING))
			to_chat(src, span_green("Your vow of silence prevents you from speaking!"))
		else
			to_chat(src, span_warning("You find yourself unable to speak!"))
		return FALSE

	return TRUE

/mob/can_speak(allow_mimes = FALSE)
	if(!allow_mimes && HAS_MIND_TRAIT(src, TRAIT_MIMING))
		return FALSE

	return ..()

///Speak as a dead person (ghost etc)
/mob/proc/say_dead(message)
	var/name = real_name
	var/alt_name = ""

	if(GLOB.say_disabled)	//This is here to try to identify lag problems
		to_chat(usr, span_danger("Speech is currently admin-disabled."))
		return

	var/jb = is_banned_from(ckey, "DSAY")
	if(QDELETED(src))
		return

	if(jb)
		to_chat(src, span_danger("You have been banned from deadchat."))
		return

	if (src.client)
		if(src.client.player_details.muted & MUTE_DEADCHAT)
			to_chat(src, span_danger("You cannot talk in deadchat (muted)."))
			return

		if(src.client.handle_spam_prevention(message,MUTE_DEADCHAT))
			return

	var/mob/dead/observer/O = src
	if(isobserver(src) && O.deadchat_name)
		name = "[O.deadchat_name]"
	else
		if(mind?.name)
			name = "[mind.name]"
		else
			name = real_name
		if(name != real_name)
			alt_name = " (died as [real_name])"

	if(OOC_FILTER_CHECK(message))
		to_chat(usr, span_warning("Your message contains forbidden words."))
		return

	var/spanned = generate_messagepart(message)
	var/source = "<span class='game'><span class='prefix'>DEAD:</span> <span class='name'>[name]</span>[alt_name]"
	var/rendered = " <span class='message'>[emoji_parse(spanned)]</span></span>"
	send_chat_to_discord(CHAT_TYPE_DEADCHAT, name, spanned)
	log_talk(message, LOG_SAY, tag="DEAD")
	if(SEND_SIGNAL(src, COMSIG_MOB_DEADSAY, message) & MOB_DEADSAY_SIGNAL_INTERCEPT)
		return
	var/displayed_key = key
	if(client?.holder?.fakekey)
		displayed_key = null
	deadchat_broadcast(rendered, source, follow_target = src, speaker_key = displayed_key)

///Check if this message is an emote
/mob/proc/check_emote(message, forced)
	if(message[1] == "*")
		emote(copytext(message, length(message[1]) + 1), intentional = !forced)
		return TRUE

///Check if the mob has a hivemind channel
/mob/proc/hivecheck()
	return FALSE

///The amount of items we are looking for in the message
#define MESSAGE_MODS_LENGTH 6

/**
 * Checks the inputted message for a custom say emote
 * Basically it checks every message for "|"
 * If a message contains it then it will mark everything that came before "|" as a custom say emote, IE: "stammers|", "cackles|", "screams|", "yells|", and everything after as the message
 * If a message contains "|" but nothing after it then it will convert everything that came before "|" into an emote
 * If a message doesn't contain "|" then it will simply return the input as a message
 *
 * Example
 * * "mutters| hello" will be marked as a custom say emote of "mutters" and the message will be "hello"
 * * and it will appear as Joe Average mutters, "hello"
 * * "screams|" will be marked as a custom say emote of "screams" and it will appear as Joe Average screams.
 */
/mob/proc/check_for_custom_say_emote(message, list/mods)
	var/customsaypos = findtext(message, "|")
	if(!customsaypos)
		return message
	if (!isnull(ckey) && is_banned_from(ckey, "Emote"))
		return copytext(message, customsaypos + 1)
	mods[MODE_CUSTOM_SAY_EMOTE] = trim_right(copytext(message, 1, customsaypos))
	message = trim_left(copytext(message, customsaypos + 1))
	if(!message)
		mods[MODE_CUSTOM_SAY_ERASE_INPUT] = TRUE
		mods[MODE_CUSTOM_SAY_EMOTE] = punctuate(mods[MODE_CUSTOM_SAY_EMOTE])
		message = "an interesting thing to say"
	return message

/**
  * Extracts and cleans message of any extenstions at the beginning of the message
  * Inserts the info into the passed list, returns the cleaned message
  *
  * Result can be
  * * SAY_MODE (Things like aliens, channels that aren't channels)
  * * MODE_WHISPER (Quiet speech)
  * * MODE_SING (Singing)
  * * MODE_HEADSET (Common radio channel)
  * * RADIO_EXTENSION the extension we're using (lots of values here)
  * * RADIO_KEY the radio key we're using, to make some things easier later (lots of values here)
  * * LANGUAGE_EXTENSION the language we're trying to use (lots of values here)
  */
/mob/proc/get_message_mods(message, list/mods)
	for(var/I in 1 to MESSAGE_MODS_LENGTH)
		// Prevents "...text" from being read as a radio message
		if (length(message) > 1 && message[2] == message[1])
			continue

		var/key = message[1]
		var/chop_to = 2 //By default we just take off the first char
		if((key == "#" && !mods[WHISPER_MODE]))
			mods[WHISPER_MODE] = MODE_WHISPER
		else if(key == "%" && !mods[MODE_SING])
			mods[MODE_SING] = TRUE
		else if(key == ";" && !mods[MODE_HEADSET])
			if(stat == CONSCIOUS) //necessary indentation so it gets stripped of the semicolon anyway.
				mods[MODE_HEADSET] = TRUE
		else if((key in GLOB.department_radio_prefixes) && length(message) > length(key) + 1 && !mods[RADIO_EXTENSION])
			key = LOWER_TEXT(message[1 + length(key)])
			var/valid_extension = GLOB.department_radio_keys[key]
			var/valid_say_mode = SSradio.saymodes[key]
			if(valid_extension || valid_say_mode)
				mods[RADIO_KEY] = key
				mods[RADIO_EXTENSION] = GLOB.department_radio_keys[key]
				chop_to = length(key) + 2
			else
				return message
		else if(key == "," && !mods[LANGUAGE_EXTENSION]) // living/say() proc can set LANGUAGE_EXTENSION before this proc.
			for(var/ld in GLOB.all_languages)
				var/datum/language/LD = ld
				if(initial(LD.key) == message[1 + length(message[1])])
					// No, you cannot speak in xenocommon just because you know the key
					if(!can_speak_language(LD))
						return message
					// you are not allowed to use metalanguage key
					if(LD == /datum/language/metalanguage && !HAS_TRAIT(src, TRAIT_METALANGUAGE_KEY_ALLOWED))
						return message
					mods[LANGUAGE_EXTENSION] = LD
					chop_to = length(key) + length(initial(LD.key)) + 1
			if(!mods[LANGUAGE_EXTENSION])
				return message
		else
			return message
		message = trim_left(copytext_char(message, chop_to))
		if(!message)
			return
	return message

#undef MESSAGE_MODS_LENGTH
