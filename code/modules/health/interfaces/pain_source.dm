// Pain level
#define TRAIT_PAIN_LEVEL "pain_level"

/datum/pain_source
	/// The owner of the consciousness datum
	var/mob/living/owner
	/// How much pain are we currently in?
	var/pain

/datum/pain_source/proc/on_life()

/// Update the damage overlay, pain level between:
/// 0: no pain
/// 100: max pain
/datum/pain_source/proc/update_damage_overlay(pain_level)
	if(pain_level)
		var/severity = 0
		switch(pain_level)
			if(5 to 15)
				severity = 1
			if(15 to 30)
				severity = 2
			if(30 to 45)
				severity = 3
			if(45 to 70)
				severity = 4
			if(70 to 85)
				severity = 5
			if(85 to INFINITY)
				severity = 6
		owner.overlay_fullscreen("pain", /atom/movable/screen/fullscreen/brute, severity)
	else
		owner.clear_fullscreen("pain")

/// Provide a source of consciousness. Without one consciousness will be 0, which is dead.
/// Source: The source of the modifier
/// Amount: The amount of consciousness provided by the source.
/datum/pain_source/proc/set_pain_source(amount, source)
	if (!amount)
		REMOVE_TRAIT(src, TRAIT_PAIN_LEVEL, source)
	else
		ADD_CUMULATIVE_TRAIT(src, TRAIT_PAIN_LEVEL, source, amount)
	//update_consciousness(GET_TRAIT_VALUE(src, TRAIT_PAIN_LEVEL))

/// Set a consciousness modifier.
/// Source: The source of the modifier
/// Amount: The multiplier for the modifier, set to 1 to remove
/datum/pain_source/proc/set_pain_modifier(amount, source)
	if (amount == 1)
		REMOVE_TRAIT(src, TRAIT_PAIN_LEVEL, source)
	else
		ADD_MULTIPLICATIVE_TRAIT(src, TRAIT_PAIN_LEVEL, source, amount)
	//update_consciousness(GET_TRAIT_VALUE(src, TRAIT_PAIN_LEVEL))

/// Add a pain message caused by a specific source
/datum/pain_source/proc/add_pain_message(message, source)

/// Remove all pain messages associated with that source
/datum/pain_source/proc/remove_pain_messages(source)

#undef TRAIT_PAIN_LEVEL
