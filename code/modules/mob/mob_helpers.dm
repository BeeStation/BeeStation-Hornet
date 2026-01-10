// see _DEFINES/is_helpers.dm for mob type checks

///Find the mob at the bottom of a buckle chain
/mob/proc/lowest_buckled_mob()
	. = src
	if(buckled && ismob(buckled))
		var/mob/Buckled = buckled
		. = Buckled.lowest_buckled_mob()

///Convert a PRECISE ZONE into the BODY_ZONE
/proc/check_zone(zone)
	if(!zone)
		return BODY_ZONE_CHEST
	switch(zone)
		if(BODY_ZONE_PRECISE_EYES)
			zone = BODY_ZONE_HEAD
		if(BODY_ZONE_PRECISE_MOUTH)
			zone = BODY_ZONE_HEAD
		if(BODY_ZONE_PRECISE_L_HAND)
			zone = BODY_ZONE_L_ARM
		if(BODY_ZONE_PRECISE_R_HAND)
			zone = BODY_ZONE_R_ARM
		if(BODY_ZONE_PRECISE_L_FOOT)
			zone = BODY_ZONE_L_LEG
		if(BODY_ZONE_PRECISE_R_FOOT)
			zone = BODY_ZONE_R_LEG
		if(BODY_ZONE_PRECISE_GROIN)
			zone = BODY_ZONE_CHEST
	return zone

/**
  * Return the zone or randomly, another valid zone
  *
  * probability controls the chance it chooses the passed in zone, or another random zone
  * defaults to 80
  */
/proc/ran_zone(zone, probability = 80)
	if(prob(probability))
		zone = check_zone(zone)
	else
		zone = pick_weight(list(BODY_ZONE_HEAD = 1, BODY_ZONE_CHEST = 1, BODY_ZONE_L_ARM = 4, BODY_ZONE_R_ARM = 4, BODY_ZONE_L_LEG = 4, BODY_ZONE_R_LEG = 4))
	return zone

///Would this zone be above the neck
/proc/above_neck(zone)
	var/list/zones = list(BODY_ZONE_HEAD, BODY_ZONE_PRECISE_MOUTH, BODY_ZONE_PRECISE_EYES)
	if(zones.Find(zone))
		return 1
	else
		return 0
/**
  * Convert random parts of a passed in message to stars
  *
  * * phrase - the string to convert
  * * probability - probability any character gets changed
  *
  * This proc is dangerously laggy, avoid it or die
  */
/proc/stars(phrase, probability = 25)
	if(probability <= 0)
		return phrase
	phrase = html_decode(phrase)
	var/leng = length(phrase)
	. = ""
	var/char = ""
	for(var/i = 1, i <= leng, i += length(char))
		char = phrase[i]
		if(char == " " || !prob(probability))
			. += char
		else
			. += "*"
	return sanitize(.)

/**
  * Turn text into complete gibberish!
  *
  * text is the inputted message, replace_characters will cause original letters to be replaced and chance are the odds that a character gets modified.
  */
/proc/Gibberish(text, replace_characters = FALSE, chance = 50)
	text = html_decode(text)
	. = ""
	var/rawchar = ""
	var/letter = ""
	var/lentext = length(text)
	for(var/i = 1, i <= lentext, i += length(rawchar))
		rawchar = letter = text[i]
		if(prob(chance))
			if(replace_characters)
				letter = ""
			for(var/j in 1 to rand(0, 2))
				letter += pick("#", "@", "*", "&", "%", "$", "/", "<", ">", ";", "*", "*", "*", "*", "*", "*", "*")
		. += letter
	return sanitize(.)

///Shake the camera of the person viewing the mob SO REAL!
/proc/shake_camera(mob/M, duration, strength=1)
	if(!M || !M.client || duration < 1)
		return
	var/client/C = M.client
	var/oldx = C.pixel_x
	var/oldy = C.pixel_y
	var/max = strength*world.icon_size
	var/min = -(strength*world.icon_size)

	for(var/i in 0 to duration-1)
		if (i == 0)
			animate(C, pixel_x=rand(min,max), pixel_y=rand(min,max), time=1)
		else
			animate(pixel_x=rand(min,max), pixel_y=rand(min,max), time=1)
	animate(pixel_x=oldx, pixel_y=oldy, time=1)


