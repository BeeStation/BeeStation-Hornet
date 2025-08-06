// Consciousness level
#define TRAIT_CONSCIOUSNESS_LEVEL "consciousness_level"

/datum/consciousness
	/// The owner of the consciousness datum
	var/mob/living/owner

/datum/consciousness/New(mob/living/owner)
	. = ..()
	src.owner = owner

/// Register signals on the owner
/datum/consciousness/proc/register_signals(mob/living/owner)

/// Called every life tick
/datum/consciousness/proc/consciousness_tick(delta_time)

/// Called when consciousness value is updated
/datum/consciousness/proc/update_consciousness(consciousness_value)

/// Trigger an update of the stat
/datum/consciousness/proc/update_stat()
	SIGNAL_HANDLER
	update_consciousness(GET_TRAIT_VALUE(src, TRAIT_CONSCIOUSNESS_LEVEL))

/// Provide a source of consciousness. Without one consciousness will be 0, which is dead.
/// Source: The source of the modifier
/// Amount: The amount of consciousness provided by the source.
/datum/consciousness/proc/set_consciousness_source(source, amount)
	if (!amount)
		REMOVE_TRAIT(src, TRAIT_CONSCIOUSNESS_LEVEL, source)
	else
		ADD_CUMULATIVE_TRAIT(src, TRAIT_CONSCIOUSNESS_LEVEL, source, amount)
	update_consciousness(GET_TRAIT_VALUE(src, TRAIT_CONSCIOUSNESS_LEVEL))

/// Set a consciousness modifier.
/// Source: The source of the modifier
/// Amount: The multiplier for the modifier, set to 1 to remove
/datum/consciousness/proc/set_consciousness_modifier(source, amount)
	if (amount == 1)
		REMOVE_TRAIT(src, TRAIT_CONSCIOUSNESS_LEVEL, source)
	else
		ADD_MULTIPLICATIVE_TRAIT(src, TRAIT_CONSCIOUSNESS_LEVEL, source, amount)
	update_consciousness(GET_TRAIT_VALUE(src, TRAIT_CONSCIOUSNESS_LEVEL))

#undef TRAIT_CONSCIOUSNESS_LEVEL
