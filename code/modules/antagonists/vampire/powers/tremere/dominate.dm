/**
 *	# Dominate;
 *
 *	Level 1 - Mesmerizes target
 *	Level 2 - Mesmerizes and mutes target
 *	Level 3 - Mesmerizes, blinds and mutes target
 *	Level 4 - Target (if at least in crit & has a mind) will revive as a Mute/Deaf Vassal for 5 minutes before dying.
 *	Level 5 - Target (if at least in crit & has a mind) will revive as a Vassal for 8 minutes before dying.
 */

// Copied from mesmerize.dm

/datum/action/vampire/targeted/tremere/dominate
	name = "Level 1: Dominate"
	upgraded_power = /datum/action/vampire/targeted/tremere/dominate/two
	level_current = 1
	desc = "Mesmerize any foe who stands still long enough."
	button_icon_state = "power_dominate"
	power_explanation = "Click any person to mesmerize them after 4 seconds.\n\
		This will completely immobilize them for the next 10 seconds."
	check_flags = BP_CANT_USE_IN_TORPOR|BP_CANT_USE_IN_FRENZY|BP_CANT_USE_WHILE_UNCONSCIOUS|BP_CANT_USE_DURING_SOL
	bloodcost = 15
	constant_bloodcost = 2
	cooldown_time = 50 SECONDS
	target_range = 6
	prefire_message = "Select a target."

/datum/action/vampire/targeted/tremere/dominate/two
	name = "Level 2: Dominate"
	upgraded_power = /datum/action/vampire/targeted/tremere/dominate/three
	level_current = 2
	desc = "Mesmerize and mute any foe who stands still long enough."
	power_explanation = "Click any person to mesmerize them after 4 seconds.\n\
		This will completely immobilize and mute them for the next 12 seconds."
	bloodcost = 20
	cooldown_time = 40 SECONDS

/datum/action/vampire/targeted/tremere/dominate/three
	name = "Level 3: Dominate"
	upgraded_power = /datum/action/vampire/targeted/tremere/dominate/advanced
	level_current = 3
	desc = "Mesmerize, mute and blind any foe who stands still long enough."
	power_explanation = "Click any person to mesmerize them after 4 seconds.\n\
		This will completely immobilize, mute, and blind them for the next 14 seconds."
	bloodcost = 30
	cooldown_time = 35 SECONDS

/datum/action/vampire/targeted/tremere/dominate/check_valid_target(atom/target_atom)
	. = ..()
	if(!.)
		return FALSE

	// Has to be alive
	if(!isliving(target_atom))
		return FALSE
	// Has to have a mind
	var/mob/living/selected_target = target_atom
	if(!selected_target.mind)
		owner.balloon_alert(owner, "[selected_target] is mindless.")
		return FALSE

/datum/action/vampire/targeted/tremere/dominate/advanced
	name = "Level 4: Possession"
	upgraded_power = /datum/action/vampire/targeted/tremere/dominate/advanced/two
	level_current = 4
	desc = "Mesmerize, mute and blind any foe who stands still long enough, or convert the damaged to temporary Vassals."
	power_explanation = "Click any person to mesmerize them after 4 seconds.\n\
		This will completely immobilize, mute, and blind them for the next 14 seconds.\n\
		However, if you are adjacent to the target, and they are in critical condition or dead, they will be turned into a temporary mute Vassal.\n\
		After 5 minutes, they will die.\n\
		If you use this on a dead Vassal, you will revive them."
	background_icon_state = "tremere_power_gold_off"
	background_icon_state_on = "tremere_power_gold_on"
	background_icon_state_off = "tremere_power_gold_off"
	bloodcost = 80
	cooldown_time = 3 MINUTES

/datum/action/vampire/targeted/tremere/dominate/advanced/two
	name = "Level 5: Possession"
	desc = "Mesmerize, mute and blind any foe who stands still long enough, or convert the damaged to temporary Vassals."
	level_current = 5
	upgraded_power = null
	power_explanation = "Click any person to mesmerize them after 4 seconds.\n\
		This will completely immobilize, mute, and blind them for the next 14 seconds.\n\
		However, if you are adjacent to the target, and they are in critical condition or dead, they will be turned into a temporary mute Vassal.\n\
		After 8 minutes, they will die.\n\
		If you use this on a dead Vassal, you will revive them."
	bloodcost = 100
	cooldown_time = 2 MINUTES

// The advanced version
/datum/action/vampire/targeted/tremere/dominate/advanced/check_valid_target(atom/target_atom)
	. = ..()
	if(!.)
		return FALSE

	// Check range
	var/mob/living/selected_target = target_atom
	if((IS_VASSAL(selected_target) || selected_target.stat >= SOFT_CRIT) && !owner.Adjacent(selected_target))
		owner.balloon_alert(owner, "out of range.")
		return FALSE
	return TRUE

