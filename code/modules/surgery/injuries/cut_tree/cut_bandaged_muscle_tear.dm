/datum/injury/cut_bandaged_muscle_tear
	severity_level = INJURY_PRIORITY_HEALING
	health_doll_icon = "bandage"
	examine_description = "<b>a bandaged muscle tear</b>"
	effectiveness_modifier = 0.8
	healed_type = /datum/injury/cut_stitched_muscle
	surgeries_provided = list(
		/datum/surgery/stitch_muscle
	)

/datum/injury/cut_bandaged_muscle_tear/on_damage_taken(total_damage, delta_damage, damage_type, damage_flag, is_sharp)
	if (!is_sharp)
		return FALSE
	if (total_damage >= 6)
		transition_to(/datum/injury/cut_muscle_tear)
	return TRUE
