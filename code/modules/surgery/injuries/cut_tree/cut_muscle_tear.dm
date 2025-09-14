/datum/injury/cut_muscle_tear
	base_type = /datum/injury/cut_healthy
	effectiveness_modifier = 0.4
	skin_armour_modifier = 0.4
	severity_level = INJURY_PRIORITY_ACTIVE
	health_doll_icon = "blood"
	examine_description = "<b>a muscle tear</b>"
	healed_type = /datum/injury/cut_stitched_muscle
	surgeries_provided = list(
		/datum/surgery/stitch_muscle
	)
	heal_description = "The victim requires a suture to stop the bleeding, and surgery to stitch the muscle for a full recovery."
	external = TRUE
	progression = 50
	injury_flags = INJURY_LIMB | INJURY_GRAPH

/datum/injury/cut_muscle_tear/on_tick(mob/living/carbon/human/target, delta_time)
	. = ..()
	var/datum/status_effect/tourniquet/tourniquet = target.has_status_effect(/datum/status_effect/tourniquet)
	if (tourniquet && tourniquet.bodyzone_target == bodypart.body_zone)
		return
	if (target.get_bleed_rate() >= BLEED_CUT)
		return
	if (DT_PROB(10, delta_time) && !target.is_bandaged())
		target.add_bleeding(BLEED_CUT)
		to_chat(target, span_userdanger("Your lacerated [bodypart.plaintext_zone] starts bleeding!"))

/datum/injury/cut_muscle_tear/on_damage_taken(total_damage, delta_damage, damage_type, damage_flag, is_sharp)
	if (!is_sharp)
		return FALSE
	if (total_damage >= 30)
		transition_to(/datum/injury/cut_arterial)
	return TRUE

/datum/injury/cut_muscle_tear/intercept_medical_application(obj/item/stack/medical/medical_item, mob/living/carbon/human/victim, mob/living/actor)
	if (istype(medical_item, /obj/item/stack/medical/suture))
		if (actor == victim)
			actor.visible_message(span_notice("[actor] starts to apply [medical_item] to [actor.p_them()]self..."), span_notice("You begin applying [medical_item] to yourself..."))
		else
			actor.visible_message(span_notice("[actor] starts to suture [victim]'s wounds'."), span_notice("You begin suturing [victim]'s wounds..."))
		if (!do_after(actor, 6 SECONDS, victim))
			return MEDICAL_ITEM_FAILED
		transition_to(/datum/injury/cut_bandaged_muscle_tear)
		return MEDICAL_ITEM_APPLIED
	return ..()

/datum/injury/cut_muscle_tear/intercept_reagent_exposure(datum/reagent, mob/living/victim, method, reac_volume, touch_protection)
	if (!istype(reagent, /datum/reagent/medicine/coagen))
		return
	if (reac_volume < 5)
		to_chat(victim, span_warning("Your lacerated [bodypart.plaintext_zone] strings, the wound fails to heal. It wasn't enough!"))
		return
	if (method != TOUCH && method != PATCH)
		return
	transition_to(/datum/injury/cut_bandaged_muscle_tear)
