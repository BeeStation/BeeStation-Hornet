/// A global list of vampire antag datums that have broken the Masquerade
GLOBAL_LIST_EMPTY(masquerade_breakers)

/// A global list of vampire antag datums in general
GLOBAL_LIST_EMPTY(all_vampires)

//////////////////////////////////////////////////
//////////// ON THE VAMP ANTAG DATUM /////////////
//////////////////////////////////////////////////
/**
 * Resumes society, called when someone is assigned Vampire
**/
/datum/antagonist/vampire/proc/check_start_society()
	if(length(GLOB.all_vampires))
		SSsociety.can_fire = TRUE
/**
 * Pauses society, called when someone is unassigned Vampire
**/
/datum/antagonist/vampire/proc/check_cancel_society()
	if(!length(GLOB.all_vampires))
		SSsociety.can_fire = FALSE

/**
 * Polls the player if they want to become prince.
**/
