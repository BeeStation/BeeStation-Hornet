/datum/objective/clockcult
	name = "Serve Rat'var"
	explanation_text = "Serve the will of Rat'Var by summoning releasing it from its prison."

/datum/objective/clockcult/check_completion()
	return GLOB.ratvar_risen || ..()