///Find if the message has the real name of any user mob in the mob_list
/proc/findname(msg)
	if(!istext(msg))
		msg = "[msg]"
	for(var/mob/M as anything in GLOB.mob_list)
		if(LOWER_TEXT(M.real_name) == LOWER_TEXT(msg))
			return M
	return FALSE

///Find the first name of a mob from the real name with regex
/mob/proc/first_name()
	var/static/regex/firstname = new("^\[^\\s-\]+") //First word before whitespace or "-"
	firstname.Find(real_name)
	return firstname.match

///Checks if the mob is able to see or not. eye_blind is temporary blindness, the trait is if they're permanently blind.
/mob/proc/is_blind()
	SHOULD_BE_PURE(TRUE)
	return eye_blind ? TRUE : HAS_TRAIT(src, TRAIT_BLIND)

// moved out of admins.dm because things other than admin procs were calling this.
/// Returns TRUE if the game has started and we're either an AI with a 0th law, or we're someone with a special role/antag datum
/proc/is_special_character(mob/M)
	if(!SSticker.HasRoundStarted())
		return FALSE
	if(!istype(M))
		return FALSE
	if(iscyborg(M)) //as a borg you're now beholden to your laws rather than greentext
		return FALSE
	if(isAI(M))
		var/mob/living/silicon/ai/A = M
		return (A.laws?.zeroth && (A.mind?.special_role || !isnull(M.mind?.antag_datums)))
	if(M.mind?.special_role || !isnull(M.mind?.antag_datums)) //they have an antag datum!
		return TRUE
	return FALSE


/mob/proc/reagent_check(datum/reagent/R, delta_time, times_fired) // utilized in the species code
	return TRUE


/**
  * Fancy notifications for ghosts
  *
  * The kitchen sink of notification procs
  *
  * Arguments:
  * * message
  * * ghost_sound sound to play
  * * enter_link Href link to enter the ghost role being notified for
  * * source The source of the notification
  * * alert_overlay The alert overlay to show in the alert message
  * * action What action to take upon the ghost interacting with the notification, defaults to NOTIFY_JUMP
  * * flashwindow Flash the byond client window
  * * ignore_key  Ignore keys if they're in the GLOB.poll_ignore list
  * * header The header of the notifiaction
  * * notify_suiciders If it should notify suiciders (who do not qualify for many ghost roles)
  * * notify_volume How loud the sound should be to spook the user
  */
/proc/notify_ghosts(message, ghost_sound = null, enter_link = null, atom/source = null, mutable_appearance/alert_overlay = null, action = NOTIFY_JUMP, flashwindow = TRUE, ignore_mapload = TRUE, ignore_key, header = null, notify_suiciders = TRUE, notify_volume = 100) //Easy notification of ghosts.
	if(ignore_mapload && SSatoms.initialized != INITIALIZATION_INNEW_REGULAR)	//don't notify for objects created during a map load
		return
	for(var/mob/dead/observer/O in GLOB.player_list)
		if(O.client)
			if(!notify_suiciders && (O in GLOB.suicided_mob_list))
				continue
			if (ignore_key && (O.ckey in GLOB.poll_ignore[ignore_key]))
				continue
			var/orbit_link
			if (source && action == NOTIFY_ORBIT)
				orbit_link = " <a href='byond://?src=[REF(O)];follow=[REF(source)]'>(Orbit)</a>"
			to_chat(O, span_ghostalert("[message][(enter_link) ? " [enter_link]" : ""][orbit_link]"))
			if(ghost_sound)
				SEND_SOUND(O, sound(ghost_sound, volume = notify_volume))
			if(flashwindow)
				window_flash(O.client)
			if(source)
				var/atom/movable/screen/alert/notify_action/A = O.throw_alert("[REF(source)]_notify_action", /atom/movable/screen/alert/notify_action)
				if(A)
					var/ui_style = O.client?.prefs?.read_player_preference(/datum/preference/choiced/ui_style)
					if(ui_style)
						A.icon = ui_style2icon(ui_style)
					if (header)
						A.name = header
					A.desc = message
					A.action = action
					A.target = source
					if(!alert_overlay)
						alert_overlay = new(source)
					alert_overlay.layer = FLOAT_LAYER
					alert_overlay.plane = FLOAT_PLANE
					A.add_overlay(alert_overlay)

