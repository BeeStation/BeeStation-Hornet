/**
 * # Chemical Inject
 *
 * TODO
 */
/datum/action/leech/chemical_inject
	name = "Inject Toxin"
	desc = "TODO"
	power_explanation = "TODO"
	button_icon_state = "inject"

	cooldown_time = 10 SECONDS
	substrate_cost = 25

	burrow_usage_flags = LEECH_ABILITY_USABLE_BURROWED

/datum/action/leech/chemical_inject/can_use()
	var/mob/living/basic/synapse_leech/leech = get_leech()
	var/mob/living/carbon/host = get_host()

	if(!leech || !host)
		return FALSE

	if(!leech.nested)
		return FALSE

	return TRUE

/datum/action/leech/chemical_inject/activate_leech_power()
	return TRUE
