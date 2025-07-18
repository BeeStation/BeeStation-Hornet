/datum/injury/repaired_skin_burn
	surgeries_provided = list(/datum/surgery/skin_graft)
	severity_level = INJURY_PRIORITY_HEALING
	health_doll_icon = "bandage"
	examine_description = "treatable burn scars"
	healed_type = /datum/injury/healthy_skin_burn
	heal_description = "This victim can be treated via a surgical skin graft."

/datum/injury/repaired_skin_burn/on_damage_taken(total_damage, delta_damage, damage_type = BRUTE, damage_flag = DAMAGE_STANDARD, is_sharp = FALSE)
	if (damage_type != BURN)
		return FALSE
	// If the skin gets burnt in an unprotected way, get blisters
	if (total_damage >= 20 || prob(delta_damage))
		transition_to(/datum/injury/second_degree_burns)
	return TRUE

/datum/injury/repaired_skin_burn/gain_message(mob/living/carbon/human/target, obj/item/bodypart/part)
	to_chat(target, span_warning("The blisters on your [part.plaintext_zone] subside."))
