/datum/injury/cut_arterial
	effectiveness_modifier = 0.4
	skin_armour_modifier = 0.4
	severity_level = INJURY_PRIORITY_ACTIVE
	health_doll_icon = "blood"
	examine_description = "<b>an arterial cut</b>"

/datum/injury/cut_arterial/on_damage_taken(total_damage, delta_damage, damage_type, damage_flag, is_sharp)
	if (!is_sharp)
		return FALSE
	return TRUE
