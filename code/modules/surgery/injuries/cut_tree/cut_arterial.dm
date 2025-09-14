/datum/injury/cut_arterial
	base_type = /datum/injury/cut_healthy
	effectiveness_modifier = 0.4
	skin_armour_modifier = 0.4
	severity_level = INJURY_PRIORITY_ACTIVE
	health_doll_icon = "blood"
	examine_description = "<b>an arterial cut</b>"
	surgeries_provided = list(
		/datum/surgery/cauterize
	)
	healed_type = /datum/injury/cut_stitched_muscle
	heal_description = "The victim requires immediate the application of a tourniquet and cauterization surgery to be performed."
	external = TRUE
	progression = 50

/datum/injury/cut_arterial/on_tick(mob/living/carbon/human/target, delta_time)
	. = ..()
	var/datum/status_effect/tourniquet/tourniquet = target.has_status_effect(/datum/status_effect/tourniquet)
	if (tourniquet && tourniquet.bodyzone_target == bodypart.body_zone)
		return
	if (target.get_bleed_rate() >= BLEED_CRITICAL)
		return
	if (target.is_bandaged())
		if (!DT_PROB_RATE(2, delta_time))
			return
		to_chat(target, span_userdanger("The bandages around your [bodypart.plaintext_zone] fail to stop the bleeding, use a tourniquet!"))
	target.add_bleeding(BLEED_TINY, sound_effect = FALSE)

/datum/injury/cut_arterial/on_damage_taken(total_damage, delta_damage, damage_type, damage_flag, is_sharp)
	if (!is_sharp)
		return FALSE
	if (total_damage >= 30)
		transition_to(/datum/injury/limb_destroyed)
	return TRUE

/datum/injury/cut_arterial/apply_to_human(mob/living/carbon/human/target)
	. = ..()
	RegisterSignal(target, COMSIG_CARBON_CAUTERISE_WOUNDS, PROC_REF(check_cauterisation))

/datum/injury/cut_arterial/remove_from_human(mob/living/carbon/human/target)
	. = ..()
	UnregisterSignal(target, COMSIG_CARBON_CAUTERISE_WOUNDS)

/datum/injury/cut_arterial/proc/check_cauterisation(mob/living/carbon/target, amount)
	if (amount > 100 || prob(amount))
		heal()
