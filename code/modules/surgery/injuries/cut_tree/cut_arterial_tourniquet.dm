/datum/injury/cut_arterial_tourniquet
	severity_level = INJURY_PRIORITY_HEALING
	health_doll_icon = "bandage"
	examine_description = "a tourniquet applied"

/datum/injury/cut_arterial_tourniquet/on_damage_taken(total_damage, delta_damage, damage_type, damage_flag, is_sharp)
	if (!is_sharp)
		return FALSE
	return TRUE
