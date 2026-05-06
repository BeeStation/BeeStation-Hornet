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

	burrow_usage_flags = LEECH_ABILITY_USABLE_ALWAYS

/datum/action/leech/chemical_inject/on_activate(mob/user, atom/target, trigger_flags)
	return TRUE
