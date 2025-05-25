/datum/injury/restored_skin_burn

/datum/injury/restored_skin_burn/on_damage_taken(total_damage, delta_damage)
	if (total_damage >= 10 || delta_damage >= 5)
		transition_to(/datum/injury/second_degree_burns)

/datum/injury/restored_skin_burn/gain_message(mob/living/carbon/human/target, obj/item/bodypart/part)
	to_chat(target, span_warning("The blisters on your [part.name] mostly subside."))
