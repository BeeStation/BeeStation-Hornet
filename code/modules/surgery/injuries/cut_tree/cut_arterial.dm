/datum/injury/cut_arterial
	alert_message = "Arterial Bleeding"
	effectiveness_modifier = 0.4
	skin_armour_modifier = 0.4

/datum/injury/cut_arterial/on_damage_taken(total_damage, delta_damage, damage_type, damage_flag, is_sharp)
	if (!is_sharp)
		return FALSE
	return TRUE
