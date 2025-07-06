/datum/injury/blisters
	skin_armour_modifier = 0.9
	effectiveness_modifier = 0.7
	surgeries_provided = list(/datum/surgery/skin_graft)

/datum/injury/blisters/on_damage_taken(total_damage, delta_damage, damage_type = BRUTE, damage_flag = DAMAGE_STANDARD, is_sharp = FALSE)
	if (damage_type != BURN)
		return FALSE
	// If the skin gets burnt in an unprotected way, get blisters
	if (total_damage >= 10 && (delta_damage > 2 || prob(delta_damage * 5)))
		transition_to(/datum/injury/second_degree_burns)
	return TRUE

/datum/injury/blisters/gain_message(mob/living/carbon/human/target, obj/item/bodypart/part)
	to_chat(target, span_userdanger("Your [part.plaintext_zone] blisters from the intense heat!"))

/datum/injury/blisters/apply_to_part(obj/item/bodypart/part)
	// If we lose the injury, stop the timer
	addtimer(CALLBACK(src, PROC_REF(check_heal), part), rand(5 MINUTES, 15 MINUTES), TIMER_DELETE_ME)

/datum/injury/blisters/proc/check_heal(obj/item/bodypart/part)
	//if (prob(30))
		// Gain an infection
	// Heal the blisters
	transition_to(/datum/injury/repaired_skin_burn)

/datum/injury/blisters/intercept_medical_application(obj/item/stack/medical/medical_item, mob/living/carbon/human/victim, mob/living/carbon/human/actor)
	if (ispath(medical_item, /datum/reagent/medicine/silver_sulfadiazine))
		return MEDICAL_ITEM_VALID
	return MEDICAL_ITEM_NO_INTERCEPT

/datum/injury/blisters/intercept_reagent_exposure(datum/reagent, mob/living/victim, method, reac_volume, touch_protection)
	if (!istype(reagent, /datum/reagent/medicine/silver_sulfadiazine) && !istype(reagent, /datum/reagent/medicine/advanced_burn_gel))
		return
	var/total_volume = victim.reagents.get_reagent_amount(/datum/reagent/medicine/silver_sulfadiazine) + victim.reagents.get_reagent_amount(/datum/reagent/medicine/advanced_burn_gel)
	if (total_volume < 5)
		to_chat(victim, span_warning("The pain in your blisters start to numb, however they do not fully subside. You need more burn gel!"))
		return
	if (method != TOUCH && method != PATCH)
		return
	transition_to(/datum/injury/treated_burn)
