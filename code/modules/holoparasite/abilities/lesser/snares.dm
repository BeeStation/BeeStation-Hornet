/datum/holoparasite_ability/lesser/snare
	name = "Surveillance Snares"
	desc = "The $theme can lay a surveillance snare, which alerts the holoparasite and the user to anyone who crosses it."
	ui_icon = "camera"
	cost = 1
	thresholds = list(
		list(
			"stat" = "Potential",
			"minimum" = 3,
			"desc" = "Deployed surveillance snares will function as audio bugs, relaying anything they hear to the holoparasite."
		)
	)
	/// Whether the holoparasite is currently attempting to deploy a snare.
	var/arming = FALSE
	/// Whether snares function as audio relays or not.
	var/audio_relay = TRUE
	/// A list containing all active snares.
	var/list/obj/effect/snare/snares = list()
	/// A list containing all the names of active snares, used with avoid_assoc_duplicate_keys when generating a snare name.
	var/list/snare_names = list()
	/// The HUD button for arming snares.
	var/atom/movable/screen/holoparasite/snare/arm/arm_hud
	/// The HUD button for disarming snares.
	var/atom/movable/screen/holoparasite/snare/disarm/disarm_hud

/datum/holoparasite_ability/lesser/snare/Destroy()
	. = ..()
	QDEL_NULL(arm_hud)
	QDEL_NULL(disarm_hud)
	QDEL_LIST(snares)
	snare_names.Cut()

/datum/holoparasite_ability/lesser/snare/apply()
	..()
	audio_relay = (master_stats.potential >= 3)

/datum/holoparasite_ability/lesser/snare/register_signals()
	..()
	RegisterSignal(owner, COMSIG_HOLOPARA_SETUP_HUD, PROC_REF(on_hud_setup))

/datum/holoparasite_ability/lesser/snare/unregister_signals()
	..()
	UnregisterSignal(owner, COMSIG_HOLOPARA_SETUP_HUD)

/datum/holoparasite_ability/lesser/snare/proc/on_hud_setup(datum/_source, datum/hud/holoparasite/hud, list/huds_to_add)
	SIGNAL_HANDLER
	if(QDELETED(arm_hud))
		arm_hud = new(null, owner, src)
	if(QDELETED(disarm_hud))
		disarm_hud = new(null, owner, src)
	huds_to_add += list(arm_hud, disarm_hud)

/datum/holoparasite_ability/lesser/snare/proc/snare_on_hear(obj/effect/snare/snare, list/hear_args)
	SIGNAL_HANDLER
	if(!length(hear_args) || !istype(snare))
		return
	// We don't care about radio chatter.
	if(hear_args[HEARING_RADIO_FREQ])
		return
	var/message = hear_args[HEARING_RAW_MESSAGE]
	var/atom/movable/speaker = hear_args[HEARING_SPEAKER]
	var/spans = hear_args[HEARING_SPANS]
	var/list/message_mods = hear_args[HEARING_MESSAGE_MODE]
	var/mob/living/summoner = owner.summoner.current
	if(QDELETED(summoner))
		return
	// Don't relay the our own speech!
	if(owner.has_matching_summoner(speaker))
		return
	// Don't relay anything the summoner or the holopara can just hear for themselves.
	if((summoner.can_hear() && (speaker in get_hearers_in_view(7, summoner))) || (speaker in get_hearers_in_view(7, owner)))
		return
	// Bit of a nasty hardcoded hack, but eh, it works!
	var/datum/antagonist/traitor/summoner_traitor = owner.summoner.has_antag_datum(/datum/antagonist/traitor)
	if(summoner_traitor?.has_codewords)
		message = GLOB.syndicate_code_phrase_regex.Replace(message, span_blue("$1"))
		message = GLOB.syndicate_code_response_regex.Replace(message, span_red("$1"))
	// Assemble the message prefix
	var/message_prefix = span_holoparasiteitalicsrobot("\"[COLOR_TEXT(owner.accent_color, snare.name)]\" [speaker.GetVoice()]")
	// Get the say message quote thingy
	var/message_part
	if(message_mods[MODE_CUSTOM_SAY_ERASE_INPUT])
		message_part = message_mods[MODE_CUSTOM_SAY_EMOTE]
	else
		var/atom/movable/source = speaker.GetSource() || speaker
		message_part = source.say_quote(message, spans, message_mods)
	message_part = span_message("[summoner.say_emphasis(message_part)]")
	// And now, we put the final message together and show it to the summoner.
	var/final_message = "[message_prefix] [message_part]"
	to_chat(owner.list_summoner_and_or_holoparasites(), final_message)

/**
 * Updates the appearance of both the arm and disarm hud buttons, as they can change appearance based on the amount of active snares.
 */
