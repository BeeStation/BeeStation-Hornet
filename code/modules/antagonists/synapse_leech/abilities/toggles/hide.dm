/**
 * # Hide
 *
 * Toggled ability. While active, the leech drops to a low layer (slipping under tables /
 * objects) and constantly drains saturation. Used to ambush prey or evade pursuit.
 */
/datum/action/leech/toggled/hide
	name = "Hide"
	desc = "Slip beneath tables and other obstacles."
	power_explanation = "Toggle to drop your visual layer and pass under most objects. Drains saturation while active."
	button_icon_state = "hide"
	background_icon_state_on = "default_on"

	cooldown_time = 1 SECONDS
	continuous_saturation_cost = LEECH_HIDE_SATURATION_DRAIN

	/// Layer we adopt while hidden.
	var/static/hidden_layer = ABOVE_NORMAL_TURF_LAYER

/datum/action/leech/toggled/hide/activate_toggle(mob/living/basic/synapse_leech/leech)
	leech.hidden = TRUE
	leech.layer = hidden_layer
	leech.visible_message(
		span_notice("[leech] flattens itself against the floor."),
		span_notice("You flatten yourself against the floor, slipping into the cracks."),
	)
	return TRUE

/datum/action/leech/toggled/hide/deactivate_toggle(mob/living/basic/synapse_leech/leech)
	leech.hidden = FALSE
	leech.layer = initial(leech.layer)
	leech.visible_message(
		span_notice("[leech] uncoils back to its full height."),
		span_notice("You rise back up."),
	)
