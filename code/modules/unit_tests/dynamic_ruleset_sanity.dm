/// Verifies that roundstart dynamic rulesets are setup properly without external configuration.
/datum/unit_test/dynamic_roundstart_ruleset_sanity

/datum/unit_test/dynamic_roundstart_ruleset_sanity/Run()
	for (var/datum/dynamic_ruleset/roundstart/ruleset as anything in subtypesof(/datum/dynamic_ruleset/roundstart))
		var/has_scaling_cost = initial(ruleset.scaling_cost)
		var/is_lone = initial(ruleset.flags) & (LONE_RULESET | HIGH_IMPACT_RULESET)

		if (has_scaling_cost && is_lone)
			Fail("[ruleset] has a scaling_cost, but is also a lone/highlander ruleset.")
		else if (!has_scaling_cost && !is_lone)
			Fail("[ruleset] has no scaling cost, but is also not a lone/highlander ruleset.")
		var/name = initial(ruleset.name)
		if(!name)
			Fail("[ruleset] has no name!")
		if(name == "Extended" || name == "Meteor") // These rulesets don't spawn antags and are exempt.
			continue
		var/datum/antagonist/antag_datum = initial(ruleset.antag_datum)
		if (!ispath(antag_datum, /datum/antagonist) || !initial(antag_datum.banning_key))
			Fail("[ruleset] has no antag_datum with a banning key!")
		var/role_pref = initial(ruleset.role_preference)
		if (!role_pref || !ispath(role_pref, /datum/role_preference))
			Fail("[ruleset] has no role preference!")

	for (var/datum/dynamic_ruleset/midround/ruleset as anything in subtypesof(/datum/dynamic_ruleset/midround) - /datum/dynamic_ruleset/midround/from_ghosts)
		var/midround_ruleset_style = initial(ruleset.midround_ruleset_style)
		if (midround_ruleset_style != MIDROUND_RULESET_STYLE_HEAVY && midround_ruleset_style != MIDROUND_RULESET_STYLE_LIGHT)
			Fail("[ruleset] has an invalid midround_ruleset_style, it should be MIDROUND_RULESET_STYLE_HEAVY or MIDROUND_RULESET_STYLE_LIGHT")