/**
  * Heal a robotic body part on a mob
  */
/proc/item_heal_robotic(mob/living/carbon/human/H, mob/user, brute_heal, burn_heal, obj/item/bodypart/affecting)
	if(affecting && (!IS_ORGANIC_LIMB(affecting)))
		var/dam //changes repair text based on how much brute/burn was supplied
		if(brute_heal > burn_heal)
			dam = 1
		else
			dam = 0
		if((brute_heal > 0 && (affecting.brute_dam > 0 || (H.is_bleeding() && H.has_mechanical_bleeding()))) || (burn_heal > 0 && affecting.burn_dam > 0))
			if(affecting.heal_damage(brute_heal, burn_heal, 0, BODYTYPE_ROBOTIC))
				H.update_damage_overlays()
			if (brute_heal > 0 && H.is_bleeding() && H.has_mechanical_bleeding())
				H.cauterise_wounds(0.4)
				user.visible_message("[user] has fixed some of the dents on [H]'s [parse_zone(affecting.body_zone)], reducing [H.p_their()] leaking to [H.get_bleed_rate_string()].")
			else
				user.visible_message("[user] has fixed some of the [dam ? "dents on" : "burnt wires in"] [H]'s [parse_zone(affecting.body_zone)].", \
					span_notice("You fix some of the [dam ? "dents on" : "burnt wires in"] [H == user ? "your" : "[H]'s"] [parse_zone(affecting.body_zone)]."))
			if((affecting.brute_dam <= 0 && brute_heal) && ((!H.is_bleeding()) && H.has_mechanical_bleeding()))
				return FALSE //successful heal, but the target is at full health. Returns false to signal you can stop healing now
			if(affecting.burn_dam <=0 && burn_heal)
				return FALSE //same as above, but checking for burn damage instead
			return TRUE //successful heal
		else
			to_chat(user, span_warning("[affecting] is already in good condition!"))
			return FALSE

///Is the passed in mob an admin ghost
/proc/IsAdminGhost(mob/user)
	if(!user)		//Are they a mob? Auto interface updates call this with a null src
		return
	if(!user.client) // Do they have a client?
		return
	if(!isobserver(user)) // Are they a ghost?
		return
	if(!check_rights_for(user.client, R_ADMIN)) // Are they allowed?
		return
	if(!user.client.AI_Interact) // Do they have it enabled?
		return
	return TRUE

/**
  * Offer control of the passed in mob to dead player
  *
  * Automatic logging and uses poll_candidates_for_mob, how convenient
  */
/proc/offer_control(mob/M)
	to_chat(M, "Control of your mob has been offered to dead players.")
	if(usr)
		log_admin("[key_name(usr)] has offered control of ([key_name(M)]) to ghosts.")
		message_admins("[key_name_admin(usr)] has offered control of ([ADMIN_LOOKUPFLW(M)]) to ghosts")

	var/mob/dead/observer/candidate = SSpolling.poll_ghosts_one_choice(offer_control_get_config(M))

	if(candidate)
		M.give_control_to_mob(candidate)
		return TRUE
	else
		to_chat(M, "There were no ghosts willing to take control.")
		message_admins("No ghosts were willing to take control of [ADMIN_LOOKUPFLW(M)])")
		return FALSE

/proc/offer_control_persistently(mob/M)
	to_chat(M, "Control of your mob has been offered to dead players.")
	if(usr)
		log_admin("[key_name(usr)] has offered control of ([key_name(M)]) to ghosts.")
		message_admins("[key_name_admin(usr)] has offered control of ([ADMIN_LOOKUPFLW(M)]) to ghosts")

	var/datum/candidate_poll/persistent/poll = SSpolling.poll_ghost_candidates_persistently(offer_control_get_config(M))
	poll.on_signup = CALLBACK(M, TYPE_PROC_REF(/mob, give_control_to_mob))

/mob/proc/give_control_to_mob(datum/candidate_poll/persistent/source, list/candidates)
	for (var/mob/controller in candidates)
		ghostize(FALSE)
		key = controller.key
		// Did not login
		if (!client)
			continue
		source.end_poll()

		to_chat(src, "Your mob has been taken over by a ghost!")
		message_admins("[key_name_admin(controller)] has taken control of ([ADMIN_LOOKUPFLW(src)])")
		return

/proc/offer_control_get_config(mob/M)
	var/poll_message = "Do you want to play as [M.real_name]?"
	var/ban_key = BAN_ROLE_ALL_ANTAGONISTS
	if(M.mind && M.mind.assigned_role)
		poll_message = "[poll_message] Job:[M.mind.assigned_role]."
	if(M.mind && M.mind.special_role)
		poll_message = "[poll_message] Status:[M.mind.special_role]."
	else if(M.mind)
		var/datum/antagonist/A = M.mind.has_antag_datum(/datum/antagonist)
		if(A)
			poll_message = "[poll_message] Status:[A.name]."
			ban_key = A.banning_key
	var/datum/poll_config/config = new()
	config.question = poll_message
	config.check_jobban = ban_key
	config.role_name_text = M.real_name
	config.poll_time = 10 SECONDS
	config.jump_target = M
	config.alert_pic = M
	return config

///Clicks a random nearby mob with the source from this mob
/mob/proc/click_random_mob()
	var/list/nearby_mobs = list()
	for(var/mob/living/L in oview(1, src))
		nearby_mobs |= L
	if(nearby_mobs.len)
		var/mob/living/T = pick(nearby_mobs)
		ClickOn(T)

/// Logs a message in a mob's individual log, and in the global logs as well if log_globally is true
/mob/log_message(message, message_type, color=null, log_globally = TRUE)
	if(!LAZYLEN(message))
		stack_trace("Empty message")
		return

	if(SSticker.current_state == GAME_STATE_FINISHED && message_type == LOG_ATTACK)
		return

	// Cannot use the list as a map if the key is a number, so we stringify it (thank you BYOND)
	var/smessage_type = num2text(message_type)

	if(client?.player_details)
		if(!islist(client.player_details.logging[smessage_type]))
			client.player_details.logging[smessage_type] = list()

	if(!islist(logging[smessage_type]))
		logging[smessage_type] = list()

	var/colored_message = message
	if(color)
		if(color[1] == "#")
			colored_message = "<font color=[color]>[message]</font>"
		else
			colored_message = "<font color='[color]'>[message]</font>"

	//This makes readability a bit better for admins.
	switch(message_type)
		if(LOG_WHISPER)
			colored_message = "(WHISPER) [colored_message]"
		if(LOG_OOC)
			colored_message = "(OOC) [colored_message]"
		if(LOG_ASAY)
			colored_message = "(ASAY) [colored_message]"
		if(LOG_EMOTE)
			colored_message = "(EMOTE) [colored_message]"

	var/list/timestamped_message = list("\[[time_stamp()]\] [key_name(src)] [loc_name(src)] (Event #[LAZYLEN(logging[smessage_type])])" = colored_message)

	logging[smessage_type] += timestamped_message

	if(client?.player_details)
		client.player_details.logging[smessage_type] += timestamped_message

	..()

///Can the mob hear
/mob/proc/can_hear()
	. = TRUE

/mob/proc/has_mouth()
	return FALSE

/**
  * Examine text for traits shared by multiple types.
  *
  * I wish examine was less copypasted. (oranges say, be the change you want to see buddy)
  */
/mob/proc/common_trait_examine()
	if(HAS_TRAIT(src, TRAIT_DISSECTED))
		. += "[span_notice("This body has been dissected and analyzed. It is no longer worth experimenting on.")]<br>"

//Can the mob see reagents inside of containers?
/mob/proc/can_see_reagents()
	. = FALSE
	if(stat == DEAD) // Dead guys and silicons can always see reagents
		return TRUE
	else if(has_unlimited_silicon_privilege)
		return TRUE
	else if(HAS_TRAIT(src, TRAIT_REAGENT_SCANNER))
		return TRUE
	else if(HAS_TRAIT(src, TRAIT_BARMASTER)) // If they're a bar master, they know what reagents are at a glance
		return TRUE

/mob/proc/can_see_boozepower() // same rule above
	. = FALSE
	if(stat == DEAD)
		return TRUE
	else if(has_unlimited_silicon_privilege)
		return TRUE
	else if(HAS_TRAIT(src, TRAIT_BOOZE_SLIDER))
		return TRUE
	else if(HAS_TRAIT(src, TRAIT_BARMASTER))
		return TRUE

///Can this mob hold items
/mob/proc/can_hold_items(obj/item/I)
	return length(held_items)

/**
 * Zone selection helpers.
 *
 * There are 2 ways to get the zone selected, a combat mode
 * which determines the zone to target based on what target was
 * pressed and a non-combat mode which displays a wheel of options.
 */

/mob/proc/select_bodyzone(atom/target, precise = FALSE, style = BODYZONE_STYLE_DEFAULT, override_zones = null)
	DECLARE_ASYNC
	// Get the selected bodyzone
	if (client?.prefs.read_player_preference(/datum/preference/choiced/zone_select) == PREFERENCE_BODYZONE_SIMPLIFIED)
		switch (style)
			if (BODYZONE_STYLE_DEFAULT)
				ASYNC_RETURN_TASK(select_bodyzone_from_wheel(target, precise, override_zones = override_zones))
			if (BODYZONE_STYLE_MEDICAL)
				var/accurate_health = HAS_TRAIT(src, TRAIT_MEDICAL_HUD) || istype(get_inactive_held_item(), /obj/item/healthanalyzer)
				if (!accurate_health && isliving(target))
					to_chat(src, span_warning("You could more easilly determine how injured [target] was if you had a medical hud or a health analyser!"))
				ASYNC_RETURN_TASK(select_bodyzone_from_wheel(target, precise, CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(select_bodyzone_limb_health), accurate_health), override_zones))
	// Return the value instantly
	if (precise)
		ASYNC_RETURN(zone_selected)
	ASYNC_RETURN(check_zone(zone_selected))

/**
 * Get the zone that we probably wanted to target. This depends on the context.
 * If we are in an injection context (quick injects like the hyposray) then we will
 * target the first part in the group that isn't protected from injections.
 * If we are in a combat context, then we will randomly pick legs, head and chest and
 * will pick the arm that the target currently has selected.
 * Arm target: Disarm target
 * Leg target: Reduce mobility of target
 * Head/Chest target: Damage/kill target
 */
/mob/proc/get_combat_bodyzone(atom/target = null, precise = FALSE, zone_context = BODYZONE_CONTEXT_COMBAT)
	// Just grab whatever bodyzone they were targetting
	if (client?.prefs.read_player_preference(/datum/preference/choiced/zone_select) != PREFERENCE_BODYZONE_SIMPLIFIED)
		if (!precise)
			return check_zone(zone_selected)
		return zone_selected || BODY_ZONE_CHEST
	// Implicitly determine the bodypart we were trying to target
	switch (zone_selected)
		if (BODY_GROUP_CHEST_HEAD)
			var/head_priority = is_priority_zone(target, BODY_ZONE_HEAD, zone_context)
			var/chest_priority = is_priority_zone(target, BODY_ZONE_CHEST, zone_context)
			return head_priority == chest_priority ? (prob(70) ? BODY_ZONE_CHEST : BODY_ZONE_HEAD) : (head_priority ? BODY_ZONE_HEAD : BODY_ZONE_CHEST)
		if (BODY_GROUP_LEGS)
			var/left_priority = is_priority_zone(target, BODY_ZONE_L_LEG, zone_context)
			var/right_priority = is_priority_zone(target, BODY_ZONE_R_LEG, zone_context)
			return left_priority == right_priority ? pick(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG) : (left_priority ? BODY_ZONE_R_LEG : BODY_ZONE_R_LEG)
		if (BODY_GROUP_ARMS)
			var/left_priority = is_priority_zone(target, BODY_ZONE_L_ARM, zone_context)
			var/right_priority = is_priority_zone(target, BODY_ZONE_R_ARM, zone_context)
			return left_priority == right_priority ? pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM) : (left_priority ? BODY_ZONE_L_ARM : BODY_ZONE_R_ARM)

