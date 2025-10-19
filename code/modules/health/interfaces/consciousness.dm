// Consciousness level
#define TRAIT_CONSCIOUSNESS_LEVEL "consciousness_level"

/datum/consciousness
	/// The owner of the consciousness datum
	var/mob/living/owner
	/// The current consciousness value
	var/value = 0
	/// The maximum consciousnessvalue
	var/max_value = 100

/datum/consciousness/New(mob/living/owner)
	. = ..()
	src.owner = owner
	register_signals(owner)

/// Register signals on the owner
/datum/consciousness/proc/register_signals(mob/living/owner)
	SHOULD_CALL_PARENT(TRUE)
	RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_IGNOREDAMAGESLOWDOWN), PROC_REF(update_movespeed))
	RegisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_IGNOREDAMAGESLOWDOWN), PROC_REF(update_movespeed))
	RegisterSignal(owner, COMSIG_LIVING_HEALTH_UPDATE, PROC_REF(update_stat))

/// Called every life tick
/datum/consciousness/proc/consciousness_tick(delta_time)

/// Called when consciousness value is updated
/datum/consciousness/proc/update_consciousness(consciousness_value)
	SHOULD_CALL_PARENT(TRUE)
	value = consciousness_value
	update_movespeed()
	update_consciousness_overlay()
	update_death_overlay()
	owner.update_health_hud()
	owner.med_hud_set_health()

/datum/consciousness/proc/update_death_overlay()
	if(owner.stat >= SOFT_CRIT)
		var/severity = 0
		switch(value)
			if(-10 to 0)
				severity = 1
			if(-20 to -10)
				severity = 2
			if(-30 to -20)
				severity = 3
			if(-40 to -30)
				severity = 4
			if(-50 to -40)
				severity = 5
			if(-60 to -50)
				severity = 6
			if(-70 to -60)
				severity = 7
			if(-80 to -70)
				severity = 8
			if(-90 to -80)
				severity = 9
			if(-100 to -90)
				severity = 10
		owner.overlay_fullscreen("crit", /atom/movable/screen/fullscreen/crit, severity)
	else
		owner.clear_fullscreen("crit")
		owner.clear_fullscreen("critvision")

/datum/consciousness/proc/update_consciousness_overlay()
	//Oxygen damage overlay
	if(value < 95)
		var/severity = 0
		switch(value)
			if(20 to 50)
				severity = 1
			if(0 to 20)
				severity = 2
			if(-20 to 0)
				severity = 3
			if(-40 to -20)
				severity = 4
			if(-60 to -40)
				severity = 5
			if(-80 to -60)
				severity = 6
			if(-100 to -80)
				severity = 7
		owner.overlay_fullscreen("consciousness", /atom/movable/screen/fullscreen/oxy, severity)
	else
		owner.clear_fullscreen("consciousness")

/// Update the mob's move speed according to the consciousness value
/datum/consciousness/proc/update_movespeed()
	if(HAS_TRAIT(owner, TRAIT_IGNOREDAMAGESLOWDOWN))
		owner.remove_movespeed_modifier(/datum/movespeed_modifier/damage_slowdown)
		owner.remove_movespeed_modifier(/datum/movespeed_modifier/damage_slowdown_flying)
		return
	var/health_deficiency = max((max_value - value), owner.exhaustion)
	if(health_deficiency >= DAMAGE_SLOWDOWN_START)
		owner.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/damage_slowdown, TRUE, multiplicative_slowdown = (health_deficiency / 100) * DAMAGE_SLOWDOWN_CRIT)
		owner.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/damage_slowdown_flying, TRUE, multiplicative_slowdown = (health_deficiency / 100) * DAMAGE_SLOWDOWN_CRIT * DAMAGE_SLOWDOWN_FLYING_MULTIPLIER)
	else
		owner.remove_movespeed_modifier(/datum/movespeed_modifier/damage_slowdown)
		owner.remove_movespeed_modifier(/datum/movespeed_modifier/damage_slowdown_flying)

/// Trigger an update of the stat
/datum/consciousness/proc/update_stat()
	SIGNAL_HANDLER
	update_consciousness(GET_TRAIT_VALUE(src, TRAIT_CONSCIOUSNESS_LEVEL))

/// Provide a source of consciousness. Without one consciousness will be 0, which is dead.
/// Source: The source of the modifier
/// Amount: The amount of consciousness provided by the source.
/datum/consciousness/proc/set_consciousness_source(amount, source)
	if (!amount)
		REMOVE_TRAIT(src, TRAIT_CONSCIOUSNESS_LEVEL, source)
	else
		ADD_CUMULATIVE_TRAIT(src, TRAIT_CONSCIOUSNESS_LEVEL, source, amount)
	update_consciousness(GET_TRAIT_VALUE(src, TRAIT_CONSCIOUSNESS_LEVEL))

/// Set a consciousness modifier.
/// Source: The source of the modifier
/// Amount: The multiplier for the modifier, set to 1 to remove
/datum/consciousness/proc/set_consciousness_modifier(amount, source)
	if (amount == 1)
		REMOVE_TRAIT(src, TRAIT_CONSCIOUSNESS_LEVEL, source)
	else
		ADD_MULTIPLICATIVE_TRAIT(src, TRAIT_CONSCIOUSNESS_LEVEL, source, amount)
	update_consciousness(GET_TRAIT_VALUE(src, TRAIT_CONSCIOUSNESS_LEVEL))

#undef TRAIT_CONSCIOUSNESS_LEVEL
