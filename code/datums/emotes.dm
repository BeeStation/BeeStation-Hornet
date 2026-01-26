/datum/emote
	var/key = "" //What calls the emote
	var/key_third_person = "" //This will also call the emote
	var/name = "" // Needed for more user-friendly emote names, so emotes with keys like "aflap" will show as "flap angry". Defaulted to key.
	var/message = "" //Message displayed when emote is used
	var/message_mime = "" //Message displayed if the user is a mime
	var/message_alien = "" //Message displayed if the user is a grown alien
	var/message_larva = "" //Message displayed if the user is an alien larva
	var/message_robot = "" //Message displayed if the user is a robot
	var/message_AI = "" //Message displayed if the user is an AI
	var/message_monkey = "" //Message displayed if the user is a monkey
	var/message_ipc = "" // Message to display if the user is an IPC
	var/message_insect = "" //Message to display if the user is a moth, apid or flyperson
	var/message_simple = "" //Message to display if the user is a simple_animal
	var/message_param = "" //Message to display if a param was given
	/// Whether the emote is visible and/or audible bitflag
	var/emote_type = NONE
	/// Checks if the mob can use its hands before performing the emote.
	var/hands_use_check = FALSE
	var/muzzle_ignore = FALSE //Will only work if the emote is EMOTE_AUDIBLE
	var/list/mob_type_allowed_typecache = /mob //Types that are allowed to use that emote
	var/list/mob_type_blacklist_typecache //Types that are NOT allowed to use that emote
	var/list/mob_type_ignore_stat_typecache
	var/stat_allowed = CONSCIOUS
	/// Sound to play when emote is called
	var/sound
	/// Volume to play the sound at
	var/sound_volume = 50
	/// Do we vary the pitch of the sound played
	var/vary = FALSE
	var/only_forced_audio = FALSE //can only code call this event instead of the player.
	/// The cooldown between the uses of the emote.
	var/cooldown = 0.5 SECONDS
	/// How long is the shared emote cooldown triggered by this emote?
	var/general_emote_audio_cooldown = 7 SECONDS
	/// How long is the specific emote cooldown triggered by this emote?
	var/specific_emote_audio_cooldown = 10 SECONDS
	/// Every time a emote is made, it increases this counter by one. When the integer equals cooldown_integer_ceiling, the mob is forced into a cooldown period
	var/cooldown_integer = 0
	/// Maximum amount of emotes that can be made
	var/cooldown_integer_ceiling = 3
	/// Does this emote's sound ignore walls?
	var/sound_wall_ignore = FALSE

	// Animated emote stuff
	// ~~~~~~~~~~~~~~~~~~~

	/// Animated emotes - Time to flick the overlay for in ticks, use SECONDS defines please.
	var/emote_length
	/// Animated emotes - pixel_x offset
	var/overlay_x_offset = 0
	/// Animated emotes - pixel_y offset
	var/overlay_y_offset = 0
	/// Animated emotes - Icon file for the overlay
	var/icon/overlay_icon = 'icons/effects/overlay_effects.dmi'
	/// Animated emotes - Icon state for the overlay
	var/overlay_icon_state

/datum/emote/New()
	if (ispath(mob_type_allowed_typecache))
		switch (mob_type_allowed_typecache)
			if (/mob)
				mob_type_allowed_typecache = GLOB.typecache_mob
			if (/mob/living)
				mob_type_allowed_typecache = GLOB.typecache_living
			else
				mob_type_allowed_typecache = typecacheof(mob_type_allowed_typecache)
	else
		mob_type_allowed_typecache = typecacheof(mob_type_allowed_typecache)
	mob_type_blacklist_typecache = typecacheof(mob_type_blacklist_typecache)
	mob_type_ignore_stat_typecache = typecacheof(mob_type_ignore_stat_typecache)

	if(!name)
		name = key

/**
 * Handles the modifications and execution of emotes.
 *
 * Arguments:
 * * user - Person that is trying to send the emote.
 * * params - Parameters added after the emote.
 * * type_override - Override to the current emote_type.
 * * intentional - Bool that says whether the emote was forced (FALSE) or not (TRUE).
 *
 */
