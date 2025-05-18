/datum/injury/healthy_skin_burn

/datum/injury/healthy_skin_burn/on_damage_taken(total_damage, delta_damage)
	// If the skin gets burnt in an unprotected way, get blisters
	if (total_damage >= 20 || prob(delta_damage))
		transition_to(/datum/injury/blisters)

/datum/injury/healthy_skin_burn/gain_message(mob/living/carbon/human/target, obj/item/bodypart/part)
	to_chat(target, span_warning("The blisters on your [part.name] subside."))
