/datum/injury
	/// The type of alert shown to the owner of the limb
	var/alert_type = null
	/// Current amount of damage taken
	var/current_damage = 0
	/// Bodypart we are attached to
	var/obj/item/bodypart/bodypart
	/// Effectiveness modifier to the limb
	var/effectiveness_modifier = 1
	/// Modifier to the bone armour provided by the limb
	var/bone_armour_modifier = 1
	/// Modifier to the skin armour provided by the limb
	var/skin_armour_modifier = 1
	/// Current amount of damage that we have taken
	VAR_PRIVATE/damage_taken = 0
	/// List of surgeries provided by this injury
	var/list/surgeries_provided = null

/// Called only if we are gained while a human has the bodypart
/// attached. Not called if a bodypart with the injury is
/// attached.
/datum/injury/proc/gain_message(mob/living/carbon/human/target, obj/item/bodypart/part)

/// Apply the injury to the bodypart
/datum/injury/proc/apply_to_part(obj/item/bodypart/part)
	return

/// Remove the injury from the bodypart
/datum/injury/proc/remove_from_part(obj/item/bodypart/part)
	return

/// Apply the injury to the target
/datum/injury/proc/apply_to_human(mob/living/carbon/human/target)
	return

/// Take the injury away from the person who owns the limb
/datum/injury/proc/remove_from_human(mob/living/carbon/human/target)
	return

/datum/injury/proc/apply_damage(delta_damage, damage_flag = DAMAGE_STANDARD, is_sharp = FALSE)
	current_damage += delta_damage
	on_damage_taken(current_damage, delta_damage, damage_flag, is_sharp)

/// Called when damage is taken
/datum/injury/proc/on_damage_taken(total_damage, delta_damage, damage_flag = DAMAGE_STANDARD, is_sharp = FALSE)
	return

/// Called when the limb processes, target may be null
/datum/injury/proc/on_tick(mob/living/carbon/human/target, delta_time)

/// Transition to a new type of injury state.
/datum/injury/proc/transition_to(new_type)
	SHOULD_NOT_OVERRIDE(TRUE)
