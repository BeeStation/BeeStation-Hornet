/datum/injury/cut_bandaged_muscle_tear
	alert_message = "<s>Muscle Tear</s> (Bandaged)"

/datum/injury/cut_bandaged_muscle_tear/on_damage_taken(total_damage, delta_damage, damage_type, damage_flag, is_sharp)
	if (!is_sharp)
		return FALSE
	return TRUE
