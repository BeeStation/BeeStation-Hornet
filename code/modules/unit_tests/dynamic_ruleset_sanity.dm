/// Verifies that roundstart dynamic rulesets are setup properly without external configuration.
/datum/unit_test/dynamic_roundstart_ruleset_sanity

/datum/unit_test/dynamic_roundstart_ruleset_sanity/Run()
	// Roundstart
	for(var/datum/dynamic_ruleset/roundstart/ruleset as anything in subtypesof(/datum/dynamic_ruleset/roundstart))
		if(ruleset == initial(ruleset.abstract_type))
			continue

		// Name
		if(!initial(ruleset.name))
			TEST_FAIL("[ruleset] has no name!")

		// Antag datum
		var/datum/antagonist/antag_datum = initial(ruleset.antag_datum)
		if(!ispath(antag_datum, /datum/antagonist))
			TEST_FAIL("[ruleset] has no antag datum!")
		else if(!initial(antag_datum.banning_key))
			TEST_FAIL("[ruleset] has an antag datum without a banning key!")

		// Role preference
		if(!ispath(initial(ruleset.role_preference), /datum/role_preference))
			TEST_FAIL("[ruleset] has no role preference!")

	// Midround
	for(var/datum/dynamic_ruleset/midround/ruleset as anything in subtypesof(/datum/dynamic_ruleset/midround))
		if(ruleset == initial(ruleset.abstract_type))
			continue

		// Name
		if(!initial(ruleset.name))
			TEST_FAIL("[ruleset] has no name!")

		// Don't check for antag datums because some midround rulesets (Space Pirates) don't directly spawn antagonists.

		// Severity
		var/severity = initial(ruleset.severity)
		if(!severity)
			TEST_FAIL("[ruleset] has an invalid severity!")

	// Latejoin
	for(var/datum/dynamic_ruleset/latejoin/ruleset as anything in subtypesof(/datum/dynamic_ruleset/latejoin))
		if(ruleset == initial(ruleset.abstract_type))
			continue

		// Name
		if(!initial(ruleset.name))
			TEST_FAIL("[ruleset] has no name!")

		// Antag datum
		var/datum/antagonist/antag_datum = initial(ruleset.antag_datum)
		if(!ispath(antag_datum, /datum/antagonist))
			TEST_FAIL("[ruleset] has no antag datum!")
		else if(!initial(antag_datum.banning_key))
			TEST_FAIL("[ruleset] has an antag datum without a banning key!")

		// Role preference
		if(!ispath(initial(ruleset.role_preference), /datum/role_preference))
			TEST_FAIL("[ruleset] has no role preference!")
