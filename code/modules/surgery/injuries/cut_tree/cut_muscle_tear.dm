/datum/injury/cut_muscle_tear
	alert_message = "Muscle Tear"
	effectiveness_modifier = 0.4
	skin_armour_modifier = 0.4

/datum/injury/cut_muscle_tear/on_tick(mob/living/carbon/human/target, delta_time)
	. = ..()
	if (target.get_bleed_rate() >= BLEED_CUT)
		return
	if (DT_PROB(10, delta_time))
		target.add_bleeding(BLEED_CUT)
		to_chat(target, span_userdanger("Your lacerated [bodypart] starts bleeding!"))

/datum/injury/cut_muscle_tear/on_damage_taken(total_damage, delta_damage, damage_type, damage_flag, is_sharp)
	if (!is_sharp)
		return FALSE
	if (total_damage >= 10)
		transition_to(/datum/injury/cut_arterial)
	return TRUE
