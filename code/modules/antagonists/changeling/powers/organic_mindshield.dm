/datum/action/changeling/organic_mindshield
	name = "Organic Mindshield"
	desc = "We emit a constant frequency matching that of a mindshield, fooling security HUDs into thinking we are mindshielded."
	button_icon_state = "mindshield"
	helptext = "Will cause you to appear to have a mindshield on security HUDs. Maintaining uses 1 chemical every 3 seconds. Does not work while on fire."
	chemical_cost = 0
	dna_cost = 1
	req_human = TRUE

/datum/action/changeling/organic_mindshield/sting_action(mob/living/user)
	..()

	if(!user.has_status_effect(/datum/status_effect/changeling/mindshield))
		user.apply_status_effect(/datum/status_effect/changeling/mindshield)
	else
		user.remove_status_effect(/datum/status_effect/changeling/mindshield)
	return TRUE

/datum/action/changeling/organic_mindshield/Remove(mob/living/user)
	user.remove_status_effect(/datum/status_effect/changeling/mindshield)
	..()
