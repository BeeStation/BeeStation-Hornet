/**
 *	FORCE OF PERSONALITY
 *	Like Awe, but instead of attracting people, it creates an aura where people
 *	periodically take a step away from the caster. Not a revulsion - more of an
 *	"I don't deserve to breathe their air" effect.
 *	People can still approach if they want to.
 */
/datum/action/vampire/force_of_personality
	name = "Force of Personality"
	desc = "Project an overwhelming aura of authority that causes those around you to involuntarily step back."
	button_icon_state = "power_awe" // Uses awe icon as a placeholder
	power_explanation = "Project an aura around yourself that subtly pushes people away.\n\
						Effects on those in your aura:\n\
						- They occasionally step away from you involuntarily.\n\
						- They feel unworthy of being in your presence.\n\
						- They can still approach you, but will periodically be pushed back.\n\
						Targets must be able to see you to be affected."
	power_flags = BP_AM_TOGGLE | BP_AM_STATIC_COOLDOWN
	check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_WHILE_STAKED | BP_CANT_USE_IN_FRENZY
	vitaecost = 30
	constant_vitaecost = 2
	cooldown_time = 10 SECONDS
	/// The range of the aura in tiles
	var/aura_range = 5

/datum/action/vampire/force_of_personality/activate_power()
	. = ..()
	to_chat(owner, span_notice("You project an overwhelming sense of authority."), type = MESSAGE_TYPE_INFO)

/datum/action/vampire/force_of_personality/deactivate_power()
	. = ..()
	to_chat(owner, span_notice("You withdraw your authoritative presence."), type = MESSAGE_TYPE_INFO)

/datum/action/vampire/force_of_personality/UsePower()
	. = ..()
	for(var/mob/living/victim in oviewers(aura_range, owner))
		if(!can_affect(victim))
			continue
		// Apply or refresh the intimidated status effect
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
	if(IS_VAMPIRE(victim) || IS_VASSAL(victim) || IS_CURATOR(victim))
		return FALSE
	return TRUE

/// Status effect for being affected by Force of Personality
/datum/status_effect/intimidated
	id = "intimidated"
	status_type = STATUS_EFFECT_UNIQUE
	duration = 4 SECONDS
	tick_interval = 1 SECONDS
	alert_type = null
	/// The vampire projecting the aura
	var/mob/living/source_vampire
	COOLDOWN_DECLARE(intimidation_effect_cooldown)

/datum/status_effect/intimidated/on_creation(mob/living/new_owner, mob/living/vampire)
	source_vampire = vampire
	return ..()

/datum/status_effect/intimidated/Destroy()
	source_vampire = null
	return ..()

/datum/status_effect/intimidated/on_apply()
	if(!iscarbon(owner))
		return FALSE
	return TRUE

/datum/status_effect/intimidated/on_remove()
	return

/datum/status_effect/intimidated/refresh()
	duration = world.time + initial(duration)

/datum/status_effect/intimidated/tick(seconds_between_ticks)
	if(QDELETED(source_vampire) || source_vampire.stat == DEAD)
		qdel(src)
		return

	if(owner.incapacitated(IGNORE_RESTRAINTS))
		return

	if(COOLDOWN_FINISHED(src, intimidation_effect_cooldown))
		COOLDOWN_START(src, intimidation_effect_cooldown, 3 SECONDS)

		// Pick a random effect - mostly stepping away
		switch(rand(1, 5))
			// Mild unease
			if(1)
				to_chat(owner, span_awe("You feel unworthy of standing so close to them..."))
			// Step away
			if(2, 3)
				if(owner.body_position == STANDING_UP)
					var/away_dir = get_dir(source_vampire.loc, owner.loc)
					var/turf/retreat_turf = get_step(owner.loc, away_dir)
					// Make sure we're not stepping into the vampire or into a wall
					if(retreat_turf && retreat_turf != source_vampire.loc && !retreat_turf.is_blocked_turf())
						owner.visible_message(span_warning("[owner] takes an involuntary step back."), span_awe("You instinctively step back, feeling unworthy of their presence..."))
						owner.Move(retreat_turf, away_dir)
			// Bow/look down
			if(4)
				owner.face_atom(source_vampire)
				to_chat(owner, span_awe("You can barely bring yourself to look at them..."))
			// Stammering/feeling small
			if(5)
				owner.face_atom(source_vampire)
				owner.set_jitter_if_lower(2 SECONDS)
				to_chat(owner, span_awe("You feel so small in their presence..."))

/datum/status_effect/intimidated/get_examine_text()
	return span_warning("[owner.p_They()] seem[owner.p_s()] intimidated and keeps backing away from something.")