/datum/action/vampire/targeted/tremere/dominate/FireTargetedPower(atom/target_atom)
	. = ..()
	var/mob/living/target = target_atom
	var/mob/living/user = owner
	if(target.stat >= SOFT_CRIT && user.Adjacent(target) && level_current >= 4)
		attempt_vassalize(target, user)
		return
	else if(IS_VASSAL(target))
		owner.balloon_alert(owner, "vassal cant be revived")
		return
	attempt_mesmerize(target, user)

/datum/action/vampire/targeted/tremere/dominate/proc/attempt_mesmerize(mob/living/target, mob/living/user)
	owner.balloon_alert(owner, "attempting to mesmerize.")
	if(!do_after(user, 3 SECONDS, target, NONE, TRUE, hidden = TRUE))
		return

	power_activated_sucessfully()
	var/power_time = 90 + level_current * 15
	if(IS_CURATOR(target))
		to_chat(target, span_notice("You feel you something crawling under your skin, but it passes."))
		return
	if(HAS_TRAIT_FROM(target, TRAIT_MUTE, TRAIT_VAMPIRE))
		owner.balloon_alert(owner, "[target] is already in some form of hypnotic gaze.")
		return
	if(iscarbon(target))
		var/mob/living/carbon/mesmerized = target
		owner.balloon_alert(owner, "successfully mesmerized [mesmerized].")
		if(level_current >= 2)
			ADD_TRAIT(target, TRAIT_MUTE, TRAIT_VAMPIRE)
		if(level_current >= 3)
			target.become_blind(TRAIT_VAMPIRE)
		mesmerized.Immobilize(power_time)
		mesmerized.next_move = world.time + power_time
		mesmerized.notransform = TRUE
		addtimer(CALLBACK(src, PROC_REF(end_mesmerize), user, target), power_time)
	if(issilicon(target))
		var/mob/living/silicon/mesmerized = target
		mesmerized.emp_act(EMP_HEAVY)
		owner.balloon_alert(owner, "temporarily shut [mesmerized] down.")

/datum/action/vampire/targeted/tremere/proc/end_mesmerize(mob/living/user, mob/living/target)
	target.notransform = FALSE
	target.cure_blind(TRAIT_VAMPIRE)
	REMOVE_TRAIT(target, TRAIT_MUTE, TRAIT_VAMPIRE)
	if(istype(user) && target.stat == CONSCIOUS && (target in view(6, get_turf(user))))
		owner.balloon_alert(owner, "[target] snapped out of their trance.")

/datum/action/vampire/targeted/tremere/dominate/proc/attempt_vassalize(mob/living/target, mob/living/user)
	owner.balloon_alert(owner, "attempting to vassalize.")
	if(!do_after(user, 6 SECONDS, target, NONE, TRUE))
		return

	if(IS_VASSAL(target))
		power_activated_sucessfully()
		to_chat(user, span_warning("We revive [target]!"))
		target.mind.grab_ghost()
		target.revive(full_heal = TRUE)
		return
	if(IS_CURATOR(target))
		to_chat(target, "Their body refuses to react...")
		return
	if(!vampiredatum_power.can_make_vassal(target))
		return
	vampiredatum_power.make_vassal(target)
	power_activated_sucessfully()
	to_chat(user, span_warning("We revive [target]!"))
	target.mind.grab_ghost()
	target.revive(full_heal = TRUE)
	var/datum/antagonist/vassal/vassaldatum = target.mind.has_antag_datum(/datum/antagonist/vassal)
	vassaldatum.special_type = TREMERE_VASSAL //don't turn them into a favorite please
	var/living_time
	if(level_current == 4)
		living_time = 5 MINUTES
		ADD_TRAIT(target, TRAIT_MUTE, TRAIT_VAMPIRE)
		ADD_TRAIT(owner, TRAIT_DEAF, TRAIT_VAMPIRE)
	else if(level_current == 5)
		living_time = 8 MINUTES
	addtimer(CALLBACK(src, PROC_REF(end_possession), target), living_time)

/datum/action/vampire/targeted/tremere/proc/end_possession(mob/living/user)
	REMOVE_TRAIT(user, TRAIT_MUTE, TRAIT_VAMPIRE)
	REMOVE_TRAIT(user, TRAIT_DEAF, TRAIT_VAMPIRE)
	user.mind.remove_antag_datum(/datum/antagonist/vassal)
	to_chat(user, span_warning("You feel the Blood of your Master run out!"))
	user.death()