/datum/holoparasite_ability/lesser/snare/proc/update_both_huds()
	arm_hud.update_appearance()
	disarm_hud.update_appearance()

/**
 * Disconnects a snare from the holoparasite, alerting the holoparasite and the user.
 */
/datum/holoparasite_ability/lesser/snare/proc/destroy_snare(obj/effect/snare/snare, intentional = FALSE)
	if(!istype(snare) || !(snare in snares))
		return
	snares -= snare
	snare_names -= snare.name
	update_both_huds()
	to_chat(owner.list_summoner_and_or_holoparasites(), "<span class='holoparasite [intentional ? "info" : "danger"] bold'>[COLOR_TEXT(owner.accent_color, snare.name)] [intentional ? "was disarmed." : "was destroyed!"]</span>")

/datum/holoparasite_ability/lesser/snare/proc/try_arm_snare()
	arming = TRUE
	arm_hud.update_appearance()
	arm_snare()
	arming = FALSE
	arm_hud.update_appearance()

/datum/holoparasite_ability/lesser/snare/proc/arm_snare(custom_name)
	if(length(snares) >= HOLOPARA_MAX_SNARES)
		to_chat(owner, span_danger("You have too many snares deployed! You may only have up to <b>[HOLOPARA_MAX_SNARES]</b> active snares at once!"))
		owner.balloon_alert(owner, "too many snares", show_in_chat = FALSE)
		return
	if(!owner.is_manifested())
		to_chat(owner, span_danger("You must be manifested to deploy a snare!"))
		owner.balloon_alert(owner, "must be manifested to deploy snare", show_in_chat = FALSE)
		return
	var/turf/snare_turf = get_turf(owner)
	var/area/snare_area = get_area(snare_turf)
	if(locate(/obj/effect/snare) in snare_turf)
		to_chat(owner, span_danger("There is already a snare at this location!"))
		owner.balloon_alert(owner, "snare already here", show_in_chat = FALSE)
		return
	var/snare_name = name_snare(custom_name, snare_area)
	if(!length(snare_name))
		return
	owner.visible_message(span_warningholoparasite("[owner.color_name] begins to rig some sort of elaborate device..."), span_noticeholoparasite("You begin to set up a snare..."))
	if(!do_after(owner, 2.5 SECONDS, snare_turf))
		to_chat(owner, span_dangerholoparasite("You were interrupted while setting up the snare!"))
		owner.balloon_alert(owner, "snare deployment interrupted", show_in_chat = FALSE)
		return
	var/obj/effect/snare/snare = new(snare_turf, src)
	owner.give_accent_border(snare)
	snare.name = snare_name
	snares |= snare
	if(audio_relay)
		snare.become_hearing_sensitive()
		RegisterSignal(snare, COMSIG_MOVABLE_HEAR, PROC_REF(snare_on_hear))
	to_chat(owner, span_dangerbold("Surveillance snare deployed!"))
	snare.balloon_alert(owner, "snare armed", show_in_chat = FALSE)
	update_both_huds()
	var/datum/space_level/snare_z_level = SSmapping.get_level(snare_turf.z)
	SSblackbox.record_feedback("associative", "holoparasite_snares", 1, list(
		"map" = SSmapping.current_map.map_name,
		"area" = "[snare_area]",
		"x" = snare_turf.x,
		"y" = snare_turf.y,
		"z" = snare_turf.z,
		"z_name" = snare_z_level?.name
	))

/datum/holoparasite_ability/lesser/snare/proc/disarm_snare()
	var/obj/effect/snare/snare_to_disarm
	switch(length(snares))
		if(0)
			to_chat(owner, span_warning("You have no snares to disarm!"))
			return
		if(1)
			snare_to_disarm = snares[1]
			if(tgui_alert(owner, "Are you sure you want to disarm [snare_to_disarm], which is your only snare?", "Disarm Snare", list("Yes", "No")) != "Yes")
				return
		else
			snare_to_disarm = tgui_input_list(owner, "Select a snare to disarm.", "Disarm Snare", snares)
	if(!istype(snare_to_disarm))
		return
	owner.balloon_alert(owner, "snare disarmed", show_in_chat = FALSE)
	destroy_snare(snare_to_disarm, intentional = TRUE)
	qdel(snare_to_disarm)

/datum/holoparasite_ability/lesser/snare/proc/name_snare(custom_name, area/snare_area)
	if(!length(custom_name))
		custom_name = "Surveillance Snare"
	else
		custom_name = trim(custom_name, MAX_NAME_LEN)
		if(CHAT_FILTER_CHECK(custom_name))
			to_chat(owner, span_warning("That custom name contains forbidden words!"))
			return
	return avoid_assoc_duplicate_keys("[custom_name] @ [snare_area.name]", snare_names)

