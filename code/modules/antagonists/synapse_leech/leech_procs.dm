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

	if(substrate <= 0)
		return

	// If we are over 5 substrate, we just apply as normal.
	if(substrate > 5)
		living_target.reagents.add_reagent(toxin_type, LEECH_TOXIN_PER_ATTACK)
		adjust_substrate(-LEECH_TOXIN_PER_ATTACK)
	else
		// We have more than 0 substrate, but less than 5.
		living_target.reagents.add_reagent(toxin_type, substrate)
		adjust_substrate(-substrate)

/// Cleans up host references and signals. Call when emerging, or if the host is destroyed.
/mob/living/basic/synapse_leech/proc/clear_host_state()
	if(host)
		UnregisterSignal(host, list(COMSIG_QDELETING, COMSIG_LIVING_DEATH))
	host = null
	nested = FALSE

/// Handles the host being qdeleted while we're inside. Drop us where they were, if possible.
/mob/living/basic/synapse_leech/proc/on_host_qdel(datum/source)
	SIGNAL_HANDLER
	var/turf/exit = get_turf(source)
	if(exit)
		forceMove(exit)
	clear_host_state()

/// Handles the host dying while we're inside.
/mob/living/basic/synapse_leech/proc/on_host_death(datum/source)
	SIGNAL_HANDLER
	to_chat(src, span_userdanger("Your host has died. Their nervous system is going cold around you."))