/datum/emote/proc/run_emote(mob/user, params, type_override, intentional = FALSE)
	SHOULD_CALL_PARENT(TRUE)

	if((emote_type & EMOTE_ANIMATED) && emote_length > 0)
		var/mutable_appearance/emote_image = mutable_appearance(overlay_icon, overlay_icon_state, ABOVE_MOB_LAYER)
		emote_image.pixel_x = overlay_x_offset
		emote_image.pixel_y = overlay_y_offset
		user.flick_overlay_view(emote_image, emote_length)

	var/tmp_sound = get_sound(user)
	if(tmp_sound && should_play_sound(user, intentional) && !TIMER_COOLDOWN_CHECK(user, "audible_emote_cooldown") && !TIMER_COOLDOWN_CHECK(user, type))
		run_cooldown_integer(user)
		playsound(source = user, soundin = tmp_sound, vol = sound_volume, vary = vary, ignore_walls = sound_wall_ignore)

	var/msg = select_message_type(user, message, intentional)
	if(params && message_param)
		msg = select_param(user, params)

	msg = replace_pronoun(user, msg)

	if(isliving(user))
		var/mob/living/L = user
		for(var/obj/item/implant/I in L.implants)
			I.trigger(key, L)

	if(!msg)
		return

	user.log_message(msg, LOG_EMOTE)

	var/space = should_have_space_before_emote(html_decode(msg)[1]) ? " " : ""
	msg = punctuate(msg)

	var/is_important = emote_type & EMOTE_IMPORTANT
	var/is_visual = emote_type & EMOTE_VISIBLE
	var/is_audible = emote_type & EMOTE_AUDIBLE

	// Emote doesn't get printed to chat, runechat only
	if(emote_type & EMOTE_RUNECHAT)
		for(var/mob/viewer as anything in viewers(user))
			if(isnull(viewer.client))
				continue
			if(!is_important && viewer != user && (!is_visual || !is_audible))
				if(is_audible && !viewer.can_hear())
					continue
				if(is_visual && viewer.is_blind())
					continue
			if(user.runechat_prefs_check(viewer, CHATMESSAGE_EMOTE))
				create_chat_message(
					speaker = user,
					raw_message = msg,
					message_mods = list(CHATMESSAGE_EMOTE = TRUE),
				)
			else if(is_important)
				to_chat(viewer, span_emote("<b>[user]</b> [msg]"))
			else if(is_audible && is_visual)
				viewer.show_message(
					span_emote("<b>[user]</b> [msg]"), MSG_AUDIBLE,
					span_emote("You see how <b>[user]</b> [msg]"), MSG_VISUAL,
				)
			else if(is_audible)
				viewer.show_message(span_emote("<b>[user]</b> [msg]"), MSG_AUDIBLE)
			else if(is_visual)
				viewer.show_message(span_emote("<b>[user]</b> [msg]"), MSG_VISUAL)
		return // Early exit so no dchat message

	// The emote has some important information, and should always be shown to the user
	else if(is_important)
		for(var/mob/viewer as anything in viewers(user))
			to_chat(viewer, span_emote("<b>[user]</b> [msg]"))
			if(user.runechat_prefs_check(viewer, list(CHATMESSAGE_EMOTE = TRUE)))
				create_chat_message(user, null, list(viewer), msg, null, list(CHATMESSAGE_EMOTE = TRUE))
	// Emotes has both an audible and visible component
	// Prioritize audible, and provide a visible message if the user is deaf
	else if(is_visual && is_audible)
		user.audible_message(
			message = msg,
			deaf_message = span_emote("You see how <b>[user]</b> [msg]"),
			self_message = msg,
			audible_message_flags = list(CHATMESSAGE_EMOTE = TRUE, ALWAYS_SHOW_SELF_MESSAGE = TRUE),
			separation = space
		)
	// Emote is entirely audible, no visible component
	else if(is_audible)
		user.audible_message(
			message = msg,
			self_message = msg,
			audible_message_flags = list(CHATMESSAGE_EMOTE = TRUE),
			separation = space
		)
	// Emote is entirely visible, no audible component
	else if(is_visual)
		user.visible_message(
			message = msg,
			self_message = msg,
			visible_message_flags = list(CHATMESSAGE_EMOTE = TRUE, ALWAYS_SHOW_SELF_MESSAGE = TRUE),
		)
	else
		CRASH("Emote [type] has no valid emote type set!")

	if(!isnull(user.client))
		var/dchatmsg = "<b>[user]</b> [msg]"
		for(var/mob/ghost as anything in GLOB.dead_mob_list - viewers(get_turf(user)))
			if(isnull(ghost.client) || isnewplayer(ghost))
				continue
			if(!ghost?.client.prefs?.read_player_preference(/datum/preference/toggle/chat_ghostsight))
				continue
			to_chat(ghost, span_emote("[FOLLOW_LINK(ghost, user)] [dchatmsg]"))
	return

