/datum/injury/trauma_fracture
	severity_level = INJURY_PRIORITY_ACTIVE
	health_doll_icon = "blood"
	examine_description = "<b>a fracture</b>"
	effectiveness_modifier = 0.5
	bone_armour_modifier = 0.7
	healed_type = /datum/injury/trauma_splinted_bone

/datum/injury/trauma_fracture/apply_to_part(obj/item/bodypart/part)
	// If we lose the injury, stop the timer
	addtimer(CALLBACK(src, PROC_REF(check_heal), part), rand(10 MINUTES, 20 MINUTES), TIMER_DELETE_ME)

/datum/injury/trauma_fracture/proc/check_heal(obj/item/bodypart/part)
	// Heal the blisters
	transition_to(/datum/injury/trauma_healthy)

/datum/injury/trauma_fracture/on_damage_taken(total_damage, delta_damage, damage_type, damage_flag, is_sharp)
	if (is_sharp || damage_type != BRUTE)
		return FALSE
	if (total_damage >= 40)
		transition_to(/datum/injury/trauma_broken_bone)
	return TRUE

/datum/injury/trauma_fracture/intercept_medical_application(obj/item/stack/medical/medical_item, mob/living/carbon/human/victim, mob/living/actor)
	if (istype(medical_item, /obj/item/stack/medical/splint))
		if (actor == victim)
			actor.visible_message(span_notice("[actor] starts to apply [medical_item] to [actor.p_them()]self..."), span_notice("You begin applying [medical_item] to yourself..."))
		else
			actor.visible_message(span_notice("[actor] starts to splint [victim]'s fracture'."), span_notice("You begin splinting [victim]'s fracture..."))
		if (!do_after(actor, 6 SECONDS, victim))
			return MEDICAL_ITEM_FAILED
		heal()
		return MEDICAL_ITEM_APPLIED
	return ..()
