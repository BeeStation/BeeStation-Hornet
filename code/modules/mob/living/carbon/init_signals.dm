//Called on /mob/living/carbon/Initialize(mapload), for the carbon mobs to register relevant signals.
/mob/living/carbon/register_init_signals()
	. = ..()

	//Traits that register add and remove
	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_AGENDER), PROC_REF(on_agender_trait_gain))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_AGENDER), PROC_REF(on_agender_trait_loss))
	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_NO_MOUTH), PROC_REF(on_no_mouth_trait_gain))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_NO_MOUTH), PROC_REF(on_no_mouth_trait_loss))
	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_SOFT_CRITICAL_CONDITION), PROC_REF(on_softcrit_gain))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_SOFT_CRITICAL_CONDITION), PROC_REF(on_softcrit_loss))
	RegisterSignals(src, list(SIGNAL_ADDTRAIT(TRAIT_STAMINA_DRAINS_POWER), SIGNAL_REMOVETRAIT(TRAIT_STAMINA_DRAINS_POWER)), PROC_REF(on_stamina_drains_power_trait_change))
	RegisterSignals(src, list(SIGNAL_ADDTRAIT(TRAIT_NOSTAMCRIT), SIGNAL_REMOVETRAIT(TRAIT_NOSTAMCRIT)), PROC_REF(on_nostamcrit_trait_change))

	//Traits that register add only
	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_NOBREATH), PROC_REF(on_nobreath_trait_gain))
	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_LIVERLESS_METABOLISM), PROC_REF(on_liverless_metabolism_trait_gain))
	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_VIRUSIMMUNE), PROC_REF(on_virusimmune_trait_gain))
	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_TOXIMMUNE), PROC_REF(on_toximmune_trait_gain))
	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_GENELESS), PROC_REF(on_geneless_trait_gain))


/**
 * On gain of TRAIT_AGENDER
 *
 * This will make the mob get it's gender set to PLURAL.
 */
/mob/living/carbon/proc/on_agender_trait_gain(datum/source)
	SIGNAL_HANDLER

	gender = PLURAL

/**
 * On removal of TRAIT_AGENDER
 *
 * This will make the mob get it's gender set to whatever the DNA says it should be.
 */
/mob/living/carbon/proc/on_agender_trait_loss(datum/source)
	SIGNAL_HANDLER

	//updates our gender to be whatever our DNA wants it to be
	switch(deconstruct_block(get_uni_identity_block(dna.unique_identity, DNA_GENDER_BLOCK), 3) || pick(G_MALE, G_FEMALE))
		if(G_MALE)
			gender = MALE
		if(G_FEMALE)
			gender = FEMALE
		else
			gender = PLURAL

/**
 * On gain of TRAIT_NO_MOUTH
 *
 * I have no mouth and I must sob
 */
/mob/living/carbon/proc/on_no_mouth_trait_gain(datum/source)
	SIGNAL_HANDLER

	for(var/obj/item/bodypart/head/head in bodyparts)
		head.mouth = FALSE

/**
 * On gain of TRAIT_NO_MOUTH
 *
 * Waaaaah 😭
 */
/mob/living/carbon/proc/on_no_mouth_trait_loss(datum/source)
	SIGNAL_HANDLER

	for(var/obj/item/bodypart/head/head in bodyparts)
		head.mouth = TRUE

/mob/living/carbon/proc/on_softcrit_gain(datum/source)
	SIGNAL_HANDLER
	stamina.add_max_modifier("softcrit", -100)
	stamina.add_regen_modifier("softcrit", -5)
	throw_alert(ALERT_SOFTCRIT, /atom/movable/screen/alert/softcrit)
	add_movespeed_modifier(/datum/movespeed_modifier/carbon_softcrit)

/mob/living/carbon/proc/on_softcrit_loss(datum/source)
	SIGNAL_HANDLER
	stamina.remove_max_modifier("softcrit")
	stamina.remove_regen_modifier("softcrit")
	clear_alert(ALERT_SOFTCRIT)
	remove_movespeed_modifier(/datum/movespeed_modifier/carbon_softcrit)

/// Stamina for carbons/charge for IPCs
/mob/living/carbon/proc/on_stamina_drains_power_trait_change(datum/source)
	SIGNAL_HANDLER
	update_stamina_hud()

/// TRAIT_NOSTAMCRIT blocks exhaustion and ends stamcrit, getting it added or removed queues an update
/mob/living/carbon/proc/on_nostamcrit_trait_change(datum/source)
	SIGNAL_HANDLER
	if(!stamina) //Destroy() deletes stamina before mutations remove their traits
		return
	if(HAS_TRAIT(src, TRAIT_NOSTAMCRIT))
		remove_status_effect(/datum/status_effect/incapacitating/stamcrit)
	on_stamina_update()

/mob/living/carbon/on_incapacitated_trait_gain(datum/source)
	. = ..()
	update_resting_regen()

/mob/living/carbon/on_incapacitated_trait_loss(datum/source)
	. = ..()
	update_resting_regen()

/mob/living/carbon/update_resting()
	. = ..()
	update_resting_regen()

///Resting speeds up stamina regen, but not while incapacitated, so resting through a stun doesn't count.
/mob/living/carbon/proc/update_resting_regen()
	if(!stamina) //Destroy() deletes stamina before status effects remove their traits
		return
	if(resting && !HAS_TRAIT(src, TRAIT_INCAPACITATED))
		stamina.add_regen_multiplier("resting", STAMINA_RESTING_REGEN_MULTIPLIER)
	else
		stamina.remove_regen_multiplier("resting")

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
	for(var/addiction_type in subtypesof(/datum/addiction))
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
 * This will clear all DNA mutations on on the mob.
 */
/mob/living/carbon/proc/on_geneless_trait_gain(datum/source)
	SIGNAL_HANDLER

	dna?.remove_all_mutations()