/mob/proc/is_priority_zone(atom/target, target_zone, context)
	switch (context)
		// Prioritise active hand
		if (BODYZONE_CONTEXT_COMBAT)
			if (isliving(target))
				var/mob/living/living_target = target
				if (living_target.active_hand_index == 1)
					return target_zone == BODY_ZONE_L_ARM
				else
					return target_zone == BODY_ZONE_R_ARM
			return FALSE
		// Prioritise things that aren't injection proof
		if (BODYZONE_CONTEXT_INJECTION)
			if (isliving(target))
				var/mob/living/living_target = target
				return living_target.can_inject(target_zone = target_zone)
			return FALSE
		// Prioritise robotic limbs
		if (BODYZONE_CONTEXT_ROBOTIC_LIMB_HEALING)
			if (isliving(target))
				var/mob/living/living_target = target
				var/obj/item/bodypart/limb = living_target.get_bodypart(target_zone)
				if (!limb)
					return FALSE
				return !IS_ORGANIC_LIMB(limb) && (limb.get_damage() > 0)
			return FALSE

/// Does the mob have a specific bodyzone group selected?
/// This will only work if you are using the simplified system (I mean it will work
/// if the mob isn't, but this proc shouldn't be used for that)
/mob/proc/is_group_selected(requested_group)
	return zone_selected == requested_group

