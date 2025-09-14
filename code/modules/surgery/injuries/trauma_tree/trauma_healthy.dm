/datum/injury/trauma_healthy
	base_type = /datum/injury/trauma_healthy
	max_absorption = 0

/datum/injury/trauma_healthy/on_damage_taken(total_damage, delta_damage, damage_type, damage_flag, is_sharp)
	if (is_sharp || damage_type != BRUTE)
		return FALSE
	if (total_damage >= 20)
		transition_to(/datum/injury/trauma_fracture)
	return TRUE
