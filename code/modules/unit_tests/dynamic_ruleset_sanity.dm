/// Verifies that roundstart dynamic rulesets are setup properly without external configuration.
/datum/unit_test/dynamic_roundstart_ruleset_sanity

/datum/unit_test/dynamic_roundstart_ruleset_sanity/Run()
	// Roundstart
	for(var/datum/dynamic_ruleset/roundstart/ruleset as anything in subtypesof(/datum/dynamic_ruleset/roundstart))
		var/name = initial(ruleset.name)

		// Name
		if(!name)
			TEST_FAIL("[ruleset] has no name!")

		// These rulesets don't spawn antags and are exempt.
		if(name == "Extended" || name == "Meteor")
			continue

		// Antag datum
		var/datum/antagonist/antag_datum = initial(ruleset.antag_datum)
		if(!ispath(antag_datum, /datum/antagonist) || !initial(antag_datum.banning_key))
			TEST_FAIL("[ruleset] has no antag_datum with a banning key!")

		// Role preference
		var/role_pref = initial(ruleset.role_preference)
		if(!role_pref || !ispath(role_pref, /datum/role_preference))
			TEST_FAIL("[ruleset] has no role preference!")

	// Midround
	for(var/datum/dynamic_ruleset/midround/ruleset as anything in subtypesof(/datum/dynamic_ruleset/midround) - /datum/dynamic_ruleset/midround/ghost - /datum/dynamic_ruleset/midround/living)

		// Severity
		var/severity = initial(ruleset.severity)
		if(severity != DYNAMIC_MIDROUND_LIGHT && severity != DYNAMIC_MIDROUND_MEDIUM && severity != DYNAMIC_MIDROUND_HEAVY)
			TEST_FAIL("[ruleset] has an invalid severity, the options are: DYNAMIC_MIDROUND_LIGHT, DYNAMIC_MIDROUND_MEDIUM, DYNAMIC_MIDROUND_HEAVY")