/mob/proc/is_zone_selected(requested_zone = BODY_ZONE_CHEST, simplified_probability = 100, precise_only = FALSE, precise = TRUE)
	if (client?.prefs.read_player_preference(/datum/preference/choiced/zone_select) != PREFERENCE_BODYZONE_SIMPLIFIED)
		return zone_selected == requested_zone || (!precise && check_zone(zone_selected) == requested_zone)
	if (precise_only)
		return FALSE
	// Check if we randomly don't hit the selected zone
	if (simplified_probability != 100 && !prob(simplified_probability))
		return FALSE
	if (requested_zone == zone_selected)
		return TRUE
	switch (zone_selected)
		if (BODY_GROUP_LEGS)
			return requested_zone == BODY_ZONE_L_LEG || requested_zone == BODY_ZONE_R_LEG || requested_zone == BODY_ZONE_PRECISE_L_FOOT || requested_zone == BODY_ZONE_PRECISE_R_FOOT || requested_zone == BODY_ZONE_PRECISE_GROIN
		if (BODY_GROUP_ARMS)
			return requested_zone == BODY_ZONE_L_ARM || requested_zone == BODY_ZONE_R_ARM || requested_zone == BODY_ZONE_PRECISE_L_HAND || requested_zone == BODY_ZONE_PRECISE_R_HAND
		if (BODY_GROUP_CHEST_HEAD)
			return requested_zone == BODY_ZONE_CHEST || requested_zone == BODY_ZONE_HEAD || requested_zone == BODY_ZONE_PRECISE_EYES || requested_zone == BODY_ZONE_PRECISE_MOUTH

