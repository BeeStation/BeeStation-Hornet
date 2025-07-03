/datum/holoparasite_ability/lesser/telepathy
	name = "Telepathy"
	desc = "The $theme can send a telepathic message to anyone it has encountered recently."
	ui_icon = "comments"
	cost = 1
	thresholds = list(
		list(
			"stat" = "Potential",
			"desc" = "Increases the duration which scanned beings will be remembered for."
		),
		list(
			"stat" = "Range",
			"desc" = "Increases the scanning range of the $theme."
		),
		list(
			"stat" = "Potential",
			"minimum" = 5,
			"desc" = "Leaves a temporary telepathic link open when communicating, allowing any being to telepathically respond to the $theme."
		)
	)
	/// The maximum distance that the holoparasite can scan for potential targets.
	var/scanning_range = 7
	/// How long a target scanned by the holoparasite will be remembered for.
	var/valid_time = 15 MINUTES
	/// Whether beings can respond to the holoparasite's telepathic messages.
	var/can_respond = TRUE
	/// A list of beings that the holoparasite has telepathically communicated with, and the maximum time at which they can respond.
	/// [mob] = maximum response time
	var/list/mob/living/can_respond_until = list()
	/// A list of all potential targets that have been encountered by the holoparasite recently.
	/// [mob] = removal time
	var/list/mob/living/potential_targets = list()
	/// The HUD button for the actual telepathy ability.
	var/atom/movable/screen/holoparasite/telepathy/telepathy_hud
	/// When the holoparasite will scan for potential targets again.
	COOLDOWN_DECLARE(next_scan)

/datum/holoparasite_ability/lesser/telepathy/Destroy()
	. = ..()
	QDEL_NULL(telepathy_hud)

/datum/holoparasite_ability/lesser/telepathy/apply()
	..()
	scanning_range = master_stats.range + 2
	valid_time = master_stats.potential * 3 MINUTES
	can_respond = master_stats.potential >= 5
	START_PROCESSING(SSprocessing, src)

/datum/holoparasite_ability/lesser/telepathy/remove()
	..()
	STOP_PROCESSING(SSprocessing, src)

/datum/holoparasite_ability/lesser/telepathy/register_signals()
	. = ..()
	RegisterSignal(owner, COMSIG_HOLOPARA_SETUP_HUD, PROC_REF(on_hud_setup))
	RegisterSignal(owner, COMSIG_LIVING_REVIVE, PROC_REF(on_revival))
	RegisterSignal(owner, COMSIG_LIVING_DEATH, PROC_REF(on_death))

/datum/holoparasite_ability/lesser/telepathy/unregister_signals()
	. = ..()
	UnregisterSignal(owner, list(COMSIG_HOLOPARA_SETUP_HUD, COMSIG_LIVING_REVIVE, COMSIG_LIVING_DEATH))

/datum/holoparasite_ability/lesser/telepathy/proc/on_hud_setup(datum/_source, datum/hud/holoparasite/hud, list/huds_to_add)
	SIGNAL_HANDLER
	if(QDELETED(telepathy_hud))
		telepathy_hud = new(null, owner, src)
	huds_to_add += telepathy_hud

/**
 * Restart scanning whenever the holoparasite is revived.
 */
/datum/holoparasite_ability/lesser/telepathy/proc/on_revival()
	SIGNAL_HANDLER
	START_PROCESSING(SSprocessing, src)

/**
 * Stop scanning whenever the holoparasite dies, and remove all potential targets.
 */
/datum/holoparasite_ability/lesser/telepathy/proc/on_death()
	SIGNAL_HANDLER
	STOP_PROCESSING(SSprocessing, src)
	can_respond_until.Cut()
	potential_targets.Cut()

/**
 * Scan nearby mobs for potential targets, and remove any targets that have been out of range for too long.
 */
