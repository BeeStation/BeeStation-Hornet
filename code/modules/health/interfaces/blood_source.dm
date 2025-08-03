
/**
 * Interface for blood sources.
 *
 * This is an interface/abstract class not intended for use, if you want
 * to modify behaviour then do it in a concrete implementation
 */

/// The volume of blood in the mob
/datum/blood_source/var/volume

/datum/blood_source/var/mob/living/owner

/datum/blood_source/New(mob/living/owner)
	// Stop bleeding if we change the source of our blood
	src.owner = owner
	owner.remove_status_effect(/datum/status_effect/bleeding)

/// Get the type path of the reagent used by the mob's blood
/datum/blood_source/proc/get_blood_id()

/datum/blood_source/proc/blood_tick(mob/living/source)

/datum/blood_source/proc/restore_blood()

/datum/blood_source/proc/bleed(amount)
	
