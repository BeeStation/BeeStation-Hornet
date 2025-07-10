/datum/injury/cut_sutured
	severity_level = INJURY_PRIORITY_HEALING
	health_doll_icon = "bandage"
	examine_description = "sutured wounds"
	healed_type = /datum/injury/cut_healthy

/datum/injury/cut_sutured/on_damage_taken(total_damage, delta_damage, damage_type, damage_flag, is_sharp)
	if (!is_sharp)
		return FALSE
	return TRUE

/datum/injury/cut_sutured/apply_to_part(obj/item/bodypart/part)
	// If we lose the injury, stop the timer
	addtimer(CALLBACK(src, PROC_REF(check_heal), part), rand(2 MINUTES, 6 MINUTES), TIMER_DELETE_ME)

/datum/injury/cut_sutured/proc/check_heal(obj/item/bodypart/part)
	heal()
