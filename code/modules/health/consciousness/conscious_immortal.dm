#define TRAIT_CONSCIOUSNESS_LEVEL "consciousness_level"

/datum/consciousness/immortal
	value = 100
	max_value = 100

/datum/consciousness/immortal/New(mob/living/owner)
	. = ..()
	// In case we ever read and update the value
	ADD_CUMULATIVE_TRAIT(src, TRAIT_CONSCIOUSNESS_LEVEL, INNATE_TRAIT, 100)

/datum/consciousness/immortal/set_consciousness_source(amount, source)
	return

/// Set a consciousness modifier.
/// Source: The source of the modifier
/// Amount: The multiplier for the modifier, set to 1 to remove
/datum/consciousness/immortal/set_consciousness_modifier(amount, source)
	return

#undef TRAIT_CONSCIOUSNESS_LEVEL
