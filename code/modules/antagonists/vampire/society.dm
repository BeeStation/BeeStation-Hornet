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
	to_chat(owner.current, span_cultbold("As a true prince, you find some of your old power!"))
	set_antag_hud(owner.current, "vampire_prince")
	owner.current.playsound_local(null, 'sound/vampires/prince.ogg', 100, FALSE, pressure_affected = FALSE)
	rank_up(6, TRUE)

/**
 * Returns the princyness of this vampire.
 * Working as follows:
 * We get the players hours, convert it into a 10 point scale. Prolly gonna go with 0-100 hours.
 * We get their clan, and get their clans default princely score. Also gonna be 0-10(mostly).
 * Add those together. Donesy.
 * We return false if the vampire is not eligible for princedom at all. (No body, etc.)
**/
/datum/antagonist/vampire/proc/get_princely_score()
	var/calculated_hour_score = min(100, owner.current?.client?.get_exp_living(TRUE) / 60) / 10
	var/clan_bonus = my_clan.princely_score_bonus

	return clan_bonus + calculated_hour_score
