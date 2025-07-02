/datum/injury/cut_minor

/datum/injury/cut_minor/on_damage_taken(total_damage, delta_damage, damage_type, damage_flag, is_sharp)
	if (!is_sharp)
		return FALSE
	if (total_damage >= 10)
		transition_to(/datum/injury/cut_laceration)
	return TRUE

/datum/injury/cut_minor/apply_to_human(mob/living/carbon/human/target)
	. = ..()
	RegisterSignal(target, SIGNAL_REMOVE_STATUS_EFFECT(/datum/status_effect/bleeding), PROC_REF(check_healed))

/datum/injury/cut_minor/proc/check_healed(datum/status_effect/bleeding/bleeding)
	transition_to(/datum/injury/cut_healthy)
