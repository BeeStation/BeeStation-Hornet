/**
 * Send a telepathic message to all of this mob's holoparasites.
 */
/mob/living/proc/holoparasite_telepathy(msg, sanitize = TRUE)
	var/list/mob/living/simple_animal/hostile/holoparasite/holoparas = holoparasites()
	if(!length(holoparas)) // You don't HAVE any holoparasites to talk with!
		return FALSE
	msg = trim(msg, max_length = MAX_MESSAGE_LEN)
	if(!length(msg))
		return FALSE
	if(CHAT_FILTER_CHECK(msg))
		to_chat(src, span_warning("Your message contains forbidden words."))
		return FALSE
	if(sanitize)
		msg = sanitize(msg)
	msg = treat_message_min(msg)
	var/preliminary_message = "[span_srtradioholoparasiteboldmessage("[msg]")]" // Apply basic color and bolding.
	var/my_message = "[span_srtradioholoparasitebold("[span_nameitalics("[src]")]: [preliminary_message]")]" // Add source, and color said source with the default grey.

	to_chat(src, my_message, type = MESSAGE_TYPE_RADIO, avoid_highlighting = TRUE)
	to_chat(holoparas, "[span_bolditalics("[span_name("[src]")]:")] [preliminary_message]", type = MESSAGE_TYPE_RADIO)
	create_chat_message(src, /datum/language/metalanguage, holoparas + src, raw_message = msg, spans = list("holoparasite"))
	for(var/ghost in GLOB.dead_mob_list)
		var/link = FOLLOW_LINK(ghost, src)
		to_chat(ghost, "[link] [my_message]", type = MESSAGE_TYPE_RADIO)

	log_talk(msg, LOG_SAY, tag = "holoparasite ([key_name(src)])")
	return TRUE

/mob/living/simple_animal/hostile/holoparasite/holoparasite_telepathy(msg, sanitize = TRUE)
	if(!summoner.current)
		return FALSE
	msg = trim(msg, max_length = MAX_MESSAGE_LEN)
	if(!length(msg))
		return FALSE
	if(CHAT_FILTER_CHECK(msg))
		to_chat(src, span_warning("Your message contains forbidden words."))
		return FALSE
	if(sanitize)
		msg = sanitize(msg)
	msg = treat_message_min(msg)
	var/preliminary_message = "[span_srtradioholoparasiteboldmessage("[msg]")]" // Apply basic color and bolding.
	var/my_message = "[span_srtradiobolditalics("[color_name]:")] [preliminary_message]" // Add source, and color said source with the holoparasite's color.
	var/ghost_message = "[span_srtradiobolditalics("[color_name] -> [span_name("[summoner.name]")]:")] [preliminary_message]"

	var/list/recipients = list_summoner_and_or_holoparasites()
	to_chat(src, my_message, type = MESSAGE_TYPE_RADIO, avoid_highlighting = TRUE)
	to_chat(recipients - src, my_message, type = MESSAGE_TYPE_RADIO)

	create_chat_message(src, /datum/language/metalanguage, recipients, raw_message = msg, spans = list("holoparasite"))
	for(var/ghost in GLOB.dead_mob_list)
		var/link = FOLLOW_LINK(ghost, src)
		to_chat(ghost, "[link] [ghost_message]", type = MESSAGE_TYPE_RADIO)

	log_talk(msg, LOG_SAY, tag = "holoparasite ([key_name(summoner)])")
	return TRUE

/mob/living/simple_animal/hostile/holoparasite/say(message, bubble_type, list/spans, sanitize, datum/language/language, ignore_spam, forced)
	if(!talk_out_loud && !is_manifested())
		// If they're talking over the radio, let them do that instead of using telepathy.
		var/datum/holoparasite_ability/lesser/misaka/radio_noise = stats.has_lesser_ability(/datum/holoparasite_ability/lesser/misaka)
		if(!radio_noise || !(radio_noise.can_talk && radio_noise.prefix_regex.Find(message)))
			holoparasite_telepathy(message, sanitize)
			return
	return ..()

/mob/living/simple_animal/hostile/holoparasite/radio(message, list/message_mods, list/spans, language)
	var/datum/holoparasite_ability/lesser/misaka/radio_noise = stats.has_lesser_ability(/datum/holoparasite_ability/lesser/misaka)
	if(radio_noise?.can_talk)
		var/obj/item/radio/holoparasite/radio = radio_noise.radio
		if(message_mods[MODE_HEADSET])
			radio.talk_into(src, message, , spans, language, message_mods)
			return NOPASS
		if(message_mods[RADIO_EXTENSION] in radio.channels)
			radio.talk_into(src, message, message_mods[RADIO_EXTENSION], spans, language, message_mods)
			return NOPASS
	return ..()

/mob/living/simple_animal/hostile/holoparasite/binarycheck()
	var/datum/holoparasite_ability/lesser/misaka/radio_noise = stats.has_lesser_ability(/datum/holoparasite_ability/lesser/misaka)
	return radio_noise?.binary || ..()
