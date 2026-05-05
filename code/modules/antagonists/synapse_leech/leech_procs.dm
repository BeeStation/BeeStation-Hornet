/// Adjusts saturation by an amount and updates the HUD display.
/mob/living/basic/synapse_leech/proc/adjust_saturation(amount)
	saturation = clamp(saturation + amount, 0, LEECH_MAX_SATURATION)
	update_saturation_display()

/// Adjusts substrate by an amount and updates the HUD display.
/mob/living/basic/synapse_leech/proc/adjust_substrate(amount)
	substrate = clamp(substrate + amount, 0, max_substrate)
	update_substrate_display()

// Leech toxin proc, called on the leech mob after a successful attack to apply toxin to the target.
/mob/living/basic/synapse_leech/proc/do_leech_toxin(mob/living/element_owner, atom/target, success)
	SIGNAL_HANDLER

	if(!success || !isliving(target))
		return

	var/mob/living/living_target = target
	if(living_target.stat == DEAD)
		return

	if(!living_target.reagents)
		return

	if(HAS_TRAIT(living_target, TRAIT_PIERCEIMMUNE))
		return

	living_target.reagents.add_reagent(toxin_type, rand(0, toxin_per_attack))
