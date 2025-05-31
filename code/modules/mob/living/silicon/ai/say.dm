/mob/living/silicon/ai/say(message, bubble_type,var/list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	if(parent && istype(parent) && parent.stat != DEAD) //If there is a defined "parent" AI, it is actually an AI, and it is alive, anything the AI tries to say is said by the parent instead.
		parent.say(message, language)
		return
	..(message)

/mob/living/silicon/ai/compose_track_href(atom/movable/speaker, namepart)
	var/mob/M = speaker.GetSource()
	if(M)
		return "<a href='byond://?src=[REF(src)];track=[html_encode(namepart)]'>"
	return ""

/mob/living/silicon/ai/compose_job(atom/movable/speaker, message_langs, raw_message, radio_freq)
	//Also includes the </a> for AI hrefs, for convenience.
	return "[radio_freq ? " (" + speaker.GetJob() + ")" : ""]" + "[speaker.GetSource() ? "</a>" : ""]"

/mob/living/silicon/ai/IsVocal()
	return !CONFIG_GET(flag/silent_ai)

/mob/living/silicon/ai/radio(message, list/message_mods = list(), list/spans, language)
	if(incapacitated())
		return FALSE
	if(!radio_enabled) //AI cannot speak if radio is disabled (via intellicard) or depowered.
		to_chat(src, span_danger("Your radio transmitter is offline!"))
		return FALSE
	..()

//For holopads only. Usable by AI.
/mob/living/silicon/ai/proc/holopad_talk(message, language)
	message = trim(message)

	if (!message)
		return
	if(CHAT_FILTER_CHECK(message))
		to_chat(usr, span_warning("Your message contains forbidden words."))
		return

	if(!QDELETED(ai_hologram))
		ai_hologram.say(message, language = language, source=current_holopad)
		src.log_talk(message, LOG_SAY, tag="Hologram in [AREACOORD(ai_hologram)]")
		ai_hologram.create_private_chat_message(
			message = message,
			message_language = language,
			hearers = list(src),
			includes_ghosts = FALSE) // ghosts already see this except for you...

		// duplication part from `game/say.dm` to make a language icon
		var/language_icon = ""
		var/datum/language/D = GLOB.language_datum_instances[language]
		if(istype(D) && D.display_icon(src))
			language_icon = "[D.get_icon()] "

		message = span_robot(say_emphasis(lang_treat(src, language, message)))
		message = span_srtradioholocall("<b>\[Holocall\] [language_icon][span_name(real_name)]</b> [message]")
		to_chat(src, message)

		for(var/mob/dead/observer/each_ghost in GLOB.dead_mob_list)
			if(!each_ghost.client || !each_ghost.client.prefs.read_player_preference(/datum/preference/toggle/chat_ghostradio))
				continue
			var/follow_link = FOLLOW_LINK(each_ghost, eyeobj || ai_hologram)
			to_chat(each_ghost, "[follow_link] [message]")
	else
		to_chat(src, "No holopad connected.")


// Make sure that the code compiles with AI_VOX undefined
#ifdef AI_VOX
#define VOX_DELAY 600
/mob/living/silicon/ai/verb/announcement_help()

	set name = "Announcement Help"
	set desc = "Display a list of vocal words to announce to the crew."
	set category = "AI Commands"

	if(incapacitated())
		return

	var/dat = {"
	<font class='bad'>WARNING:</font> Misuse of the announcement system will get you job banned.<BR><BR>
	Here is a list of words you can type into the 'Announcement' button to create sentences to vocally announce to everyone on the same level at you.<BR>
	<UL><LI>You can also click on the word to PREVIEW it.</LI>
	<LI>You can only say 30 words for every announcement.</LI>
	<LI>Do not use punctuation as you would normally, if you want a pause you can use the full stop and comma characters by separating them with spaces, like so: 'Alpha . Test , Bravo'.</LI>
	<LI>Numbers are in word format, e.g. eight, sixty, etc </LI>
	<LI>Sound effects begin with 'sound' before the actual word, e.g. soundcensor. They're all at the top of the list.</LI>
	<LI>Use Ctrl+F to see if a word exists in the list.</LI></UL><HR>
	"}

	var/index = 0
	for(var/word in GLOB.vox_sounds)
		index++
		dat += "<A href='byond://?src=[REF(src)];say_word=[word]'>[capitalize(word)]</A>"
		if(index != GLOB.vox_sounds.len)
			dat += " / "

	var/datum/browser/popup = new(src, "announce_help", "Announcement Help", 500, 400)
	popup.set_content(dat)
	popup.open()


/mob/living/silicon/ai/proc/announcement()
	var/static/announcing_vox = 0 // Stores the time of the last announcement
	if(announcing_vox > world.time)
		to_chat(src, span_notice("Please wait [DisplayTimeText(announcing_vox - world.time)]."))
		return

	var/message = capped_input(src, "WARNING: Misuse of this verb can result in you being job banned. More help is available in 'Announcement Help'", "Announcement", src.last_announcement)

	last_announcement = message

	if(!message || announcing_vox > world.time)
		return

	if(incapacitated())
		return

	if(control_disabled)
		to_chat(src, span_warning("Wireless interface disabled, unable to interact with announcement PA."))
		return

	var/list/words = splittext(trim(message), " ")
	var/list/incorrect_words = list()

	if(words.len > 30)
		words.len = 30

	for(var/word in words)
		word = LOWER_TEXT(trim(word))
		if(!word)
			words -= word
			continue
		if(!GLOB.vox_sounds[word])
			incorrect_words += word

	if(incorrect_words.len)
		to_chat(src, span_notice("These words are not available on the announcement system: [english_list(incorrect_words)]."))
		return

	announcing_vox = world.time + VOX_DELAY

	log_game("[key_name(src)] made a vocal announcement with the following message: [message].")
	message_admins("[key_name(src)] made a vocal announcement with the following message: [message].")

	for(var/word in words)
		play_vox_word(word, src.get_virtual_z_level(), null)


/proc/play_vox_word(word, z_level, mob/only_listener)

	word = LOWER_TEXT(word)

	if(GLOB.vox_sounds[word])

		var/sound_file = GLOB.vox_sounds[word]
		var/sound/voice = sound(sound_file, wait = 1, channel = CHANNEL_VOX)
		voice.status = SOUND_STREAM

		// If there is no single listener, broadcast to everyone in the same z level
		if(!only_listener)
			// Play voice for all mobs in the z level
			for(var/mob/M in GLOB.player_list)
				if(M.client && M.can_hear() && M.client.prefs.read_player_preference(/datum/preference/toggle/sound_vox))
					var/turf/T = get_turf(M)
					if(T.get_virtual_z_level() == z_level)
						SEND_SOUND(M, voice)
		else
			SEND_SOUND(only_listener, voice)
		return TRUE
	return FALSE

#undef VOX_DELAY
#endif
