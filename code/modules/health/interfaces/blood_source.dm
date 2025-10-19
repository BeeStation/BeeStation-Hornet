
/**
 * Interface for blood sources.
 *
 * This is an interface/abstract class not intended for use, if you want
 * to modify behaviour then do it in a concrete implementation
 */

/// The volume of blood in the mob
/datum/blood_source
	var/volume
	var/bleed_effect_type

	/// The blood circulation type provided
	var/circulation_type_provided

	VAR_PROTECTED/mob/living/owner

/datum/blood_source/proc/Initialize(mob/living/owner)
	// Stop bleeding if we change the source of our blood
	src.owner = owner
	owner.remove_status_effect(/datum/status_effect/bleeding)
	restore_blood()

/datum/blood_source/proc/transfer_to(datum/blood_source/new_source)
	if (!new_source.status_traits)
		new_source.status_traits = list()
	// Copy all status traits across, as we do not want to lose values
	// such as circulation
	for (var/trait in status_traits)
		var/list/trait_sources = status_traits[trait]
		new_source.status_traits[trait] = trait_sources.Copy()

/// Get the type path of the reagent used by the mob's blood
/datum/blood_source/proc/get_blood_id()

/// Executed every life tick
/datum/blood_source/proc/blood_tick(mob/living/source, delta_time)

/// Restore the blood to a safe status
/datum/blood_source/proc/restore_blood()

/// Bleed blood onto the ground
/datum/blood_source/proc/bleed(amount)

/// Get the data associated with the blood, such as the DNA stored within
/datum/blood_source/proc/get_blood_data()
	RETURN_TYPE(/list)
	return list()

/// Number between 0 and 1 representing how well blood is circulating around the body.
/// Numbers less than 1 mean that the body is not getting enough blood-flow
/datum/blood_source/proc/get_effectiveness()
	return GET_TRAIT_VALUE(src, TRAIT_VALUE_CIRCULATION) * GET_TRAIT_VALUE(src, TRAIT_VALUE_OXYGENATION)

/// Get the oxygenation rating of the lungs
/datum/blood_source/proc/get_oxygenation_rating()
	if (HAS_TRAIT(owner, TRAIT_NOBREATH))
		return 1
	return GET_TRAIT_VALUE(src, TRAIT_VALUE_OXYGENATION)

/// Get the circulation effectiveness
/datum/blood_source/proc/get_circulation_rating()
	if (!owner.needs_heart())
		return 1
	return GET_TRAIT_VALUE(src, TRAIT_VALUE_CIRCULATION)

/// Set the base circulation rating to the specified value
/// The final blood effectiveness is calculated from circulation * oxygenation
/datum/blood_source/proc/set_circulation_rating(multiplier, source)
	ADD_CUMULATIVE_TRAIT(src, TRAIT_VALUE_CIRCULATION, source, multiplier)

/// Multiply the circulation rating by the specified value
/// The final blood effectiveness is calculated from circulation * oxygenation
/datum/blood_source/proc/multiply_circulation_rating(multiplier, source)
	ADD_MULTIPLICATIVE_TRAIT(src, TRAIT_VALUE_CIRCULATION, source, multiplier)

/// Set the base oxygenation rating to the specified value
/// The final blood effectiveness is calculated from circulation * oxygenation
/datum/blood_source/proc/set_oxygenation_rating(multiplier, source)
	ADD_CUMULATIVE_TRAIT(src, TRAIT_VALUE_OXYGENATION, source, multiplier)

/// Multiply the oxygenation rating by the specified value
/// The final blood effectiveness is calculated from circulation * oxygenation
/datum/blood_source/proc/multiply_oxygenation_rating(multiplier, source)
	ADD_MULTIPLICATIVE_TRAIT(src, TRAIT_VALUE_OXYGENATION, source, multiplier)

/// Enter shock, raised by a particular source. We are in shock if we have at least
/// 1 shock source.
/datum/blood_source/proc/enter_shock(source)
	ADD_MULTIPLICATIVE_TRAIT(src, TRAIT_VALUE_CIRCULATION, source, 0)

/// Exit shock
/datum/blood_source/proc/exit_shock(source)
	ADD_MULTIPLICATIVE_TRAIT(src, TRAIT_VALUE_CIRCULATION, source, 1)