/**
 * Don't use this
 */
/mob/proc/_set_zone_selected(zone_selected)
	src.zone_selected = zone_selected

/// Returns a generic path of the object based on the slot
/proc/get_path_by_slot(slot_id)
	switch(slot_id)
		if(ITEM_SLOT_BACK)
			return /obj/item/storage/backpack
		if(ITEM_SLOT_MASK)
			return /obj/item/clothing/mask
		if(ITEM_SLOT_NECK)
			return /obj/item/clothing/neck
		if(ITEM_SLOT_HANDCUFFED)
			return /obj/item/restraints/handcuffs
		if(ITEM_SLOT_LEGCUFFED)
			return /obj/item/restraints/legcuffs
		if(ITEM_SLOT_BELT)
			return /obj/item/storage/belt
		if(ITEM_SLOT_ID)
			return /obj/item/card/id
		if(ITEM_SLOT_EARS)
			return /obj/item/clothing/ears
		if(ITEM_SLOT_EYES)
			return /obj/item/clothing/glasses
		if(ITEM_SLOT_GLOVES)
			return /obj/item/clothing/gloves
		if(ITEM_SLOT_HEAD)
			return /obj/item/clothing/head
		if(ITEM_SLOT_FEET)
			return /obj/item/clothing/shoes
		if(ITEM_SLOT_OCLOTHING)
			return /obj/item/clothing/suit
		if(ITEM_SLOT_ICLOTHING)
			return /obj/item/clothing/under
		if(ITEM_SLOT_LPOCKET)
			return /obj/item
		if(ITEM_SLOT_RPOCKET)
			return /obj/item
		if(ITEM_SLOT_SUITSTORE)
			return /obj/item
	return null
