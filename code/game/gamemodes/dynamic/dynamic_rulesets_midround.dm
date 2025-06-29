/**
 * Do not directly inherit this!
 * Use either /datum/dynamic_ruleset/midround/living or /datum/dynamic_ruleset/midround/ghost/
**/

/datum/dynamic_ruleset/midround
	rule_category = DYNAMIC_CATEGORY_MIDROUND
	restricted_roles = list(JOB_NAME_AI, JOB_NAME_CYBORG, JOB_NAME_POSIBRAIN)

	/// How disruptive the ruleset is (DYNAMIC_MIDROUND_LIGHT, DYNAMIC_MIDROUND_MEDIUM, DYNAMIC_MIDROUND_HEAVY)
	var/severity

/// Override this to return an icon for the poll
/datum/dynamic_ruleset/midround/proc/get_poll_icon()
	SHOULD_CALL_PARENT(FALSE)
	return
