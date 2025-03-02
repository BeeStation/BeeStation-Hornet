/// Verifies that roundstart dynamic rulesets are setup properly without external configuration.
/datum/unit_test/dynamic_roundstart_ruleset_sanity

/datum/unit_test/dynamic_roundstart_ruleset_sanity/Run()
	for(var/datum/dynamic_ruleset/roundstart/ruleset as anything in subtypesof(/datum/dynamic_ruleset/roundstart))
		var/name = initial(ruleset.name)
		if(!name)
			TEST_FAIL("[ruleset] has no name!")
		if(name == "Extended" || name == "Meteor") // These rulesets don't spawn antags and are exempt.
			continue
		var/datum/antagonist/antag_datum = initial(ruleset.antag_datum)
		if(!ispath(antag_datum, /datum/antagonist) || !initial(antag_datum.banning_key))
			TEST_FAIL("[ruleset] has no antag_datum with a banning key!")
		var/role_pref = initial(ruleset.role_preference)
		if (!role_pref || !ispath(role_pref, /datum/role_preference))
			TEST_FAIL("[ruleset] has no role preference!")

	for(var/datum/dynamic_ruleset/midround/ruleset as anything in subtypesof(/datum/dynamic_ruleset/midround) - /datum/dynamic_ruleset/midround/from_ghosts)
		var/midround_ruleset_style = initial(ruleset.midround_ruleset_style)
		if(midround_ruleset_style != MIDROUND_RULESET_STYLE_HEAVY && midround_ruleset_style != MIDROUND_RULESET_STYLE_LIGHT)
			TEST_FAIL("[ruleset] has an invalid midround_ruleset_style, it should be MIDROUND_RULESET_STYLE_HEAVY or MIDROUND_RULESET_STYLE_LIGHT")
