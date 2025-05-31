/datum/injury/healthy_skin_burn

/datum/injury/healthy_skin_burn/on_damage_taken(total_damage, delta_damage, damage_flag = DAMAGE_STANDARD, is_sharp = FALSE)
	if (damage_flag != DAMAGE_FIRE && damage_flag != DAMAGE_ACID && damage_flag != DAMAGE_BOMB && damage_flag != DAMAGE_LASER && damage_flag != DAMAGE_SHOCK && damage_flag != DAMAGE_ENERGY)
		return FALSE
	// If the skin gets burnt in an unprotected way, get blisters
	if (total_damage >= 20 || prob(delta_damage))
		transition_to(/datum/injury/blisters)
	return TRUE

/datum/injury/healthy_skin_burn/gain_message(mob/living/carbon/human/target, obj/item/bodypart/part)
	to_chat(target, span_warning("The blisters on your [part.name] subside."))
