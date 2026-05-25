/mob/living/carbon/human/register_init_signals()
	. = ..()

	RegisterSignals(src, list(SIGNAL_ADDTRAIT(TRAIT_UNKNOWN_APPEARANCE), SIGNAL_REMOVETRAIT(TRAIT_UNKNOWN_APPEARANCE)), PROC_REF(on_unknown_appearance_trait))

/// Gaining or losing [TRAIT_UNKNOWN_APPEARANCE] updates our name and our sechud
/mob/living/carbon/human/proc/on_unknown_appearance_trait(datum/source)
	SIGNAL_HANDLER

	name = get_visible_name()
	sec_hud_set_ID()
