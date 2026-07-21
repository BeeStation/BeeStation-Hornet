/datum/objective/brainwash_targets
	name = "brainwash targets"
	explanation_text = "Brainwash at least %GOALS% members of the crew and have them stage a terrorist attack against the station."
	murderbone_flag = TRUE
	var/amount = 0

/datum/objective/brainwash_targets/proc/generate_amount()
	// 5-10% of the crew
	var/target = ceil(SSjob.initial_players_to_assign * rand(5, 10) * 0.01)
	target_amount = target
	update_explanation_text()

/datum/objective/brainwash_targets/update_explanation_text()
	. = ..()
	explanation_text = replacetext(initial(explanation_text), "%GOAL%", amount)

/datum/objective/brainwash_targets/check_completion()
	return amount >= target_amount