/datum/holoparasite_ability/lesser/telepathy/process()
	if(owner.stat == DEAD)
		return PROCESS_KILL
	if(!COOLDOWN_FINISHED(src, next_scan))
		return
	var/original_length = length(potential_targets)
	var/turf/owner_turf = get_turf(owner)
	var/list/updated = list()
	var/next_removal_time = world.time + valid_time
	var/list/view_scan = view(scanning_range, owner_turf)
	view_scan -= owner.list_summoner_and_or_holoparasites()
	for(var/mob/living/potential_target in view_scan)
		if(!potential_target.mind || !potential_target.ckey)
			continue
		if(istype(potential_target.get_item_by_slot(ITEM_SLOT_HEAD), /obj/item/clothing/head/costume/foilhat))
			continue
		potential_targets[potential_target] = next_removal_time
		updated += potential_target
	for(var/mob/living/potential_target as() in potential_targets - updated)
		if(world.time >= potential_targets[potential_target] || istype(potential_target.get_item_by_slot(ITEM_SLOT_HEAD), /obj/item/clothing/head/costume/foilhat))
			potential_targets -= potential_target
	if(length(potential_targets) != original_length)
		telepathy_hud.update_icon() // update maptext
	COOLDOWN_START(src, next_scan, HOLOPARA_TELEPATHY_SCAN_COOLDOWN)

/**
 * Sends a telepathic message to a target.
 * Checks to ensure the target is valid, that the holoparasite has been near the target recently enough,
 * and that the message does not contain any prohibited words.
 *
 * Arguments
 * * target: The target to send the message to.
 * * message: The message to send.
 * * sanitize: Whether to sanitize the message before sending it.
 */
/datum/holoparasite_ability/lesser/telepathy/proc/telepathy(mob/living/target, message, sanitize = TRUE)
	if(!message || !istype(target))
		return
	message = trim(message, max_length = MAX_MESSAGE_LEN)
	if(!length(message))
		return
	if(!potential_targets[target] || world.time >= potential_targets[target])
		to_chat(owner, span_warning("You cannot communicate with [target], you have not been near [target.p_them()] recently enough!"))
		return
	if(istype(target.get_item_by_slot(ITEM_SLOT_HEAD), /obj/item/clothing/head/costume/foilhat))
		to_chat(owner, span_warning("Your telepathy is blocked by the foil hat on [target]'s head!"))
		return
	if(sanitize)
		message = sanitize(message)
	message = owner.treat_message_min(message)
	if(CHAT_FILTER_CHECK(message))
		to_chat(usr, span_warning("You cannot send a telepathic message that contains prohibited words."))
		return
	var/response_href = ""
	if(can_respond(target, check_time = FALSE, silent = TRUE))
		can_respond_until[target] = world.time + HOLOPARA_TELEPATHY_RESPONSE_TIME
		response_href = "<a href='byond://?src=[REF(src)];respond=1'><b>\[[span_hypnophrase("RESPOND")]\]</b></a> "
	SSblackbox.record_feedback("amount", "holoparasite_telepathy_sent", 1)
	to_chat(owner, span_holoparasite("You telepathically said: \"[span_message(message)]\" to [span_name(target)]."), type = MESSAGE_TYPE_RADIO, avoid_highlighting = TRUE)
	to_chat(target, span_holoparasite("[response_href][span_notice("You hear a strange, resonating voice in your head...")] [span_message("[COLOR_TEXT(owner.accent_color, message)]")]"), type = MESSAGE_TYPE_RADIO)
	log_directed_talk(owner, target, message, LOG_SAY, "holoparasite telepathy")
	for(var/mob/dead/dead in GLOB.dead_mob_list)
		if(!isobserver(dead) || !dead.client)
			continue
		var/follow_link_user = FOLLOW_LINK(dead, owner)
		var/follow_link_target = FOLLOW_LINK(dead, target)
		to_chat(dead, "[span_holoparasite("[follow_link_user] [owner.color_name] Telepathy --> [follow_link_target] [span_name(target)]")] [span_holoparasitemessage(message)]", type = MESSAGE_TYPE_RADIO)

/**
 * Handles telepathic responses.
 */
/datum/holoparasite_ability/lesser/telepathy/Topic(href, list/href_list)
	if(!href_list["respond"] || !can_respond(usr))
		return
	var/message = tgui_input_text(usr, "What would you like to respond to the telepathic message with?", "Telepathic Response", timeout = can_respond_until[usr] - world.time)
	if(!message || !length(message) || !can_respond(usr))
		return
	message = usr.treat_message_min(message)
	if(CHAT_FILTER_CHECK(message))
		to_chat(usr, span_warning("You cannot send a telepathic response that contains prohibited words."))
		return
	SSblackbox.record_feedback("amount", "holoparasite_telepathy_responses", 1)
	to_chat(usr, span_holoparasite("You telepathically respond to the message with \"[span_message(message)]\"."), type = MESSAGE_TYPE_RADIO, avoid_highlighting = TRUE)
	to_chat(owner, span_holoparasite("Telepathic response from [span_name("[usr]")]: [span_message(message)]"), type = MESSAGE_TYPE_RADIO)
	log_directed_talk(usr, owner, message, LOG_SAY, "holoparasite telepathy response")
	create_chat_message(usr, /datum/language/metalanguage, list(owner), raw_message = message, spans = list("holoparasite"))
	for(var/mob/dead/observer/gost in GLOB.dead_mob_list)
		var/follow_link_user = FOLLOW_LINK(gost, usr)
		var/follow_link_owner = FOLLOW_LINK(gost, owner)
		to_chat(gost, span_holoparasite("[follow_link_user] [span_name("[usr]")] Telepathic Response --> [follow_link_owner] [owner.color_name] [span_holoparasitemessage(message)]"), type = MESSAGE_TYPE_RADIO)

