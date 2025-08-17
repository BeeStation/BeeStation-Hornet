
/datum/consciousness/organic

/datum/consciousness/organic/register_signals(mob/living/owner)
	..()
	RegisterSignal(owner, COMSIG_MOB_BRAIN_CONSCIOUSNESS_UPDATE, PROC_REF(consciousness_update))
	RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_NODEATH), PROC_REF(update_stat))
	RegisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_NODEATH), PROC_REF(update_stat))
	RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_NOHARDCRIT), PROC_REF(update_stat))
	RegisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_NOHARDCRIT), PROC_REF(update_stat))
	RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_NOSOFTCRIT), PROC_REF(update_stat))
	RegisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_NOSOFTCRIT), PROC_REF(update_stat))
	RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_KNOCKEDOUT), PROC_REF(update_stat))
	RegisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_KNOCKEDOUT), PROC_REF(update_stat))

/datum/consciousness/organic/proc/consciousness_update(datum/source, consciousness_rating)
	set_consciousness_source(consciousness_rating, FROM_BRAIN)

/datum/consciousness/organic/consciousness_tick(delta_time)
	if (DT_PROB(3, delta_time) && value < max_value - 70)
		to_chat(owner, span_pain("You feel like you are about to pass out!"))
	else if (DT_PROB(2, delta_time) && value < max_value - 30)
		to_chat(owner, span_pain("You feel lightheaded..."))

/datum/consciousness/organic/update_consciousness(consciousness_value)
	..()
	if (owner.status_flags & GODMODE)
		return
	if (owner.stat != DEAD)
		if(consciousness_value <= HEALTH_THRESHOLD_DEAD && !HAS_TRAIT(owner, TRAIT_NODEATH))
			owner.death()
			return
		if(consciousness_value <= HEALTH_THRESHOLD_FULLCRIT && !HAS_TRAIT(owner, TRAIT_NOHARDCRIT))
			owner.set_stat(HARD_CRIT)
		else if(HAS_TRAIT(owner, TRAIT_KNOCKEDOUT))
			owner.set_stat(UNCONSCIOUS)
		else if(consciousness_value <= HEALTH_THRESHOLD_CRIT && !HAS_TRAIT(owner, TRAIT_NOSOFTCRIT))
			owner.set_stat(SOFT_CRIT)
		else
			owner.set_stat(CONSCIOUS)
