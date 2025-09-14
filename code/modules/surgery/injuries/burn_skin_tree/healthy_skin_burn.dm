/datum/injury/healthy_skin_burn
	base_type = /datum/injury/healthy_skin_burn
	max_absorption = 0
	injury_flags = INJURY_LIMB | INJURY_GRAPH

/datum/injury/healthy_skin_burn/on_damage_taken(total_damage, delta_damage, damage_type = BRUTE, damage_flag = DAMAGE_STANDARD, is_sharp = FALSE)
	if (damage_type != BURN)
		return FALSE
	// If the skin gets burnt in an unprotected way, get blisters
	if (total_damage >= 20 || prob(delta_damage))
		transition_to(/datum/injury/blisters)
	return TRUE

/datum/injury/healthy_skin_burn/gain_message(mob/living/carbon/human/target, obj/item/bodypart/part)
	to_chat(target, span_warning("The blisters on your [part.plaintext_zone] subside."))
