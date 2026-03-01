/**
 * Do not directly inherit this!
 * Use either /datum/dynamic_ruleset/midround/living or /datum/dynamic_ruleset/midround/ghost
 */
/datum/dynamic_ruleset/midround
	rule_category = DYNAMIC_CATEGORY_MIDROUND
	restricted_roles = list(JOB_NAME_AI, JOB_NAME_CYBORG, JOB_NAME_POSIBRAIN)
	abstract_type = /datum/dynamic_ruleset/midround
	ruleset_flags = NO_TRANSFER_RULESET | REQUIRED_POP_ALLOW_UNREADY

	/// How disruptive the ruleset is (DYNAMIC_MIDROUND_LIGHT, DYNAMIC_MIDROUND_MEDIUM, DYNAMIC_MIDROUND_HEAVY)
	var/severity

/datum/dynamic_ruleset/midround/duplicate()
	var/datum/dynamic_ruleset/midround/new_ruleset = ..()
	new_ruleset.severity = severity

	return new_ruleset

/// Override this to return an icon for the poll
/datum/dynamic_ruleset/midround/proc/get_poll_icon()
	SHOULD_CALL_PARENT(FALSE)
	return

/// Abort the midround event, calling off our search to fufill the event.
/datum/dynamic_ruleset/midround/proc/abort()
	return

//////////////////////////////////////////////
//                                          //
//             PIRATES (MEDIUM)             //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/pirates
	name = "Space Pirates"
	severity = DYNAMIC_MIDROUND_MEDIUM | DYNAMIC_MIDROUND_HEAVY
	points_cost = 40
	weight = 2
	ruleset_flags = CANNOT_REPEAT | NO_TRANSFER_RULESET

/datum/dynamic_ruleset/midround/pirates/allowed(require_drafted = TRUE)
	if(!SSmapping.empty_space)
		return FALSE
	return TRUE

/datum/dynamic_ruleset/midround/pirates/execute()
	send_pirate_threat()
	return DYNAMIC_EXECUTE_SUCCESS
