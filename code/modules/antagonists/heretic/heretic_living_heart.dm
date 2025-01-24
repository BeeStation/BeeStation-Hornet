/**
 * # Living Heart Component
 *
 * Applied to a heart to turn it into a heretic's 'living heart'.
 * The living heart is what they use to track people they need to sacrifice.
 *
 * This component handles adding the associated action, as well as updating the heart's icon.
 *
 * Must be attached to an organ located within a heretic.
 * If removed from the body of a heretic, it will self-delete and become a normal heart again.
 */
/datum/component/living_heart
	/// The action we create and give to our heart.
	var/datum/action/item_action/organ_action/track_target/action
	/// The icon of the heart before we made it a living heart.
	var/old_icon
	/// The icon_state of the heart before we made it a living heart.
	var/old_icon_state

/datum/component/living_heart/Initialize()
	if(!isorgan(parent))
		return COMPONENT_INCOMPATIBLE

	var/obj/item/organ/organ_parent = parent
	if(organ_parent.status != ORGAN_ORGANIC || (organ_parent.organ_flags & ORGAN_SYNTHETIC))
		return COMPONENT_INCOMPATIBLE

	if(!IS_HERETIC(organ_parent.owner))
		return COMPONENT_INCOMPATIBLE

	action = new(organ_parent)
	action.Grant(organ_parent.owner)

	ADD_TRAIT(parent, TRAIT_LIVING_HEART, REF(src))
	RegisterSignal(parent, COMSIG_CARBON_LOSE_ORGAN, PROC_REF(on_organ_removed))

	old_icon = organ_parent.icon
	old_icon_state = organ_parent.icon_state

	organ_parent.icon = 'icons/obj/heretic.dmi'
	organ_parent.icon_state = "living_heart"
	action.UpdateButtonIcon()

/datum/component/living_heart/Destroy(force, silent)
	QDEL_NULL(action)
	REMOVE_TRAIT(parent, TRAIT_LIVING_HEART, REF(src))
	UnregisterSignal(parent, COMSIG_CARBON_LOSE_ORGAN)

	var/obj/item/organ/organ_parent = parent
	organ_parent.icon = old_icon
	organ_parent.icon_state = old_icon_state

	return ..()

/**
 * Signal proc for [COMSIG_CARBON_LOSE_ORGAN].
 *
 * If the organ is removed, the component will remove itself.
 */
/datum/component/living_heart/proc/on_organ_removed(obj/item/organ/source, mob/living/carbon/old_owner)
	SIGNAL_HANDLER

	to_chat(old_owner, "<span class='userdanger'>As your living [source.name] leaves your body, you feel less connected to the Mansus!</span>")
	qdel(src)

/*
 * The action associated with the living heart.
 * Allows a heretic to track sacrifice targets.
 */
/datum/action/item_action/organ_action/track_target
	name = "Living Heartbeat"
	desc = "Track a Sacrifice Target"
	check_flags = AB_CHECK_CONSCIOUS
	background_icon_state = "bg_ecult"
	/// Whether the target radial is currently opened.
	var/radial_open = FALSE
	/// How long we have to wait between tracking uses.
	var/track_cooldown_length = 8 SECONDS
	/// The cooldown between button uses.
	COOLDOWN_DECLARE(track_cooldown)

/datum/action/item_action/organ_action/track_target/Grant(mob/granted)
	if(!IS_HERETIC(granted))
		return
	return ..()

/datum/action/item_action/organ_action/track_target/IsAvailable()
	. = ..()
	if(!.)
		return
	if(!IS_HERETIC(owner))
		return FALSE
	if(!HAS_TRAIT(target, TRAIT_LIVING_HEART))
		return FALSE
	if(!COOLDOWN_FINISHED(src, track_cooldown))
		return FALSE
	if(radial_open)
		return FALSE

/datum/action/item_action/organ_action/track_target/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return

	var/datum/antagonist/heretic/heretic_datum = IS_HERETIC(owner)
	if(!LAZYLEN(heretic_datum.sac_targets))
		owner.balloon_alert(owner, "No targets, visit a rune")
		return TRUE

	var/list/targets_to_choose = list()
	var/list/mob/living/carbon/tracked_targets = list()
	for(var/datum/weakref/target_ref as anything in heretic_datum.sac_targets)
		var/datum/mind/target_mind = target_ref.resolve()
		if(!istype(target_mind) || !iscarbon(target_mind.current))
			continue
		tracked_targets[target_mind.name] = target_mind.current
		targets_to_choose[target_mind.name] = heretic_datum.sac_targets[target_ref]

	radial_open = TRUE
	var/tracked = show_radial_menu(
		owner,
		owner,
		targets_to_choose,
		custom_check = CALLBACK(src, PROC_REF(check_menu)),
		radius = 40,
		require_near = TRUE,
		tooltips = TRUE,
	)
	radial_open = FALSE
	// If our last tracked name is still null, skip the trigger
	if(isnull(tracked))
		return FALSE

	var/mob/living/carbon/tracked_mob = tracked_targets[tracked]
	if(QDELETED(tracked_mob))
		return FALSE
	. = track_sacrifice_target(tracked_mob)

	if(.)
		COOLDOWN_START(src, track_cooldown, track_cooldown_length)
		playsound(owner, 'sound/effects/singlebeat.ogg', vol = 50, vary = TRUE, extrarange = SILENCED_SOUND_EXTRARANGE)

/datum/action/item_action/organ_action/track_target/proc/track_sacrifice_target(mob/living/carbon/tracked)
	var/turf/owner_turf = get_turf(owner)
	var/turf/tracked_turf = get_turf(tracked)
	var/balloon_message = "Your target is "
	if(tracked.stat == DEAD)
		balloon_message += "dead and "
	else if(!tracked.ckey)
		balloon_message += "catatonic and "
	if(owner_turf.get_virtual_z_level() != tracked_turf.get_virtual_z_level())
		if(is_reserved_level(tracked_turf.z))
			balloon_message += "traveling through space"
		else
			balloon_message += "on another plane"
	else
		balloon_message += distance_hint(owner_turf, tracked_turf)
	owner.balloon_alert(owner, balloon_message)
	return TRUE

/datum/action/item_action/organ_action/track_target/proc/distance_hint(turf/source, turf/target)
	var/dist = get_dist(source, target)
	var/dir = get_dir(source, target)
	switch(dist)
		if(0 to 15)
			return "very near, [dir2text(dir)]"
		if(16 to 31)
			return "near, [dir2text(dir)]"
		if(32 to 127)
			return "far away, [dir2text(dir)]"
		else
			return "very far away"

/// Callback for the radial to ensure it's closed when not allowed.
/datum/action/item_action/organ_action/track_target/proc/check_menu()
	if(QDELETED(src))
		return FALSE
	if(!IS_HERETIC(owner))
		return FALSE
	if(!HAS_TRAIT(target, TRAIT_LIVING_HEART))
		return FALSE
	return TRUE
