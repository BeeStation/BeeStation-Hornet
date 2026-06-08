/datum/action/vampire/force_of_personality
	name = "Force of Personality"
	desc = "Project an overwhelming aura of authority that prevents those around you from bringing themselves to approach."
	button_icon_state = "power_fop"
	power_explanation = "Project an aura around yourself that stops people from approaching you.\n\
						Those within 3 tiles will be unable to step any closer to you, and will back away if you close in on them.\n\
						Targets must be able to see you to be affected."
	power_flags = BP_AM_TOGGLE | BP_AM_STATIC_COOLDOWN
	check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_WHILE_STAKED | BP_CANT_USE_IN_FRENZY
	vitaecost = 20
	constant_vitaecost = 1
	cooldown_time = 10 SECONDS
	/// The range of the aura in tiles, this is further than the actual effect just so we can hit them with the status effect before they even get close enough.
	var/aura_range = 7

/datum/action/vampire/force_of_personality/activate_power()
	. = ..()
	to_chat(owner, span_notice("You project an overwhelming sense of authority."), type = MESSAGE_TYPE_INFO)

/datum/action/vampire/force_of_personality/deactivate_power()
	. = ..()
	to_chat(owner, span_notice("You withdraw your authoritative presence."), type = MESSAGE_TYPE_INFO)

/datum/action/vampire/force_of_personality/use_power()
	. = ..()
	for(var/mob/living/victim in oviewers(aura_range, owner))
		if(!can_affect(victim))
			continue
		if(!victim.has_status_effect(/datum/status_effect/intimidated))
			victim.apply_status_effect(/datum/status_effect/intimidated, owner)
		else
			var/datum/status_effect/intimidated/existing = victim.has_status_effect(/datum/status_effect/intimidated)
			existing.refresh()

/// Checks if this victim can be affected by the force of personality aura
/datum/action/vampire/force_of_personality/proc/can_affect(mob/living/victim)
	if(!victim.client)
		return FALSE
	if(victim.has_unlimited_silicon_privilege)
		return FALSE
	if(victim.stat != CONSCIOUS)
		return FALSE
	if(victim.is_blind() || HAS_TRAIT(victim, TRAIT_NEARSIGHT))
		return FALSE
	if(HAS_MIND_TRAIT(victim, TRAIT_VAMPIRE_ALIGNED) || IS_CURATOR(victim))
		return FALSE
	return TRUE

/// Status effect for being affected by Force of Personality
/datum/status_effect/intimidated
	id = "intimidated"
	status_type = STATUS_EFFECT_UNIQUE
	duration = 10 SECONDS
	tick_interval = 0.2 SECONDS
	alert_type = null
	/// The vampire projecting the aura
	var/mob/living/source_vampire
	/// The range at which the effect triggers
	var/trigger_range = 3
	COOLDOWN_DECLARE(message_cooldown)

/datum/status_effect/intimidated/on_creation(mob/living/new_owner, mob/living/vampire, datum/action/vampire/force_of_personality/power)
	source_vampire = vampire
	return ..()

/datum/status_effect/intimidated/Destroy()
	source_vampire = null
	return ..()

/datum/status_effect/intimidated/on_apply()
	if(!iscarbon(owner))
		return FALSE
	RegisterSignal(owner, COMSIG_MOB_CLIENT_PRE_MOVE, PROC_REF(block_approach))
	return TRUE

/datum/status_effect/intimidated/on_remove()
	UnregisterSignal(owner, COMSIG_MOB_CLIENT_PRE_MOVE)

/// Vetoes any player-driven move that would carry the owner into (or keep them
/// inside) the vampire's inner ring. Lateral and outward moves are allowed so
/// the victim isn't fully frozen, only barred from approaching.
/datum/status_effect/intimidated/proc/block_approach(datum/source, list/move_args)
	SIGNAL_HANDLER

	if(QDELETED(source_vampire))
		return

	var/atom/new_loc = move_args[MOVE_ARG_NEW_LOC]
	if(!new_loc)
		return

	// Distance from the tile they want to enter to the caster
	if(get_dist(new_loc, source_vampire) >= trigger_range)
		return

	// Block if this move would take them closer to (or no further from) the vampire
	if(get_dist(get_turf(source), source_vampire) < get_dist(new_loc, source_vampire))
		return

	if(COOLDOWN_FINISHED(src, message_cooldown))
		COOLDOWN_START(src, message_cooldown, 3 SECONDS)
		to_chat(owner, span_awe("You don't dare approach them..."))

	return COMSIG_MOB_CLIENT_BLOCK_PRE_MOVE

/datum/status_effect/intimidated/tick(seconds_between_ticks)
	if(QDELETED(source_vampire) || source_vampire.stat == DEAD)
		qdel(src)
		return

	if(INCAPACITATED_IGNORING(owner, INCAPABLE_RESTRAINTS))
		return

	if(get_dist(owner, source_vampire) >= trigger_range)
		return

	// Step away from the vampire
	if(owner.body_position == STANDING_UP)
		var/away_dir = get_dir(source_vampire.loc, owner.loc)
		var/turf/retreat_turf = get_step(owner.loc, away_dir)
		// Make sure we're not stepping into the vampire or into a wall
		if(retreat_turf && !retreat_turf.is_blocked_turf())
			if(COOLDOWN_FINISHED(src, message_cooldown))
				COOLDOWN_START(src, message_cooldown, 3 SECONDS)
				owner.visible_message(span_warning("[owner] takes a hurried step back."), span_awe("You don't dare approach them..."))
			owner.Move(retreat_turf, away_dir)

/datum/status_effect/intimidated/get_examine_text()
	return span_warning("[owner.p_They()] seem[owner.p_s()] intimidated.")
