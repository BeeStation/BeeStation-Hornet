/datum/injury/cut_laceration
	effectiveness_modifier = 0.8
	skin_armour_modifier = 0.6

/datum/injury/cut_laceration/on_tick(mob/living/carbon/human/target, delta_time)
	. = ..()
	if (target.get_bleed_rate() >= BLEED_CUT)
		return
	if (DT_PROB(10, delta_time))
		target.add_bleeding(BLEED_CUT)
		to_chat(target, span_userdanger("Your lacerated [bodypart] starts bleeding!"))

/datum/injury/cut_laceration/on_damage_taken(total_damage, delta_damage, damage_type, damage_flag, is_sharp)
	if (!is_sharp)
		return FALSE
	if (total_damage >= 10)
		transition_to(/datum/injury/cut_muscle_tear)
	return TRUE
