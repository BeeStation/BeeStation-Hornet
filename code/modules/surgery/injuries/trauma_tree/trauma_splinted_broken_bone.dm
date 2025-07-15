/datum/injury/trauma_splinted_broken_bone
	severity_level = INJURY_PRIORITY_HEALING
	health_doll_icon = "bandage"
	examine_description = "a splinted broken bone"
	effectiveness_modifier = 0.5
	healed_type = /datum/injury/trauma_splinted_bone
	surgeries_provided = list(
		/datum/surgery/bone_setting
	)

/datum/injury/trauma_splinted_broken_bone/on_damage_taken(total_damage, delta_damage, damage_type, damage_flag, is_sharp)
	if (is_sharp || damage_type != BRUTE)
		return FALSE
	if (total_damage >= 5)
		transition_to(/datum/injury/trauma_broken_bone)
	return TRUE
