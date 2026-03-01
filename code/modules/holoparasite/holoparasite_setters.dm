/**
 * Sets the summoner of the holoparasite.
 */
/mob/living/simple_animal/hostile/holoparasite/proc/set_summoner(datum/mind/new_summoner)
	if(!istype(new_summoner))
		stack_trace("Bad summoner type: [new_summoner] on [key_name(src)], expected mind")
		return FALSE
	var/datum/mind/old_summoner = summoner
	// Unregister all signals from our old summoner.
	if(old_summoner?.current)
		unregister_body_signals(old_summoner.current)
	// Unregister ourself from the old holder.
	parent_holder?.remove_holoparasite(src)
	mind?.enslaved_to = null
	faction.Cut()
	// Set our summoner to the new one.
	summoner = new_summoner
	// Register ourself to the new holder
	var/datum/holoparasite_holder/new_holder = new_summoner.holoparasite_holder()
	new_holder.add_holoparasite(src)
	parent_holder.holoparasites |= src
	mind_initialize()
	// Enslave the holoparasite's mind to the summoner.
	mind.enslave_mind_to_creator(new_summoner)
	// This is a nested tally list, just in case that future jobs rework ever gets merged.
	SSblackbox.record_feedback("nested tally", "holoparasite_summoner_special_roles", 1, new_summoner.special_role ? list(new_summoner.special_role) : list("(none)"))
	// Register all signals to our new summoner.
	if(new_summoner.current)
		register_body_signals(new_summoner.current)
	// Take the verbs from our old summoner.
	old_summoner?.current?.update_holoparasite_verbs()
	// Give holopara verbs to our new summoner.
	new_summoner?.current?.update_holoparasite_verbs()
	// Force the holoparasite to recall to its master.
	recall(forced = TRUE)
	// Send a signal.
	SEND_SIGNAL(src, COMSIG_HOLOPARA_SET_SUMMONER, old_summoner, new_summoner)
	SEND_SIGNAL(mind, COMSIG_HOLOPARA_SET_SUMMONER, old_summoner, new_summoner)
	return TRUE

/**
 * Sets the new name of the holoparasite.
 */
/mob/living/simple_animal/hostile/holoparasite/proc/set_name(new_name, silent = FALSE, internal = FALSE)
	. = TRUE
	if(!istext(new_name))
		return FALSE
	new_name = trim(new_name)
	if(new_name == real_name)
		return
	var/name_length = length(new_name)
	if(!name_length || name_length > MAX_NAME_LEN)
		return FALSE
	var/old_name = real_name
	var/old_color_name = color_name
	name = new_name
	real_name = new_name
	mind?.name = new_name
	color_name = span_name("[COLOR_TEXT(accent_color, new_name)]")
	SSblackbox.record_feedback("text", "holoparasite_name", 1, new_name)
	SEND_SIGNAL(src, COMSIG_HOLOPARA_SET_NAME, old_name, new_name)
	if(!internal)
		message_admins("[ADMIN_LOOKUPFLW(src)] was renamed from [old_name] to [new_name].")
		log_game("[key_name(src)] was renamed from [old_name] to [new_name]")
		if(!silent)
			to_chat(src, span_holoparasite("Your name is now [color_name]!"))
			to_chat(summoner.current, span_holoparasite("[old_color_name] is now known as [color_name]!"))

/**
 * Sets the accent color of the holoparasite.
 */
/mob/living/simple_animal/hostile/holoparasite/proc/set_accent_color(new_color, silent = FALSE)
	if(!new_color)
		return FALSE
	var/old_accent_color = accent_color
	new_color = sanitize_hexcolor(new_color, include_crunch = TRUE, default = (length(old_accent_color) == 7 && old_accent_color != initial(accent_color)) ? old_accent_color : pick(GLOB.color_list_rainbow))
	accent_color = new_color
	chat_color = new_color
	if(tracking_beacon)
		tracking_beacon.colour = new_color
		tracking_beacon.remove_from_huds()
		if(is_manifested() && range != 1)
			tracking_beacon.add_to_huds()
	for(var/mutable_appearance/overlay as() in accent_overlays)
		overlay.color = new_color
	color_name = span_name("[COLOR_TEXT(new_color, real_name)]")
	SEND_SIGNAL(src, COMSIG_HOLOPARA_SET_ACCENT_COLOR, old_accent_color, new_color)
	if(!silent)
		to_chat(src, span_holoparasite("Your [COLOR_TEXT(new_color, "new accent color")] has been set."))
	SSblackbox.record_feedback("tally", "holoparasite_accent_color", 1, new_color)
	return TRUE

/mob/living/simple_animal/hostile/holoparasite/proc/set_theme(datum/holoparasite_theme/new_theme)
	var/datum/holoparasite_theme/old_theme = theme
	new_theme = get_holoparasite_theme(new_theme)
	if(!istype(new_theme))
		CRASH("Attempted to set invalid holoparasite theme on [key_name(src)]")
	theme = new_theme
	new_theme.apply(src)
	SSblackbox.record_feedback("tally", "holoparasite_theme", 1, "[new_theme.type]")
	SEND_SIGNAL(src, COMSIG_HOLOPARA_SET_THEME, old_theme, new_theme)
	return TRUE

/mob/living/simple_animal/hostile/holoparasite/proc/set_battlecry(new_battlecry, silent = FALSE)
	. = TRUE
	if(!length(new_battlecry))
		SSblackbox.record_feedback("tally", "holoparasite_battlecry", 1, "(none)")
		battlecry = null
		balloon_alert(src, "battlecry unset", show_in_chat = FALSE)
		return
	new_battlecry = trim(new_battlecry, HOLOPARA_MAX_BATTLECRY_LENGTH)
	if(CHAT_FILTER_CHECK(new_battlecry))
		if(!silent)
			to_chat(src, span_warning("Your battlecry contains forbidden words."))
		return FALSE
	battlecry = new_battlecry
	if(!silent)
		to_chat(src, span_notice("You set your battlecry to '<b>[battlecry]</b>'."))
	SSblackbox.record_feedback("tally", "holoparasite_battlecry", 1, battlecry)
	balloon_alert(src, "battlecry set", show_in_chat = FALSE)
