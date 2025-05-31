/datum/injury/restored_skin_burn

/datum/injury/restored_skin_burn/on_damage_taken(total_damage, delta_damage, damage_flag = DAMAGE_STANDARD, is_sharp = FALSE)
	if (damage_flag != DAMAGE_FIRE && damage_flag != DAMAGE_ACID && damage_flag != DAMAGE_BOMB && damage_flag != DAMAGE_LASER && damage_flag != DAMAGE_SHOCK && damage_flag != DAMAGE_ENERGY)
		return FALSE
	if (total_damage >= 10 || delta_damage >= 5)
		transition_to(/datum/injury/second_degree_burns)
	return TRUE

/datum/injury/restored_skin_burn/gain_message(mob/living/carbon/human/target, obj/item/bodypart/part)
	to_chat(target, span_warning("The blisters on your [part.name] mostly subside."))
