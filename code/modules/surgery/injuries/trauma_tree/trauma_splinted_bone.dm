/datum/injury/trauma_splinted_bone
	severity_level = INJURY_PRIORITY_HEALING
	health_doll_icon = "bandage"
	examine_description = "a splinted fracture"
	effectiveness_modifier = 0.9
	heal_description = "The victim should rest and allow the damaged bones to naturally heal over time."
	external = TRUE

/datum/injury/trauma_splinted_bone/apply_to_part(obj/item/bodypart/part)
	// If we lose the injury, stop the timer
	addtimer(CALLBACK(src, PROC_REF(check_heal), part), rand(2 MINUTES, 5 MINUTES), TIMER_DELETE_ME)

/datum/injury/trauma_splinted_bone/proc/check_heal(obj/item/bodypart/part)
	// Heal the blisters
	transition_to(/datum/injury/trauma_healthy)

/datum/injury/trauma_splinted_bone/on_damage_taken(total_damage, delta_damage, damage_type, damage_flag, is_sharp)
	if (is_sharp || damage_type != BRUTE)
		return FALSE
	if (total_damage >= 15)
		transition_to(/datum/injury/trauma_broken_bone)
	return TRUE
