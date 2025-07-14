/datum/injury/trauma_splinted_broken_bone
	healed_type = /datum/injury/trauma_splinted_bone
	effectiveness_modifier = 0.5

/datum/injury/trauma_splinted_broken_bone/on_damage_taken(total_damage, delta_damage, damage_type, damage_flag, is_sharp)
	if (is_sharp || damage_type != BRUTE)
		return FALSE
	if (total_damage >= 5)
		transition_to(/datum/injury/trauma_broken_bone)
	return TRUE
