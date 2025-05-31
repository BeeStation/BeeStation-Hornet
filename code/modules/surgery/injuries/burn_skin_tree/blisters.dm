/datum/injury/blisters
	skin_armour_modifier = 0.9
	effectiveness_modifier = 0.7
	surgeries_provided = list(/datum/surgery/skin_graft)

/datum/injury/blisters/on_damage_taken(total_damage, delta_damage, damage_flag = DAMAGE_STANDARD, is_sharp = FALSE)
	if (damage_flag != DAMAGE_FIRE && damage_flag != DAMAGE_ACID && damage_flag != DAMAGE_BOMB && damage_flag != DAMAGE_LASER && damage_flag != DAMAGE_SHOCK && damage_flag != DAMAGE_ENERGY)
		return FALSE
	// If the skin gets burnt in an unprotected way, get blisters
	if (total_damage >= 10 && (delta_damage > 2 || prob(delta_damage * 5)))
		transition_to(/datum/injury/second_degree_burns)
	return TRUE

/datum/injury/blisters/gain_message(mob/living/carbon/human/target, obj/item/bodypart/part)
	to_chat(target, span_userdanger("Your [part.name] blisters from the intense heat!"))

/datum/injury/blisters/apply_to_part(obj/item/bodypart/part)
	// If we lose the injury, stop the timer
	addtimer(CALLBACK(src, PROC_REF(check_heal), part), rand(5 MINUTES, 15 MINUTES), TIMER_DELETE_ME)

/datum/injury/blisters/proc/check_heal(obj/item/bodypart/part)
	if (prob(30))
		// Gain an infection
	// Heal the blisters
	transition_to(/datum/injury/repaired_skin_burn)
