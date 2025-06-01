/datum/injury/cut_arterial

/datum/injury/cut_arterial/on_damage_taken(total_damage, delta_damage, damage_type, damage_flag, is_sharp)
	if (!is_sharp)
		return FALSE
	return TRUE
