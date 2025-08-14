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
			if(90 to 95)
				severity = 1
			if(85 to 90)
				severity = 2
			if(80 to 85)
				severity = 3
			if(75 to 80)
				severity = 4
			if(70 to 75)
				severity = 5
			if(60 to 70)
				severity = 6
			if(0 to 60)
				severity = 7
		owner.overlay_fullscreen("consciousness", /atom/movable/screen/fullscreen/oxy, severity)
	else
		owner.clear_fullscreen("consciousness")

	if(owner.stat >= SOFT_CRIT)
		var/severity = 0
		switch(consciousness_value)
			if(47 to 50)
				severity = 1
			if(44 to 46)
				severity = 2
			if(40 to 43)
				severity = 3
			if(30 to 35)
				severity = 4
			if(25 to 30)
				severity = 5
			if(20 to 25)
				severity = 6
			if(15 to 20)
				severity = 7
			if(10 to 15)
				severity = 8
			if(5 to 10)
				severity = 9
			if(0 to 5)
				severity = 10
		if(owner.stat != HARD_CRIT && !HAS_TRAIT(owner,TRAIT_NOHARDCRIT))
			var/visionseverity = 4
			switch(consciousness_value)
				if(45 to 50)
					visionseverity = 5
				if(40 to 45)
					visionseverity = 6
				if(35 to 40)
					visionseverity = 7
				if(30 to 35)
					visionseverity = 8
				if(25 to 30)
					visionseverity = 9
				if(20 to 25)
					visionseverity = 10
			owner.overlay_fullscreen("critvision", /atom/movable/screen/fullscreen/crit/vision, visionseverity)
		else
			owner.clear_fullscreen("critvision")
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
