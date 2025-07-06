/datum/injury/cut_muscle_tear
	effectiveness_modifier = 0.4
	skin_armour_modifier = 0.4
	severity_level = INJURY_PRIORITY_ACTIVE
	health_doll_icon = "blood"
	examine_description = "<b>a muscle tear</b>"

/datum/injury/cut_muscle_tear/on_tick(mob/living/carbon/human/target, delta_time)
	. = ..()
	if (target.get_bleed_rate() >= BLEED_CUT)
		return
	if (DT_PROB(10, delta_time) && !target.is_bandaged())
		target.add_bleeding(BLEED_CUT)
		to_chat(target, span_userdanger("Your lacerated [bodypart.plaintext_zone] starts bleeding!"))

/datum/injury/cut_muscle_tear/on_damage_taken(total_damage, delta_damage, damage_type, damage_flag, is_sharp)
	if (!is_sharp)
		return FALSE
	if (total_damage >= 10)
		transition_to(/datum/injury/cut_arterial)
	return TRUE