/datum/emote/proc/run_cooldown_integer(mob/user)
	//If we do one audible emote, then do nothing, we eventually should purge our list
	cooldown_integer_window(user)
	cooldown_integer += 1
	//debug
	//user.balloon_alert(user, "[cooldown_integer]")
	check_cooldown_integer(user)

/datum/emote/proc/check_cooldown_integer(mob/user)
	if(cooldown_integer >= cooldown_integer_ceiling)
		to_chat(user, span_warning("[name] emote limit reached"))
		TIMER_COOLDOWN_START(user, type, specific_emote_audio_cooldown)
		TIMER_COOLDOWN_START(user, "general_emote_audio_cooldown", general_emote_audio_cooldown)
		//We used up all our usable emotes, now we set the integer back to zero and wait the long wait
		cooldown_integer = initial(cooldown_integer)

/datum/emote/proc/cooldown_integer_window(mob/user)
	if(TIMER_COOLDOWN_CHECK(user, COOLDOWN_EMOTE_WINDOW))
		TIMER_COOLDOWN_START(user, COOLDOWN_EMOTE_WINDOW, 4 SECONDS)
	else
		//We did a few emotes, but didnt use them all up, reset our integer
		cooldown_integer = initial(cooldown_integer)

/**
 * For handling emote cooldown, return true to allow the emote to happen.
 *
 * Arguments:
 * * user - Person that is trying to send the emote.
 * * intentional - Bool that says whether the emote was forced (FALSE) or not (TRUE).
 *
 * Returns FALSE if the cooldown is not over, TRUE if the cooldown is over.
 */
/datum/emote/proc/check_cooldown(mob/user, intentional)
	if(!intentional)
		return TRUE

	if(user.emotes_used && user.emotes_used[src] + cooldown > world.time)
		return FALSE

	if(!user.emotes_used)
		user.emotes_used = list()

	user.emotes_used[src] = world.time
	return TRUE

/datum/emote/proc/get_sound(mob/living/user)
	return sound //by default just return this var.

/datum/emote/proc/replace_pronoun(mob/user, message)
	if(findtext(message, "their"))
		message = replacetext(message, "their", user.p_their())
	if(findtext(message, "them"))
		message = replacetext(message, "them", user.p_them())
	if(findtext(message, "%s"))
		message = replacetext(message, "%s", user.p_s())
	return message

/datum/emote/proc/select_message_type(mob/user, msg, intentional)
	. = msg
	if(!muzzle_ignore && user.is_muzzled() && (emote_type & EMOTE_AUDIBLE))
		return "makes a [pick("strong ", "weak ", "")]noise."
	if(HAS_TRAIT(user, TRAIT_MIMING) && message_mime)
		. = message_mime
	if(isalienadult(user) && message_alien)
		. = message_alien
	else if(islarva(user) && message_larva)
		. = message_larva
	else if(iscyborg(user) && message_robot)
		. = message_robot
	else if(isAI(user) && message_AI)
		. = message_AI
	else if(ismonkey(user) && message_monkey)
		. = message_monkey
	else if(isipc(user) && message_ipc)
		. = message_ipc
	else if((ismoth(user) || isapid(user) || isflyperson(user)) && message_insect)
		. = message_insect
	else if((isanimal(user) || isbasicmob(user)) && message_simple)
		. = message_simple

	return .

