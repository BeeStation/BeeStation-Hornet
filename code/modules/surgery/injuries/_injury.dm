/datum/injury
	/// The type of alert shown to the owner of the limb
	var/alert_type = null
	var/obj/item/bodypart/bodypart
	/// Effectiveness modifier to the limb
	var/effectiveness_modifier = 1
	/// Modifier to the bone armour provided by the limb
	var/bone_armour_modifier = 1
	/// Modifier to the skin armour provided by the limb
	var/skin_armour_modifier = 1
	/// Current amount of damage that we have taken
	VAR_PRIVATE/damage_taken = 0

/// Called only if we are gained while a human has the bodypart
/// attached. Not called if a bodypart with the injury is
/// attached.
/datum/injury/proc/gain_message(mob/living/carbon/human/target, obj/item/bodypart/part)

/datum/injury/proc/apply_to_part(obj/item/bodypart/part)
	return

/datum/injury/proc/remove_from_part(obj/item/bodypart/part)
	return

/datum/injury/proc/apply_to_human(mob/living/carbon/human/target)
	return

/datum/injury/proc/remove_from_human(mob/living/carbon/human/target)
	return

/// Called when damage is taken
/datum/injury/proc/on_damage_taken(total_damage, delta_damage)
	return

/datum/injury/proc/on_tick(mob/living/carbon/human/target, delta_time)

/// Transition to a new type of injury state.
/datum/injury/proc/transition_to(new_type)
	SHOULD_NOT_OVERRIDE(TRUE)
