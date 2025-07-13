/datum/injury/cut_arterial
	effectiveness_modifier = 0.4
	skin_armour_modifier = 0.4
	severity_level = INJURY_PRIORITY_ACTIVE
	health_doll_icon = "blood"
	examine_description = "<b>an arterial cut</b>"

/datum/injury/cut_arterial/on_tick(mob/living/carbon/human/target, delta_time)
	. = ..()
	if (target.has_status_effect(/datum/status_effect/tourniquet))
		return
	if (target.get_bleed_rate() >= BLEED_CRITICAL)
		return
	if (target.is_bandaged())
		if (!DT_PROB_RATE(2, delta_time))
			return
		to_chat(target, span_userdanger("The bandages around your [bodypart.plaintext_zone] fail to stop the bleeding, use a tourniquet!"))
	target.add_bleeding(BLEED_TINY, silent = TRUE)

/datum/injury/cut_arterial/on_damage_taken(total_damage, delta_damage, damage_type, damage_flag, is_sharp)
	if (!is_sharp)
		return FALSE
	if (total_damage >= 15)
		transition_to(/datum/injury/limb_destroyed)
	return TRUE
