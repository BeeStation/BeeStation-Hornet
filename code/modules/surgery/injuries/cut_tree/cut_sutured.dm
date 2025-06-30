/datum/injury/cut_sutured
	alert_message = "<s>Laceration</s> (Sutured)"

/datum/injury/cut_sutured/on_damage_taken(total_damage, delta_damage, damage_type, damage_flag, is_sharp)
	if (!is_sharp)
		return FALSE
	return TRUE
