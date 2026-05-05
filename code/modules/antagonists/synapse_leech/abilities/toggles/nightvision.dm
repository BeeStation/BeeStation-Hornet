/**
 * # Nightvision
 * Toggle ability that cycles between dim ambient sight and full darkvision.
 */
/datum/action/leech/toggled/nightvision
	name = "Toggle Darkvision"
	desc = "Sharpen your sight to see clearly in total darkness."
	power_explanation = "Toggle between baseline and full darkvision."
	button_icon_state = "nightvision"
	cooldown_time = 1 SECONDS

/datum/action/leech/toggled/nightvision/activate_toggle(mob/living/basic/synapse_leech/leech)
	leech.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	leech.update_sight()
	to_chat(leech, span_notice("Your sight pierces the dark."))
	return TRUE

/datum/action/leech/toggled/nightvision/deactivate_toggle(mob/living/basic/synapse_leech/leech)
	leech.lighting_alpha = initial(leech.lighting_alpha)
	leech.update_sight()
	to_chat(leech, span_notice("Your eyes settle back into their normal sensitivity."))
