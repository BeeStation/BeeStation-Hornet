/datum/consciousness/point

/datum/consciousness/point/New(mob/living/owner)
	. = ..()
	// By default, using a point system our health is just our damage
	set_consciousness_source(FROM_HITPOINTS, owner.maxHealth)

/datum/consciousness/point/register_signals(mob/living/owner)
	// No death affects stat
	RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_NODEATH), PROC_REF(update_stat))
	RegisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_NODEATH), PROC_REF(update_stat))
	RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_NOHARDCRIT), PROC_REF(update_stat))
	RegisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_NOHARDCRIT), PROC_REF(update_stat))
	RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_NOSOFTCRIT), PROC_REF(update_stat))
	RegisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_NOSOFTCRIT), PROC_REF(update_stat))
	RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_KNOCKEDOUT), PROC_REF(update_stat))
	RegisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_KNOCKEDOUT), PROC_REF(update_stat))

/datum/consciousness/point/consciousness_tick(delta_time)
	// Continuously just become the hitpoints of our owner
	set_consciousness_source(FROM_HITPOINTS, owner.health)

/// Calculate our crit and death status when our consciousness updates
/datum/consciousness/point/update_consciousness(consciousness_value)
	if (owner.status_flags & GODMODE)
		return
	if (owner.stat != DEAD)
		if(consciousness_value <= HEALTH_THRESHOLD_DEAD && !HAS_TRAIT(owner, TRAIT_NODEATH))
			owner.death()
			return
		if(consciousness_value <= owner.hardcrit_threshold && !HAS_TRAIT(owner, TRAIT_NOHARDCRIT))
			owner.set_stat(HARD_CRIT)
		else if(HAS_TRAIT(owner, TRAIT_KNOCKEDOUT))
			owner.set_stat(UNCONSCIOUS)
		else if(consciousness_value <= owner.crit_threshold && !HAS_TRAIT(owner, TRAIT_NOSOFTCRIT))
			owner.set_stat(SOFT_CRIT)
		else
			owner.set_stat(CONSCIOUS)
