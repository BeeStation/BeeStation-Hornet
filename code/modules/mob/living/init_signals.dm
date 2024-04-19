///Called on /mob/living/Initialize(), for the mob to register to relevant signals.
/mob/living/proc/register_init_signals()
	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_KNOCKEDOUT), PROC_REF(on_knockedout_trait_gain))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_KNOCKEDOUT), PROC_REF(on_knockedout_trait_loss))

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_DEATHCOMA), PROC_REF(on_deathcoma_trait_gain))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_DEATHCOMA), PROC_REF(on_deathcoma_trait_loss))

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_IMMOBILIZED), .proc/on_immobilized_trait_gain)
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_IMMOBILIZED), .proc/on_immobilized_trait_loss)

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_HANDS_BLOCKED), .proc/on_handsblocked_trait_gain)
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_HANDS_BLOCKED), .proc/on_handsblocked_trait_loss)


///Called when TRAIT_KNOCKEDOUT is added to the mob.
/mob/living/proc/on_knockedout_trait_gain(datum/source)
	if(stat < UNCONSCIOUS)
		set_stat(UNCONSCIOUS)

///Called when TRAIT_KNOCKEDOUT is removed from the mob.
/mob/living/proc/on_knockedout_trait_loss(datum/source)
	if(stat < DEAD)
		update_stat()


///Called when TRAIT_DEATHCOMA is added to the mob.
/mob/living/proc/on_deathcoma_trait_gain(datum/source)
	ADD_TRAIT(src, TRAIT_KNOCKEDOUT, TRAIT_DEATHCOMA)

///Called when TRAIT_DEATHCOMA is removed from the mob.
/mob/living/proc/on_deathcoma_trait_loss(datum/source)
	REMOVE_TRAIT(src, TRAIT_KNOCKEDOUT, TRAIT_DEATHCOMA)

///Called when TRAIT_IMMOBILIZED is added to the mob.
/mob/living/proc/on_immobilized_trait_gain(datum/source)
	mobility_flags &= ~MOBILITY_MOVE

///Called when TRAIT_IMMOBILIZED is removed from the mob.
/mob/living/proc/on_immobilized_trait_loss(datum/source)
	mobility_flags |= MOBILITY_MOVE


///Called when TRAIT_HANDS_BLOCKED is added to the mob.
/mob/living/proc/on_handsblocked_trait_gain(datum/source)
	mobility_flags &= ~(MOBILITY_USE | MOBILITY_PICKUP | MOBILITY_STORAGE)
	drop_all_held_items()

///Called when TRAIT_HANDS_BLOCKED is removed from the mob.
/mob/living/proc/on_handsblocked_trait_loss(datum/source)
	mobility_flags |= (MOBILITY_USE | MOBILITY_PICKUP | MOBILITY_STORAGE)