/datum/holoparasite_ability/lesser/telepathy/proc/can_respond(mob/living/responder, check_time = TRUE, silent = FALSE)
	. = TRUE
	if(!istype(responder) || responder.stat == DEAD)
		return FALSE
	if(owner.stat == DEAD)
		if(!silent)
			to_chat(responder, span_warning("You feel as if the telepathic link has been broken..."))
		return FALSE
	if(check_time)
		if(!can_respond_until[responder])
			return FALSE
		if(world.time > can_respond_until[responder])
			if(!silent)
				to_chat(responder, span_warning("It's too late to respond now!"))
			return FALSE
	if(istype(responder.get_item_by_slot(ITEM_SLOT_HEAD), /obj/item/clothing/head/costume/foilhat))
		if(!silent)
			to_chat(responder, span_warning("Your response is blocked by the foil hat on your head!"))
		return FALSE
	if(!can_respond)
		if(iscarbon(responder))
			var/mob/living/carbon/carbon_responder = responder
			if(carbon_responder.has_dna())
				// Stargazers can always telepathically respond.
				if(isstargazer(carbon_responder))
					return TRUE
				// As can anyone with the telepathy mutation.
				if(carbon_responder.dna.check_mutation(/datum/mutation/telepathy))
					return TRUE
		return FALSE

/atom/movable/screen/holoparasite/telepathy
	name = "Telepathy"
	desc = "Transmit a telepathic message to any sapient being you have recently encountered."
	icon_state = "base"
	accent_overlay_states = list("telepathy-accent")
	var/datum/holoparasite_ability/lesser/telepathy/ability

CREATION_TEST_IGNORE_SUBTYPES(/atom/movable/screen/holoparasite/telepathy)

/atom/movable/screen/holoparasite/telepathy/Initialize(mapload, mob/living/simple_animal/hostile/holoparasite/_owner, datum/holoparasite_ability/lesser/telepathy/_ability)
	. = ..()
	if(!istype(_ability))
		CRASH("Tried to make telepad holoparasite HUD without proper reference to telepathy ability")
	ability = _ability
	update_icon()

/atom/movable/screen/holoparasite/telepathy/on_login()
	if(!text_overlay || !owner?.client)
		return
	owner.client.images |= text_overlay

/atom/movable/screen/holoparasite/telepathy/update_overlays()
	. = ..()
	if(!text_overlay)
		text_overlay = image(loc = src)
		text_overlay.maptext_width = 64
		text_overlay.maptext_height = 64
		text_overlay.maptext_x = -16
		text_overlay.maptext_y = 2
		text_overlay.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
	text_overlay.maptext = "<center><span class='chatOverhead' style='font-weight: bold;color: #eeeeee;'>[length(ability.potential_targets)]</span></center>"
	. |= text_overlay

/atom/movable/screen/holoparasite/telepathy/use()
	if(!length(ability.potential_targets))
		to_chat(owner, span_warning("You haven't recently encountered any beings you can send telepathic messages to!"))
		return
	var/list/targets = assoc_to_keys(ability.potential_targets)
	var/mob/living/target = tgui_input_list(owner, "Select a being to telepathically communicate with", "Holoparasite Telepathy", targets)
	if(!istype(target))
		return
	var/message = tgui_input_text(owner, "Enter a message to telepathically transmit to [target]", "Holoparasite Telepathy", timeout = ability.can_respond_until[target] - world.time)
	if(!length(message))
		return
	ability.telepathy(target, message, sanitize = FALSE) // sanitize is FALSE as tgui_input_text already handles that

/atom/movable/screen/holoparasite/telepathy/should_be_transparent()
	return ..() || !length(ability.potential_targets)
