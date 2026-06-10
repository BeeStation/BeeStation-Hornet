/mob/living/carbon/alien/humanoid/death(gibbed)
	if(stat == DEAD)
		return

	. = ..()

	update_icons()
	status_flags |= CANPUSH

//When the alien queen dies, all others must pay the price for letting her die.
/mob/living/carbon/alien/humanoid/royal/queen/death(gibbed)
	if(stat == DEAD)
		return

	for(var/mob/living/carbon/C in GLOB.alive_mob_list)
		if(C == src) //Make sure not to proc it on ourselves.
			continue
		var/obj/item/organ/alien/hivenode/node = C.get_organ_by_type(/obj/item/organ/alien/hivenode)
		if(istype(node)) // just in case someone would ever add a diffirent node to hivenode slot
			node.queen_death()

			// (original duration was extremely long and i couldnt find the code for it)
			addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(remove_queen_panic_debuff), C), 300 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE)

	return ..()

// Helper proc to clean up the queen death panic debuff from a xenomorph
/proc/remove_queen_panic_debuff(mob/living/carbon/target)
	if(!target)
		return
	// Attempt to remove common status effects applied by queen_death()
	// Adjust effect names to match your codebase if different.
	target.remove_status_effect(/datum/status_effect/queen_death_backlash)
	target.remove_status_effect(/datum/status_effect/queen_death_slow)
	target.remove_status_effect(/datum/status_effect/queen_death_stamina)
	// If the debuff applies a movespeed modifier, remove it as well
	target.remove_movespeed_modifier(/datum/movespeed_modifier/queen_death)
	// Optional: remove any trait applied by the queen's death
	if(HAS_TRAIT(target, TRAIT_QUEEN_DEATH_PANIC))
		REMOVE_TRAIT(target, TRAIT_QUEEN_DEATH_PANIC, "queen_death")
