// Consciousness level
#define TRAIT_CONSCIOUSNESS_LEVEL "consciousness_level"

/datum/consciousness
	/// The owner of the consciousness datum
	var/mob/living/owner

/datum/consciousness/New(mob/living/owner)
	. = ..()
	src.owner = owner
	register_signals(owner)

/// Register signals on the owner
/datum/consciousness/proc/register_signals(mob/living/owner)

/// Called every life tick
/datum/consciousness/proc/consciousness_tick(delta_time)

/// Called when consciousness value is updated
/datum/consciousness/proc/update_consciousness(consciousness_value)
	//Oxygen damage overlay
	if(consciousness_value < 95)
		var/severity = 0
		switch(consciousness_value)
			if(80 to 100)
				severity = 1
			if(70 to 80)
				severity = 2
			if(60 to 70)
				severity = 3
			if(50 to 60)
				severity = 4
			if(40 to 50)
				severity = 5
			if(20 to 40)
				severity = 6
			if(0 to 20)
				severity = 7
		owner.overlay_fullscreen("consciousness", /atom/movable/screen/fullscreen/oxy, severity)
	else
		owner.clear_fullscreen("consciousness")

	if(owner.stat >= SOFT_CRIT)
		var/severity = 0
		switch(consciousness_value)
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
