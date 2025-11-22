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
	if(length(GLOB.all_vampires) >= 2)
		SSsociety.can_fire = TRUE
/**
 * Pauses society, called when someone is unassigned Vampire
**/
/datum/antagonist/vampire/proc/check_cancel_society()
	if(length(GLOB.all_vampires) < 2)
		SSsociety.can_fire = FALSE

/**
 * Turns the player into a prince.
**/
/datum/antagonist/vampire/proc/princify()
	rank_up(8, TRUE) // Rank up a lot.
	to_chat(owner.current, span_cultbold("As a true prince, you find some of your old power returning to you!"))
	set_antag_hud(owner.current, "prince")
	owner.current.playsound_local(null, 'sound/vampires/prince.ogg', 100, FALSE, pressure_affected = FALSE)
	prince = TRUE

/**
 * Turns the player into a scourge.
**/
/datum/antagonist/vampire/proc/scourgify()
	if(prince) // Literally how would this happen. Still, just in case.
		CRASH("Somehow a prince was going to be turned into a scourge")

	rank_up(4, TRUE) // Rank up less.
	to_chat(owner.current, span_cultbold("As a camarilla scourge, your newfound purpose empowers you!"))
	set_antag_hud(owner.current, "scourge")
	owner.current.playsound_local(null, 'sound/vampires/prince.ogg', 100, FALSE, pressure_affected = FALSE)
	scourge = TRUE

/**
 * Returns the princyness of this vampire.
 * get the players hours, convert it into a 10 point scale, 0-100 hours.
 * get their clans default princely score. 0-10(mostly).
 * Add those together.
**/
/datum/antagonist/vampire/proc/get_princely_score()
	var/calculated_hour_score = min(100, owner.current?.client?.get_exp_living(TRUE) / 60) / 10
	var/clan_bonus = my_clan.princely_score_bonus

	return clan_bonus + calculated_hour_score
