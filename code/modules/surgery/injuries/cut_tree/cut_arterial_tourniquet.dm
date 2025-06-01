/datum/injury/cut_arterial_tourniquet

/datum/injury/cut_arterial_tourniquet/on_damage_taken(total_damage, delta_damage, damage_type, damage_flag, is_sharp)
	if (!is_sharp)
		return FALSE
	return TRUE
