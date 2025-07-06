/datum/injury/restored_skin_burn
	severity_level = INJURY_PRIORITY_HEALING
	health_doll_icon = "bandage"

/datum/injury/restored_skin_burn/on_damage_taken(total_damage, delta_damage, damage_type = BRUTE, damage_flag = DAMAGE_STANDARD, is_sharp = FALSE)
	if (damage_type != BURN)
		return FALSE
	if (total_damage >= 10 || delta_damage >= 5)
		transition_to(/datum/injury/third_degree_burn)
	return TRUE

/datum/injury/restored_skin_burn/gain_message(mob/living/carbon/human/target, obj/item/bodypart/part)
	to_chat(target, span_warning("The blisters on your [part.plaintext_zone] mostly subside."))
