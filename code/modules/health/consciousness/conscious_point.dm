/datum/consciousness/point

/datum/consciousness/point/New(mob/living/owner)
	. = ..()
	// By default, using a point system our health is just our damage
	set_consciousness_source(owner.maxHealth, FROM_HITPOINTS)

/datum/consciousness/point/register_signals(mob/living/owner)
	..()
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
	var/new_consciousness = (owner.health / owner.maxHealth) * 100
	if (new_consciousness != value)
		set_consciousness_source(new_consciousness, FROM_HITPOINTS)

/// Calculate our crit and death status when our consciousness updates
/datum/consciousness/point/update_consciousness(consciousness_value)
	..()
	if (HAS_TRAIT(owner, TRAIT_GODMODE))
		return
	if (owner.stat != DEAD)
		if(consciousness_value <= HEALTH_THRESHOLD_DEAD && !HAS_TRAIT(owner, TRAIT_NODEATH))
			owner.death()
			return
		if(consciousness_value <= owner.hardcrit_threshold && !HAS_TRAIT(owner, TRAIT_NOHARDCRIT))
			owner.set_stat_source(HARD_CRIT, FROM_CONSCIOUSNESS)
		else if(HAS_TRAIT(owner, TRAIT_KNOCKEDOUT))
			owner.set_stat_source(UNCONSCIOUS, FROM_CONSCIOUSNESS)
		else if(consciousness_value <= owner.crit_threshold && !HAS_TRAIT(owner, TRAIT_NOSOFTCRIT))
			owner.set_stat_source(SOFT_CRIT, FROM_CONSCIOUSNESS)
		else
			owner.clear_stat(FROM_CONSCIOUSNESS)
