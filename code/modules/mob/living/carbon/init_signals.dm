/mob/living/carbon/register_init_signals()
	. = ..()
	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_GENELESS), PROC_REF(on_geneless_trait_gain))

/**
 * On gain of TRAIT_GENELLESS
 *
 * This will clear all DNA mutations on on the mob.
 */
/mob/living/carbon/proc/on_geneless_trait_gain(datum/source)
	SIGNAL_HANDLER

	dna?.remove_all_mutations()
