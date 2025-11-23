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

	for(var/datum/antagonist/vampire as anything in GLOB.all_vampires)
		to_chat(vampire.owner.current, span_narsiesmall("[owner.current] has claimed the role of Prince!"))

	grant_power(new /datum/action/vampire/targeted/scourgify)

	var/datum/objective/vampire/prince/prince_objective = new()
	objectives += prince_objective
	owner.announce_objectives()

	tgui_alert(owner, "You have been chosen for Princedom. Please note that this entails a certain responsibility. Your job, now, is to keep order, and to enforce the masquerade.", "Welcome, my Prince.", list("I understand"), 30 SECONDS, TRUE)

/**
 * Turns the player into a scourge.
**/
/datum/antagonist/vampire/proc/scourgify()
	if(prince) // Literally how would this happen. Still, just in case.
		CRASH("Somehow a prince was going to be turned into a scourge")

	rank_up(4, TRUE) // Rank up less.
	to_chat(owner.current, span_cultbold("As a camarilla scourge, your newfound purpose empowers you!"))
	set_antag_hud(owner.current, "scourge")
	owner.current.playsound_local(null, 'sound/vampires/scourge_recruit.ogg', 100, FALSE, pressure_affected = FALSE)
	scourge = TRUE

	var/datum/objective/vampire/scourge/scourge_objective = new()
	objectives += scourge_objective
	owner.announce_objectives()

	for(var/datum/antagonist/vampire as anything in GLOB.all_vampires)
		to_chat(vampire.owner.current, span_cultbigbold("Under authority of the Prince, [owner.current] has been raised to the duty of the Scourge!"))

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

// We could put this in objectives but like, it's just two tiny hardcoded things. It's fine here.
/datum/objective/vampire/scourge
	name = "Camarilla Scourge"
	explanation_text = "Obey your prince! Ensure order! Safeguard the Masquerade!"

/datum/objective/vampire/prince
	name = "Camarilla Prince"
	explanation_text = "Rule your fellow kindred with an iron fist! Ensure the sanctity of the Masquerade, at ALL costs!"
