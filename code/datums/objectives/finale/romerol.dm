/datum/objective/romerol
	name = "romerol"
	explanation_text = "Obtain and release the highly feared and restricted romerol toxin."
	murderbone_flag = TRUE
	var/released = FALSE

/datum/objective/romerol/check_completion()
	return released