/datum/emote/proc/select_param(mob/user, params)
	return replacetext(message_param, "%t", params)

/datum/emote/proc/can_run_emote(mob/user, status_check = TRUE, intentional = FALSE, params)
	if(!is_type_in_typecache(user, mob_type_allowed_typecache))
		return FALSE
	if(is_type_in_typecache(user, mob_type_blacklist_typecache))
		return FALSE
	if(status_check && !is_type_in_typecache(user, mob_type_ignore_stat_typecache))
		if(user.stat > stat_allowed)
			if(!intentional)
				return FALSE
			switch(user.stat)
				if(SOFT_CRIT)
					to_chat(user, span_notice("You cannot [key] while in a critical condition."))
				if(UNCONSCIOUS, HARD_CRIT)
					to_chat(user, span_notice("You cannot [key] while unconscious."))
				if(DEAD)
					to_chat(user, span_notice("You cannot [key] while dead."))
			return FALSE
		if(hands_use_check && HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
			if(!intentional)
				return FALSE
			to_chat(user, span_warning("You cannot use your hands to [key] right now!"))
			return FALSE

	if(HAS_TRAIT(user, TRAIT_EMOTEMUTE))
		return FALSE

	return TRUE

/**
 * Check to see if the user should play a sound when performing the emote.
 *
 * Arguments:
 * * user - Person that is doing the emote.
 * * intentional - Bool that says whether the emote was forced (FALSE) or not (TRUE).
 *
 * Returns a bool about whether or not the user should play a sound when performing the emote.
 */
/datum/emote/proc/should_play_sound(mob/user, intentional = FALSE)
	if(emote_type & EMOTE_AUDIBLE && !hands_use_check)
		if(ishuman(user))
			var/mob/living/carbon/human/loud_mouth = user
			if(HAS_TRAIT(loud_mouth, TRAIT_MIMING)) // vow of silence prevents outloud noises
				return FALSE
			if(!loud_mouth.get_organ_slot(ORGAN_SLOT_TONGUE))
				return FALSE

	if(only_forced_audio && intentional)
		return FALSE
	return TRUE

/**
* Allows the intrepid coder to send a basic emote
* Takes text as input, sends it out to those who need to know after some light parsing
* If you need something more complex, make it into a datum emote
* Arguments:
* * text - The text to send out
*
* Returns TRUE if it was able to run the emote, FALSE otherwise.
*/
/atom/proc/manual_emote(text)
	if(!text)
		CRASH("Someone passed nothing to manual_emote(), fix it")

	log_message(text, LOG_EMOTE)
	visible_message(text, visible_message_flags = list(CHATMESSAGE_EMOTE = TRUE))
	return TRUE

/mob/manual_emote(text)
	if (stat != CONSCIOUS)
		return FALSE
	. = ..()
	if (!.)
		return FALSE
	if (!client)
		return TRUE
	var/ghost_text = "<b>[src]</b> [text]"
	var/origin_turf = get_turf(src)
	for(var/mob/ghost as anything in GLOB.dead_mob_list)
		if(!ghost.client || isnewplayer(ghost))
			continue
		if(ghost.client.prefs.read_player_preference(/datum/preference/toggle/chat_ghostsight) && !(ghost in viewers(origin_turf, null)))
			if(mind || ghost.client.prefs.read_player_preference(/datum/preference/toggle/chat_followghostmindless))
				ghost.show_message("[FOLLOW_LINK(ghost, src)] [ghost_text]")
			else
				ghost.show_message("[ghost_text]")
	return TRUE

/**
 * Returns a boolean based on whether or not the string contains a comma or an apostrophe,
 * to be used for emotes to decide whether or not to have a space between the name of the user
 * and the emote.
 *
 * Requires the message to be HTML decoded beforehand. Not doing it here for performance reasons.
 *
 * Returns TRUE if there should be a space, FALSE if there shouldn't.
 */
/proc/should_have_space_before_emote(string)
	var/static/regex/no_spacing_emote_characters = regex(@"(,|')")
	return !no_spacing_emote_characters.Find(string)
