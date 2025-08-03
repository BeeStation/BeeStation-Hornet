/datum/injury/cut_healthy
	max_absorption = 0

/datum/injury/cut_healthy/on_damage_taken(total_damage, delta_damage, damage_type, damage_flag, is_sharp)
	if (!is_sharp)
		return FALSE
	if (total_damage >= 10)
		transition_to(/datum/injury/cut_laceration)
	return TRUE
