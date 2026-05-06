/**
 * # Synapse Leech Abilities
 *
 * The base action class for all synapse leech abilities. Modeled loosely on the vampire power
 * system, but stripped down to fit my tiny smooth brain
 *
 * Abilities should:
 *   - Set substrate_cost / saturation_cost / cooldown_time as appropriate.
 *   - Override on_activate() to actually do the thing.
 *   - For toggled effects, subtype /datum/action/leech/toggled.
 *   - For click-targeted effects, subtype /datum/action/leech/targeted.
 *
 * Granting is done in /mob/living/basic/synapse_leech/Initialize() using GRANT_ACTION().
 */
/datum/action/leech
	abstract_type = /datum/action/leech
	name = "Leech Action"
	desc = "A leechy action."
	background_icon = 'icons/synapse_leech/actions.dmi'
	background_icon_state = "default"
	button_icon = 'icons/synapse_leech/actions.dmi'
	button_icon_state = "default"
	check_flags = AB_CHECK_CONSCIOUS

	/// Substrate consumed when the ability is activated.
	var/substrate_cost = 0
	/// Saturation consumed when the ability is activated.
	var/saturation_cost = 0
	/// One-line tutorial / explanation text shown in the ability description.
	var/power_explanation
	/**
	 * Bitfield controlling when this ability is usable based on burrow state
	 * If the leech's current state is not allowed, the button is greyed out
	 */
	var/burrow_usage_flags = LEECH_ABILITY_USABLE_UNBURROWED

/datum/action/leech/New(Target)
	. = ..()
	update_desc()

/// Convenience: returns our owner as a synapse leech, or null.
/datum/action/leech/proc/get_leech()
	return istype(owner, /mob/living/basic/synapse_leech) ? owner : null

/// Convenience: returns the leech's host, or null.
/datum/action/leech/proc/get_host()
	var/mob/living/basic/synapse_leech/leech = get_leech()
	return leech ? leech.host : null

/// Builds the description string from the ability's costs and explanation.
/datum/action/leech/proc/update_desc()
	var/list/parts = list()
	if(initial(desc))
		parts += initial(desc)
	if(power_explanation)
		parts += power_explanation
	if(substrate_cost > 0)
		parts += "<b>Substrate cost:</b> [substrate_cost]"
	if(saturation_cost > 0)
		parts += "<b>Saturation cost:</b> [saturation_cost]"
	if(cooldown_time > 0)
		parts += "<b>Cooldown:</b> [cooldown_time / 10]s"
	desc = parts.Join("<br>")

/// Checks whether the leech can afford the activation costs. Shows feedback to the owner.
/datum/action/leech/proc/can_pay_cost(feedback = TRUE)
	var/mob/living/basic/synapse_leech/leech = get_leech()
	if(!leech)
		return FALSE
	if(substrate_cost > 0 && leech.substrate < substrate_cost)
		if(feedback)
			leech.balloon_alert(leech, "not enough substrate!")
		return FALSE
	if(saturation_cost > 0 && leech.saturation < saturation_cost)
		if(feedback)
			leech.balloon_alert(leech, "too hungry!")
		return FALSE
	return TRUE

/// Spends the activation costs. Should only be called after can_pay_cost() returns TRUE.
/datum/action/leech/proc/pay_cost()
	var/mob/living/basic/synapse_leech/leech = get_leech()
	if(!leech)
		return
	if(substrate_cost > 0)
		leech.adjust_substrate(-substrate_cost)
	if(saturation_cost > 0)
		leech.adjust_saturation(-saturation_cost)

/// Override of the action availability check. We want to additionally require a leech owner.
/datum/action/leech/is_available(feedback = FALSE)
	. = ..()
	if(!.)
		return
	var/mob/living/basic/synapse_leech/leech = get_leech()
	if(!leech)
		return FALSE
	// Burrow-state gating: greys out the button (and blocks activation) when the
	// ability isn't allowed in the leech's current nested state.
	if(leech.nested)
		if(!(burrow_usage_flags & LEECH_ABILITY_USABLE_BURROWED))
			if(feedback)
				leech.balloon_alert(leech, "burrowed!")
			return FALSE
	else
		if(!(burrow_usage_flags & LEECH_ABILITY_USABLE_UNBURROWED))
			if(feedback)
				leech.balloon_alert(leech, "must be burrowed!")
			return FALSE
	return TRUE
