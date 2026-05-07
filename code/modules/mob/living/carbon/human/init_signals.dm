/mob/living/carbon/human/register_init_signals()
	. = ..()

	RegisterSignals(src, list(SIGNAL_ADDTRAIT(TRAIT_UNKNOWN_APPEARANCE), SIGNAL_REMOVETRAIT(TRAIT_UNKNOWN_APPEARANCE)), PROC_REF(on_unknown_appearance_trait))

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_TRACKED_SENSORS), PROC_REF(add_to_suit_sensors))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_TRACKED_SENSORS), PROC_REF(remove_from_suit_sensors))

/// Gaining or losing [TRAIT_UNKNOWN_APPEARANCE] updates our name and our sechud
/mob/living/carbon/human/proc/on_unknown_appearance_trait(datum/source)
	SIGNAL_HANDLER

	name = get_visible_name()
	sec_hud_set_ID()

/// Called when [TRAIT_TRACKED_SENSORS] is added to the mob.
/mob/living/carbon/human/proc/add_to_suit_sensors(datum/source)
	SIGNAL_HANDLER
	GLOB.suit_sensors_list |= src

/// Called when [TRAIT_TRACKED_SENSORS] is removed from the mob.
/mob/living/carbon/human/proc/remove_from_suit_sensors(datum/source)
	SIGNAL_HANDLER
	GLOB.suit_sensors_list -= src
