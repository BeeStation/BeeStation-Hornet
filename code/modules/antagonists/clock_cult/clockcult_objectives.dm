/datum/objective/clockcult
	name = "serve Rat'var"
	explanation_text = "Protect the Celestial Gateway so that Rat'var may enlighten this world!"

/datum/objective/clockcult/check_completion()
	return GLOB.ratvar_risen
