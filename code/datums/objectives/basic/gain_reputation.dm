/datum/objective/gain_reputation
	name = "Gain Reputation"
	explanation_text = "Gain at least 800 reputation."

/datum/objective/gain_reputation/check_completion()
	var/list/objective_owners = get_owners()
	for (var/datum/component/uplink/uplink as anything in GLOB.uplinks)
		if (!(uplink.owner in objective_owners))
			continue
		if (uplink.reputation >= target_amount)
			return TRUE
	return ..()

/datum/objective/gain_reputation/update_explanation_text()
	explanation_text = "Gain at least [target_amount] reputation by completing priority directives."
