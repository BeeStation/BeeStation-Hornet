/datum/injury/restored_skin_burn
	base_type = /datum/injury/healthy_skin_burn
	severity_level = INJURY_PRIORITY_HEALING
	health_doll_icon = "bandage"
	examine_description = "untreatable burn scars"
	heal_description = "This injury is not life-threatening but poses a severe risk if the victim is damaged further. It can be mitigated via augmentation or replacement of the bodypart."
	external = TRUE
	progression = 50
	injury_flags = INJURY_LIMB | INJURY_GRAPH

/datum/injury/restored_skin_burn/on_damage_taken(total_damage, delta_damage, damage_type = BRUTE, damage_flag = DAMAGE_STANDARD, is_sharp = FALSE)
	if (damage_type != BURN)
		return FALSE
	if (total_damage >= 10 || delta_damage >= 5)
		transition_to(/datum/injury/third_degree_burn)
	return TRUE

/datum/injury/restored_skin_burn/gain_message(mob/living/carbon/human/target, obj/item/bodypart/part)
	to_chat(target, span_warning("The pain in your [part.plaintext_zone] subsides."))
