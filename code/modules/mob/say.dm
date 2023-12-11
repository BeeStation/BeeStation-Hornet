//Speech verbs.

///Say verb
/mob/verb/say_verb(message as text)
	set name = "Say"
	set category = "IC"

	if(GLOB.say_disabled)	//This is here to try to identify lag problems
		to_chat(usr, "<span class='danger'>Speech is currently admin-disabled.</span>")
		return
	if(message)
		say(message)

///Whisper verb
/mob/verb/whisper_verb(message as text)
	set name = "Whisper"
	set category = "IC"
	if(GLOB.say_disabled)	//This is here to try to identify lag problems
		to_chat(usr, "<span class='danger'>Speech is currently admin-disabled.</span>")
		return
	whisper(message)

///whisper a message
/mob/proc/whisper(message, datum/language/language=null)
	say(message, language) //only living mobs actually whisper, everything else just talks

///The me emote verb
/mob/verb/me_verb(message as text)
	set name = "Me"
	set category = "IC"

	if(GLOB.say_disabled)	//This is here to try to identify lag problems
		to_chat(usr, "<span class='danger'>Speech is currently admin-disabled.</span>")
		return

	message = trim(copytext_char(sanitize(message), 1, MAX_MESSAGE_LEN))

	usr.emote("me",1,message,TRUE)

///Speak as a dead person (ghost etc)
/mob/proc/say_dead(var/message)
	var/name = real_name
	var/alt_name = ""

	if(GLOB.say_disabled)	//This is here to try to identify lag problems
		to_chat(usr, "<span class='danger'>Speech is currently admin-disabled.</span>")
		return

	var/jb = is_banned_from(ckey, "DSAY")
	if(QDELETED(src))
		return

	if(jb)
		to_chat(src, "<span class='danger'>You have been banned from deadchat.</span>")
		return



	if (src.client)
		if(src.client.prefs.muted & MUTE_DEADCHAT)
			to_chat(src, "<span class='danger'>You cannot talk in deadchat (muted).</span>")
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
		to_chat(usr, "<span class='warning'>Your message contains forbidden words.</span>")
		return
	var/spanned = say_quote(say_emphasis(message))
	var/rendered = "<span class='game deadsay'><span class='prefix'>DEAD:</span> <span class='name'>[name]</span>[alt_name] <span class='message'>[emoji_parse(spanned)]</span></span>"
	send_chat_to_discord(CHAT_TYPE_DEADCHAT, name, spanned)
	log_talk(message, LOG_SAY, tag="DEAD")
	if(SEND_SIGNAL(src, COMSIG_MOB_DEADSAY, message) & MOB_DEADSAY_SIGNAL_INTERCEPT)
		return
	deadchat_broadcast(rendered, follow_target = src, speaker_key = key)

///Check if this message is an emote
/mob/proc/check_emote(message, forced)
	if(message[1] == "*")
		emote(copytext(message, length(message[1]) + 1), intentional = !forced)
		return TRUE

///Check if the mob has a hivemind channel
/mob/proc/hivecheck()
	return 0

///Check if the mob has a ling hivemind
/mob/proc/lingcheck()
	return LINGHIVE_NONE

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
	if(is_banned_from(ckey, "Emote"))
		return copytext(message, customsaypos + 1)
	mods[MODE_CUSTOM_SAY_EMOTE] = trim_right(lowertext(copytext_char(message, 1, customsaypos)))
	message = trim_left(copytext(message, customsaypos + 1))
	if(!message)
		mods[MODE_CUSTOM_SAY_ERASE_INPUT] = TRUE
		mods[MODE_CUSTOM_SAY_EMOTE] = punctuate(mods[MODE_CUSTOM_SAY_EMOTE])
		message = ""
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
		var/key = message[1]
		var/chop_to = 2 //By default we just take off the first char
		if(key == "#" && !mods[WHISPER_MODE])
			mods[WHISPER_MODE] = MODE_WHISPER
		else if(key == "%" && !mods[MODE_SING])
			mods[MODE_SING] = TRUE
		else if(key == ";" && !mods[MODE_HEADSET] && stat == CONSCIOUS)
			mods[MODE_HEADSET] = TRUE
		else if((key in GLOB.department_radio_prefixes) && length(message) > length(key) + 1 && !mods[RADIO_EXTENSION])
			key = lowertext(message[1 + length(key)])
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
