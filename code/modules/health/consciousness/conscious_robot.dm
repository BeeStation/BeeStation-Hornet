/**

Point consciousness: Robot

This is a special type where being knocked out, stunned, or paralyzed
causes crit.

*/

/datum/consciousness/point/robot

/datum/consciousness/point/robot/register_signals(mob/living/owner)
	// Knockout affects stat
	RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_KNOCKEDOUT), PROC_REF(update_stat))
	RegisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_KNOCKEDOUT), PROC_REF(update_stat))
	// Paralysis affects stat
	RegisterSignal(owner, SIGNAL_ADD_STATUS_EFFECT(/datum/status_effect/incapacitating/paralyzed), PROC_REF(update_stat))
	RegisterSignal(owner, SIGNAL_REMOVE_STATUS_EFFECT(/datum/status_effect/incapacitating/paralyzed), PROC_REF(update_stat))
	// Stun affects stat
	RegisterSignal(owner, SIGNAL_ADD_STATUS_EFFECT(/datum/status_effect/incapacitating/stun), PROC_REF(update_stat))
	RegisterSignal(owner, SIGNAL_REMOVE_STATUS_EFFECT(/datum/status_effect/incapacitating/stun), PROC_REF(update_stat))
	// Knockdown affects stat
	RegisterSignal(owner, SIGNAL_ADD_STATUS_EFFECT(/datum/status_effect/incapacitating/knockdown), PROC_REF(update_stat))
	RegisterSignal(owner, SIGNAL_REMOVE_STATUS_EFFECT(/datum/status_effect/incapacitating/knockdown), PROC_REF(update_stat))

/datum/consciousness/point/robot/update_consciousness(consciousness_value)
	..()
	if (owner.status_flags & GODMODE)
		return
	if (owner.stat != DEAD)
		if (consciousness_value <= 0)
			owner.death()
		else if(HAS_TRAIT(owner, TRAIT_KNOCKEDOUT) || owner.IsStun() || owner.IsKnockdown() || owner.IsParalyzed())
			owner.set_stat(UNCONSCIOUS)
		else
			owner.set_stat(CONSCIOUS)