/datum/holoparasite_ability/lesser/snare/proc/get_snare_by_name(name_to_find)
	name_to_find = trim(LOWER_TEXT(name_to_find), MAX_NAME_LEN)
	for(var/obj/effect/snare/snare as() in snares)
		if(LOWER_TEXT(snare.name) == name_to_find)
			return snare

/atom/movable/screen/holoparasite/snare
	var/datum/holoparasite_ability/lesser/snare/ability

CREATION_TEST_IGNORE_SUBTYPES(/atom/movable/screen/holoparasite/snare)

/atom/movable/screen/holoparasite/snare/Initialize(mapload, mob/living/simple_animal/hostile/holoparasite/_owner, datum/holoparasite_ability/lesser/snare/_ability)
	. = ..()
	if(!istype(_ability))
		CRASH("Tried to make snare holoparasite HUD without proper reference to snare ability")
	ability = _ability

/atom/movable/screen/holoparasite/snare/arm
	name = "Arm Snare"
	desc = "Arm a surveillance snare below you, which will alert you whenever someone walks over it."
	icon_state = "snare:arm"

/atom/movable/screen/holoparasite/snare/arm/use()
	if(ability.arming)
		return
	ability.try_arm_snare()

/atom/movable/screen/holoparasite/snare/arm/should_be_transparent()
	return length(ability.snares) >= HOLOPARA_MAX_SNARES

/atom/movable/screen/holoparasite/snare/arm/in_use()
	return ability.arming

/atom/movable/screen/holoparasite/snare/arm/update_overlays()
	. = ..()
	if(!text_overlay)
		text_overlay = image(loc = src)
		text_overlay.maptext_width = 64
		text_overlay.maptext_height = 64
		text_overlay.maptext_x = -16
		text_overlay.maptext_y = 2
		text_overlay.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
	text_overlay.maptext = "<center><span class='chatOverhead' style='font-weight: bold;color: #eeeeee;'>[length(ability.snares)]</span></center>"
	. |= text_overlay

/atom/movable/screen/holoparasite/snare/disarm
	name = "Disarm Snare"
	desc = "Disarm a surveillance snare that you have setup."
	icon_state = "snare:disarm"

/atom/movable/screen/holoparasite/snare/disarm/should_be_transparent()
	return !length(ability.snares)

/atom/movable/screen/holoparasite/snare/disarm/use()
	ability.disarm_snare()

/obj/effect/snare
	name = "snare"
	desc = "..."
	icon = 'icons/mob/holoparasite.dmi'
	icon_state = "snare"
	layer = BELOW_MOB_LAYER
	alpha = 100
	/// A reference to the holoparasite ability that created this snare.
	var/datum/holoparasite_ability/lesser/snare/ability

CREATION_TEST_IGNORE_SUBTYPES(/obj/effect/snare)

/obj/effect/snare/Initialize(mapload, datum/holoparasite_ability/lesser/snare/_ability)
	. = ..()
	if(!istype(_ability))
		stack_trace("Attempted to initialize holoparasite snare without associated ability reference!")
		return INITIALIZE_HINT_QDEL
	ability = _ability
	var/image/blank_image = image(icon_state = "blank", loc = src)
	blank_image.override = TRUE
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/except_holoparasite, "holopara_snare", blank_image, NONE, ability.owner)
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered)
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/snare/Destroy()
	ability.destroy_snare(src)
	return ..()

/obj/effect/snare/examine(mob/user)
	if(!ability.owner.has_matching_summoner(user))
		return list()
	return ..()

/**
 * Alerts the holoparasite and its summoner whenever something crosses the surveillance snare.
 */
/obj/effect/snare/proc/on_entered(datum/source, mob/living/crosser)
	SIGNAL_HANDLER
	if(!istype(crosser))
		return
	if(HAS_TRAIT(crosser, TRAIT_LIGHT_STEP) && prob(45))
		return
	var/mob/living/simple_animal/hostile/holoparasite/owner = ability.owner
	if(owner.has_matching_summoner(crosser))
		return
	to_chat(owner.list_summoner_and_or_holoparasites(), span_warningbold("[crosser] has crossed surveillance snare, [COLOR_TEXT(owner.accent_color, name)]."))
	SSblackbox.record_feedback("amount", "holoparasite_snares_triggered", 1)

/**
 * Destroy the surveillance snare when acted upon by a singularity.
 */
/obj/effect/snare/singularity_act()
	qdel(src)

/**
 * Destroy the surveillance snare when pulled by a singularity.
 */
/obj/effect/snare/singularity_pull(obj/anomaly/singularity/singularity, current_size)
	qdel(src)
