/mob/living/carbon/human/register_init_signals()
	. = ..()

	//Traits that register add only
	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_NOBREATH), PROC_REF(on_nobreath_trait_gain))
	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_LIVERLESS_METABOLISM), PROC_REF(on_liverless_metabolism_trait_gain))
	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_VIRUSIMMUNE), PROC_REF(on_virusimmune_trait_gain))
	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_TOXIMMUNE), PROC_REF(on_toximmune_trait_gain))
	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_GENELESS), PROC_REF(on_geneless_trait_gain))

	RegisterSignals(src, list(SIGNAL_ADDTRAIT(TRAIT_UNKNOWN), SIGNAL_REMOVETRAIT(TRAIT_UNKNOWN)), PROC_REF(on_unknown_trait))

	RegisterSignals(src, list(SIGNAL_ADDTRAIT(TRAIT_FAT), SIGNAL_REMOVETRAIT(TRAIT_FAT)), PROC_REF(on_fat))

/// Gaining or losing [TRAIT_UNKNOWN] updates our name and our sechud
/mob/living/carbon/human/proc/on_unknown_trait(datum/source)
	SIGNAL_HANDLER

	name = get_visible_name()
	sec_hud_set_ID()

/**
 * On gain of TRAIT_NOBREATH
 *
 * This will clear all alerts and moods related to breathing.
 */
/mob/living/carbon/proc/on_nobreath_trait_gain(datum/source)
	SIGNAL_HANDLER

	setOxyLoss(0, updating_health = TRUE, forced = TRUE)
	losebreath = 0
	failed_last_breath = FALSE

	clear_alert(ALERT_TOO_MUCH_OXYGEN)
	clear_alert(ALERT_NOT_ENOUGH_OXYGEN)

	clear_alert(ALERT_TOO_MUCH_PLASMA)
	clear_alert(ALERT_NOT_ENOUGH_PLASMA)

	clear_alert(ALERT_TOO_MUCH_NITRO)
	clear_alert(ALERT_NOT_ENOUGH_NITRO)

	clear_alert(ALERT_TOO_MUCH_CO2)
	clear_alert(ALERT_NOT_ENOUGH_CO2)

	clear_alert(ALERT_TOO_MUCH_N2O)
	clear_alert(ALERT_NOT_ENOUGH_N2O)

	SEND_SIGNAL(src, COMSIG_CLEAR_MOOD_EVENT, "chemical_euphoria")
	SEND_SIGNAL(src, COMSIG_CLEAR_MOOD_EVENT, "smell")
	SEND_SIGNAL(src, COMSIG_CLEAR_MOOD_EVENT, "suffocation")

/**
 * On gain of TRAIT_LIVERLESS_METABOLISM
 *
 * This will clear all moods related to addictions and stop metabolization.
 */
/mob/living/carbon/proc/on_liverless_metabolism_trait_gain(datum/source)
	SIGNAL_HANDLER

	for(var/addiction_type in GLOB.addictions)
		mind?.remove_addiction_points(addiction_type, MAX_ADDICTION_POINTS) //Remove the addiction!

	reagents.end_metabolization(keep_liverless = TRUE)

/**
 * On gain of TRAIT_VIRUSIMMUNE
 *
 * This will clear all diseases on the mob.
 */
/mob/living/carbon/proc/on_virusimmune_trait_gain(datum/source)
	SIGNAL_HANDLER

	for(var/datum/disease/disease as anything in diseases)
		disease.cure(FALSE)

/**
 * On gain of TRAIT_TOXIMMUNE
 *
 * This will clear all toxin damage on the mob.
 */
/mob/living/carbon/proc/on_toximmune_trait_gain(datum/source)
	SIGNAL_HANDLER

	setToxLoss(0, updating_health = TRUE, forced = TRUE)

/**
 * On gain of TRAIT_GENELLESS
 *
 * This will clear all DNA mutations on the mob.
 */
/mob/living/carbon/proc/on_geneless_trait_gain(datum/source)
	SIGNAL_HANDLER

	dna?.remove_all_mutations()

/mob/living/carbon/human/proc/on_fat(datum/source)
	SIGNAL_HANDLER

	if(HAS_TRAIT(src, TRAIT_FAT))
		add_movespeed_modifier(/datum/movespeed_modifier/obesity)
	else
		remove_movespeed_modifier(/datum/movespeed_modifier/obesity)
