/datum/injury/treated_burn
	severity_level = INJURY_PRIORITY_HEALING
	health_doll_icon = "bandage"
	examine_description = "treated burn wounds"
	healed_type = /datum/injury/repaired_skin_burn

/datum/injury/treated_burn/on_damage_taken(total_damage, delta_damage, damage_type = BRUTE, damage_flag = DAMAGE_STANDARD, is_sharp = FALSE)
	if (damage_type != BURN)
		return FALSE
	// If the skin gets burnt in an unprotected way, get blisters
	if (total_damage >= 10 && (delta_damage > 2 || prob(delta_damage * 5)))
		transition_to(/datum/injury/second_degree_burns)
	return TRUE

/datum/injury/treated_burn/gain_message(mob/living/carbon/human/target, obj/item/bodypart/part)
	to_chat(target, span_warning("The blisters on your [part.plaintext_zone] subside."))

/datum/injury/treated_burn/apply_to_part(obj/item/bodypart/part)
	// If we lose the injury, stop the timer
	addtimer(CALLBACK(src, PROC_REF(check_heal), part), rand(3 MINUTES, 8 MINUTES), TIMER_DELETE_ME)

/datum/injury/treated_burn/proc/check_heal(obj/item/bodypart/part)
	heal()
