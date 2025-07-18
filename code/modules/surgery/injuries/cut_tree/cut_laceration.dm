/datum/injury/cut_laceration
	effectiveness_modifier = 0.8
	skin_armour_modifier = 0.6
	severity_level = INJURY_PRIORITY_ACTIVE
	health_doll_icon = "blood"
	examine_description = "<b>lacerations</b>"
	healed_type = /datum/injury/cut_sutured
	surgeries_provided = list(
		/datum/surgery/cauterize
	)
	heal_description = "The victim requires sutures to prevent further bleeding."

/datum/injury/cut_laceration/on_tick(mob/living/carbon/human/target, delta_time)
	. = ..()
	var/datum/status_effect/tourniquet/tourniquet = target.has_status_effect(/datum/status_effect/tourniquet)
	if (tourniquet && tourniquet.bodyzone_target == bodypart.body_zone)
		return
	if (target.get_bleed_rate() >= BLEED_SURFACE)
		return
	if (DT_PROB(5, delta_time) && !target.is_bandaged())
		target.add_bleeding(BLEED_CUT)
		to_chat(target, span_userdanger("Your lacerated [bodypart.plaintext_zone] starts bleeding!"))

/datum/injury/cut_laceration/on_damage_taken(total_damage, delta_damage, damage_type, damage_flag, is_sharp)
	if (!is_sharp)
		return FALSE
	if (total_damage >= 30)
		transition_to(/datum/injury/cut_muscle_tear)
	return TRUE

/datum/injury/cut_laceration/intercept_medical_application(obj/item/stack/medical/medical_item, mob/living/carbon/human/victim, mob/living/actor)
	if (istype(medical_item, /obj/item/stack/medical/suture))
		if (actor == victim)
			actor.visible_message(span_notice("[actor] starts to apply [medical_item] to [actor.p_them()]self..."), span_notice("You begin applying [medical_item] to yourself..."))
		else
			actor.visible_message(span_notice("[actor] starts to suture [victim]'s wounds'."), span_notice("You begin suturing [victim]'s wounds..."))
		if (!do_after(actor, 6 SECONDS, victim))
			return MEDICAL_ITEM_FAILED
		heal()
		return MEDICAL_ITEM_APPLIED
	return ..()

/datum/injury/cut_laceration/apply_to_human(mob/living/carbon/human/target)
	. = ..()
	RegisterSignal(target, COMSIG_CARBON_CAUTERISE_WOUNDS, PROC_REF(check_cauterisation))

/datum/injury/cut_laceration/remove_from_human(mob/living/carbon/human/target)
	. = ..()
	UnregisterSignal(target, COMSIG_CARBON_CAUTERISE_WOUNDS)

/datum/injury/cut_laceration/proc/check_cauterisation(mob/living/carbon/target, amount)
	if (amount > 100 || prob(amount))
		heal()

/datum/injury/cut_laceration/intercept_reagent_exposure(datum/reagent, mob/living/victim, method, reac_volume, touch_protection)
	if (!istype(reagent, /datum/reagent/medicine/coagen))
		return
	if (reac_volume < 5)
		to_chat(victim, span_warning("Your lacerated [bodypart.plaintext_zone] strings, the wound fails to heal. It wasn't enough!"))
		return
	if (method != TOUCH && method != PATCH)
		return
	heal()
