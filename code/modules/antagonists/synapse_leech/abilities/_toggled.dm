/**
 * # Toggled Leech Ability
 *
 * Base class for leech abilities that have a sustained "on" state. Activation pays the upfront
 * costs (substrate_cost / saturation_cost) and starts an ongoing effect; clicking the button
 * again, or running out of resources, deactivates it.
 *
 * Subclasses should override:
 *   - activate_toggle(mob/living/basic/synapse_leech/leech) called when turned on
 *   - deactivate_toggle(mob/living/basic/synapse_leech/leech) called when turned off
 *   - tick_toggle(mob/living/basic/synapse_leech/leech, delta_time) called every Life tick while on
 *
 * Constant per-second resource drains are charged automatically via continuous_substrate_cost
 * and continuous_saturation_cost (in points-per-second).
 */
/datum/action/leech/toggled
	abstract_type = /datum/action/leech/toggled
	toggleable = TRUE

	/// Substrate drained per second while toggled on.
	var/continuous_substrate_cost = 0
	/// Saturation drained per second while toggled on.
	var/continuous_saturation_cost = 0
	/// Background icon used while toggled active.
	var/background_icon_state_on = "default_on"
	/// Background icon used while toggled inactive (default).
	var/background_icon_state_off = "default"

/datum/action/leech/toggled/update_desc()
	. = ..()
	var/list/extras = list()
	if(continuous_substrate_cost > 0)
		extras += "<b>Upkeep:</b> [continuous_substrate_cost] substrate / sec"
	if(continuous_saturation_cost > 0)
		extras += "<b>Upkeep:</b> [continuous_saturation_cost] saturation / sec"
	if(length(extras))
		desc = "[desc][desc ? "<br>" : ""][extras.Join("<br>")]"

/datum/action/leech/toggled/on_activate(mob/user, atom/target, trigger_flags)
	// Toggleable actions call deactivate() automatically on a second click; we only handle "turning on" here.
	var/mob/living/basic/synapse_leech/leech = get_leech()
	if(!leech)
		return FALSE
	if(!can_pay_cost())
		return FALSE
	pay_cost()
	if(!activate_toggle(leech))
		return FALSE
	background_icon_state = background_icon_state_on
	update_buttons()
	RegisterSignal(leech, COMSIG_LIVING_LIFE, PROC_REF(on_life_tick))
	start_cooldown()
	return TRUE

/datum/action/leech/toggled/on_deactivate(mob/user, atom/target)
	var/mob/living/basic/synapse_leech/leech = get_leech()
	if(leech)
		UnregisterSignal(leech, COMSIG_LIVING_LIFE)
		deactivate_toggle(leech)
	background_icon_state = background_icon_state_off
	update_buttons()

/// Hook for subclasses; return TRUE if activation succeeded.
/datum/action/leech/toggled/proc/activate_toggle(mob/living/basic/synapse_leech/leech)
	return TRUE

/// Hook for subclasses to clean up when toggled off.
/datum/action/leech/toggled/proc/deactivate_toggle(mob/living/basic/synapse_leech/leech)
	return

/// Hook for subclasses for per-tick effects. Return FALSE to force-deactivate.
/datum/action/leech/toggled/proc/tick_toggle(mob/living/basic/synapse_leech/leech, delta_time)
	return TRUE

/datum/action/leech/toggled/proc/on_life_tick(mob/living/basic/synapse_leech/leech, delta_time, times_fired)
	SIGNAL_HANDLER
	if(!active)
		return
	// Continuous costs.
	if(continuous_substrate_cost > 0)
		if(leech.substrate < continuous_substrate_cost * delta_time)
			leech.balloon_alert(leech, "out of substrate!")
			deactivate(leech)
			return
		leech.adjust_substrate(-continuous_substrate_cost * delta_time)
	if(continuous_saturation_cost > 0)
		if(leech.saturation <= LEECH_MIN_SATURATION)
			leech.balloon_alert(leech, "too hungry!")
			deactivate(leech)
			return
		leech.adjust_saturation(-continuous_saturation_cost * delta_time)

	if(!tick_toggle(leech, delta_time))
		deactivate(leech)
