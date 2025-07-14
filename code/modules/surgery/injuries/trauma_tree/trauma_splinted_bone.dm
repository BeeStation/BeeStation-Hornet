/datum/injury/trauma_splinted_bone

/datum/injury/trauma_splinted_bone/on_damage_taken(total_damage, delta_damage, damage_type, damage_flag, is_sharp)
	if (is_sharp || damage_type != BRUTE)
		return FALSE
	if (total_damage >= 15)
		transition_to(/datum/injury/trauma_broken_bone)
	return TRUE
