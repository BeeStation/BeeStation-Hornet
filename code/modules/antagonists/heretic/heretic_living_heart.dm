/**
 * # Living Heart Component
 *
 * Applied to a heart to turn it into a heretic's 'living heart'.
 * The living heart is what they use to track people they need to sacrifice.
 *
 * This component handles the action associated with it -
 * if the organ is removed, the action should be deleted
 */
/datum/component/living_heart
	/// The action we create and give to our heart.
	var/datum/action/track_target/action

/datum/component/living_heart/Initialize()
	if(!isorgan(parent))
		return COMPONENT_INCOMPATIBLE

	var/obj/item/organ/organ_parent = parent
	action = new(src)

	action = new(organ_parent)
	action.Grant(organ_parent.owner)

/datum/component/living_heart/Destroy(force, silent)
	QDEL_NULL(action)
	return ..()

/datum/component/living_heart/RegisterWithParent()
	ADD_TRAIT(parent, TRAIT_LIVING_HEART, REF(src))
	RegisterSignal(parent, COMSIG_ORGAN_REMOVED, PROC_REF(on_organ_removed))
	RegisterSignal(parent, COMSIG_ORGAN_BEING_REPLACED, PROC_REF(on_organ_replaced))

/datum/component/living_heart/UnregisterFromParent()
	REMOVE_TRAIT(parent, TRAIT_LIVING_HEART, REF(src))
	UnregisterSignal(parent, list(COMSIG_ORGAN_REMOVED, COMSIG_ORGAN_BEING_REPLACED))

/datum/component/living_heart/PostTransfer()
	if(!isorgan(parent))
		return COMPONENT_INCOMPATIBLE

/**
 * Signal proc for [COMSIG_CARBON_LOSE_ORGAN].
 *
 * If the organ is removed, the component will remove itself.
 */
/datum/component/living_heart/proc/on_organ_removed(obj/item/organ/source, mob/living/carbon/old_owner)
	SIGNAL_HANDLER

	to_chat(old_owner, span_userdanger("As your living [source.name] leaves your body, you feel less connected to the Mansus!"))
	qdel(src)

/**
 * Signal proc for [COMSIG_ORGAN_BEING_REPLACED].
 *
 * If the organ is replaced, before it's done transfer the component over
 */
/datum/component/living_heart/proc/on_organ_replaced(obj/item/organ/source, obj/item/organ/replacement)
	SIGNAL_HANDLER

	if(IS_ROBOTIC_ORGAN(replacement))
		qdel(src)
		return

	replacement.TakeComponent(src)

/*
 * The action associated with the living heart.
 * Allows a heretic to track sacrifice targets.
 */
/datum/action/track_target
	name = "Living Heartbeat"
	desc = "LMB: Chose one of your sacrifice targets to track. RMB: Repeats last target you chose to track."
	check_flags = AB_CHECK_CONSCIOUS
	background_icon_state = "bg_heretic"
	button_icon = 'icons/obj/heretic.dmi'
	button_icon_state = "living_heart"
	cooldown_time = 4 SECONDS

	/// Tracks whether we were right clicked or left clicked in our last trigger
	var/right_clicked = FALSE
	/// The real name of the last mob we tracked
	var/last_tracked_name
	/// Whether the target radial is currently opened.
	var/radial_open = FALSE

/datum/action/track_target/Grant(mob/granted)
	if(!IS_HERETIC(granted))
		return
	return ..()

/datum/action/track_target/is_available()
	. = ..()
	if(!.)
		return
	if(!IS_HERETIC(owner))
		return FALSE
	if(radial_open)
		return FALSE

	return TRUE

/*
/datum/action/track_target/trigger(trigger_flags)
	right_clicked = !!(trigger_flags & TRIGGER_SECONDARY_ACTION)
	return ..()
*/

/datum/action/track_target/on_activate(mob/user, atom/target)
	var/datum/antagonist/heretic/heretic_datum = IS_HERETIC(owner)
	var/datum/heretic_knowledge/sac_knowledge = heretic_datum.get_knowledge(/datum/heretic_knowledge/hunt_and_sacrifice)
	if(!LAZYLEN(heretic_datum.sac_targets))
		owner.balloon_alert(owner, "No targets, visit a rune")
		start_cooldown(1 SECONDS)
		return TRUE

	var/list/targets_to_choose = list()
	var/list/mob/living/carbon/tracked_targets = list()
	for(var/datum/weakref/target_ref as anything in heretic_datum.sac_targets)
		var/datum/mind/target_mind = target_ref.resolve()
		if(!istype(target_mind) || !iscarbon(target_mind.current))
			continue
		tracked_targets[target_mind.name] = target_mind.current
		targets_to_choose[target_mind.name] = heretic_datum.sac_targets[target_ref]

	// If we don't have a last tracked name, open a radial to set one.
	// If we DO have a last tracked name, we skip the radial if they right click the action.
	if(isnull(last_tracked_name) || !right_clicked)
		radial_open = TRUE
		last_tracked_name = show_radial_menu(
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
	if(isnull(last_tracked_name))
		return FALSE

	var/mob/living/carbon/tracked_mob = tracked_targets[last_tracked_name]
	if(QDELETED(tracked_mob))
		last_tracked_name = null
		return FALSE
	. = track_sacrifice_target(tracked_mob)

	if(.)
		playsound(owner, 'sound/effects/singlebeat.ogg', vol = 50, vary = TRUE, extrarange = SILENCED_SOUND_EXTRARANGE)

	// Let them know how to sacrifice people if they're able to be sac'd
	if(tracked_mob.stat == DEAD)
		to_chat(owner, span_hierophant("[tracked_mob] is dead. Bring them to a transmutation rune \
			and invoke \"[sac_knowledge.name]\" to sacrifice them!"))

	start_cooldown()

/datum/action/track_target/proc/track_sacrifice_target(mob/living/carbon/tracked)
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

/datum/action/track_target/proc/distance_hint(turf/source, turf/target)
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
/datum/action/track_target/proc/check_menu()
	if(QDELETED(src))
		return FALSE
	if(!IS_HERETIC(owner))
		return FALSE
	return TRUE
