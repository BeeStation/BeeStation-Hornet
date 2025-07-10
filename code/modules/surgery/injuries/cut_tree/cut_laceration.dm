/datum/injury/cut_laceration
	effectiveness_modifier = 0.8
	skin_armour_modifier = 0.6
	severity_level = INJURY_PRIORITY_ACTIVE
	health_doll_icon = "blood"
	examine_description = "<b>lacerations</b>"
	healed_type = /datum/injury/cut_sutured

/datum/injury/cut_laceration/on_tick(mob/living/carbon/human/target, delta_time)
	. = ..()
	if (target.get_bleed_rate() >= BLEED_CUT)
		return
	if (DT_PROB(5, delta_time) && !target.is_bandaged())
		target.add_bleeding(BLEED_CUT)
		to_chat(target, span_userdanger("Your lacerated [bodypart.plaintext_zone] starts bleeding!"))

/datum/injury/cut_laceration/on_damage_taken(total_damage, delta_damage, damage_type, damage_flag, is_sharp)
	if (!is_sharp)
		return FALSE
	if (total_damage >= 10)
		transition_to(/datum/injury/cut_muscle_tear)
	return TRUE

/datum/injury/blisters/intercept_reagent_exposure(datum/reagent, mob/living/victim, method, reac_volume, touch_protection)
	if (!istype(reagent, /datum/reagent/medicine/coagen))
		return
	if (reac_volume < 5)
		to_chat(victim, span_warning("Your lacerated [bodypart.plaintext_zone] strings, the wound fails to heal. It wasn't enough!"))
		return
	if (method != TOUCH && method != PATCH)
		return
	heal()
