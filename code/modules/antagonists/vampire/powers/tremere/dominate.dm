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
	check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_IN_FRENZY | BP_CANT_USE_WHILE_UNCONSCIOUS | BP_CANT_USE_DURING_SOL
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

/datum/action/vampire/targeted/tremere/dominate/advanced
	name = "Level 4: Possession"
	upgraded_power = /datum/action/vampire/targeted/tremere/dominate/advanced/two
	level_current = 4
	desc = "Mesmerize, mute and blind any foe who stands still long enough, or convert the damaged to temporary Vassals."
	power_explanation = "Click any person to mesmerize them after 4 seconds.\n\
		This will completely immobilize, mute, and blind them for the next 15 seconds.\n\
		Additionally, if you are adjacent to the target, and they are in critical condition or dead, they will be turned into a temporary mute vassal.\n\
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
		This will completely immobilize, mute, and blind them for the next 17 seconds.\n\
		Additionally, if you are adjacent to the target, and they are in critical condition or dead, they will be turned into a temporary mute vassal.\n\
		After 8 minutes, they will die.\n\
		If you use this on a dead Vassal, you will revive them."
	bloodcost = 100
	cooldown_time = 2 MINUTES

/datum/action/vampire/targeted/tremere/dominate/check_valid_target(atom/target_atom)
	. = ..()
	if(!.)
		return FALSE

	// Must be a carbon or silicon
	if(!iscarbon(target_atom) && !issilicon(target_atom))
		return FALSE
	var/mob/living/living_target = target_atom

	// Has to have a mind
	if(!living_target.mind)
		living_target.balloon_alert(owner, "[living_target] is mindless.")
		return FALSE

/datum/action/vampire/targeted/tremere/dominate/advanced/check_valid_target(atom/target_atom)
	. = ..()
	if(!.)
		return FALSE

	// Check range
	var/mob/living/living_target = target_atom
	if(living_target.stat >= SOFT_CRIT && !owner.Adjacent(living_target))
		living_target.balloon_alert(owner, "out of range.")
		return FALSE

/datum/action/vampire/targeted/tremere/dominate/FireTargetedPower(atom/target_atom)
	. = ..()
	var/mob/living/living_target = target_atom

	if(living_target.stat >= SOFT_CRIT && owner.Adjacent(living_target) && level_current >= 4)
		attempt_vassalize(living_target)
	else if(living_target.stat == CONSCIOUS)
		attempt_mesmerize(living_target)

/datum/action/vampire/targeted/tremere/dominate/proc/attempt_mesmerize(mob/living/living_target)
	owner.balloon_alert(owner, "attempting to mesmerize.")
	if(!do_after(owner, 4 SECONDS, living_target, hidden = TRUE))
		return

	power_activated_sucessfully()
	var/power_time = 9 SECONDS + level_current * 1.5 SECONDS
	if(IS_CURATOR(living_target))
		to_chat(living_target, span_notice("You feel you something crawling under your skin, but it passes."))
		return
	if(HAS_TRAIT_FROM(living_target, TRAIT_MUTE, TRAIT_MESMERIZED))
		owner.balloon_alert(owner, "[living_target] is already in some form of hypnotic gaze.")
		return

	if(iscarbon(living_target))
		var/mob/living/carbon/carbon_target = living_target
		owner.balloon_alert(owner, "successfully mesmerized [carbon_target].")
		if(level_current >= 2)
			ADD_TRAIT(living_target, TRAIT_MUTE, TRAIT_MESMERIZED)
		if(level_current >= 3)
			living_target.become_blind(TRAIT_MESMERIZED)

		carbon_target.Immobilize(power_time)
		carbon_target.next_move = world.time + power_time
		carbon_target.notransform = TRUE
		addtimer(CALLBACK(src, PROC_REF(end_mesmerize), living_target, owner), power_time)

	if(issilicon(living_target))
		var/mob/living/silicon/silicon_target = living_target
		silicon_target.emp_act(EMP_HEAVY)
		owner.balloon_alert(owner, "temporarily shut [silicon_target] down.")

/datum/action/vampire/targeted/tremere/proc/end_mesmerize(mob/living/living_target)
	living_target.notransform = FALSE
	living_target.cure_blind(TRAIT_MESMERIZED)
	REMOVE_TRAIT(living_target, TRAIT_MUTE, TRAIT_MESMERIZED)

	if(living_target in view(6, get_turf(owner)))
		living_target.balloon_alert(owner, "snapped out of [living_target.p_their()] trance!")

/datum/action/vampire/targeted/tremere/dominate/proc/attempt_vassalize(mob/living/living_target)
	var/datum/antagonist/vassal/vassaldatum = IS_VASSAL(living_target)

	living_target.balloon_alert(owner, "attempting to revive.")
	if(!do_after(owner, 6 SECONDS, living_target))
		return

	if(vassaldatum)
		power_activated_sucessfully()
		living_target.balloon_alert(owner, "revived [living_target]!")
		living_target.mind.grab_ghost()
		living_target.revive(HEAL_ALL)
		return

	if(IS_CURATOR(living_target))
		living_target.balloon_alert(owner, "[living_target.p_their()] body refuses to rise.")
		return

	if(!vampiredatum_power.can_make_vassal(living_target, ignore_concious_check = TRUE))
		return

	vampiredatum_power.make_vassal(living_target)
	power_activated_sucessfully()

	living_target.mind.grab_ghost()
	living_target.revive(HEAL_ALL)

	vassaldatum = IS_VASSAL(living_target)
	vassaldatum.special_type = TREMERE_VASSAL //don't turn them into a favorite please

	// You will die in 5 or 8 minutes
	var/time_to_live
	if(level_current == 4)
		time_to_live = 5 MINUTES
		living_target.add_traits(list(TRAIT_MUTE, TRAIT_DEAF), TRAIT_MESMERIZED)
	else if(level_current >= 5)
		time_to_live = 8 MINUTES

	addtimer(CALLBACK(src, PROC_REF(end_possession), living_target), time_to_live)

	// Give alerts
	to_chat(living_target, span_userdanger("You have been revived as a temporary vassal! You will perish in [DisplayTimeText(time_to_live)]"))
	living_target.balloon_alert(owner, "revived [living_target]!")

/datum/action/vampire/targeted/tremere/proc/end_possession(mob/living/target)
	target.remove_traits(list(TRAIT_MUTE, TRAIT_DEAF), TRAIT_MESMERIZED)
	target.mind.remove_antag_datum(/datum/antagonist/vassal)
	to_chat(target, span_userdanger("You feel the Blood of your Master run out!"))
	target.death()
