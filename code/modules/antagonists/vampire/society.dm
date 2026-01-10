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

	if(SSvsociety.can_fire)
		return

	if(length(GLOB.all_vampires) >= 3)
		SSvsociety.can_fire = TRUE
		message_admins("Vampire Society has started, as there are [length(GLOB.all_vampires)] vampires active.")
		log_game("Vampire Society has started, as there are [length(GLOB.all_vampires)] vampires active.")

/**
 * Pauses society, called when someone is unassigned Vampire
**/
/datum/antagonist/vampire/proc/check_cancel_society()

	if(!SSvsociety.can_fire)
		return

	if(length(GLOB.all_vampires) < 3)
		SSvsociety.can_fire = FALSE
		message_admins("Vampire Society has paused, as there are only [length(GLOB.all_vampires)] vampires active.")
		log_game("Vampire Society has paused, as there are only [length(GLOB.all_vampires)] vampires active.")

/**
 * Turns the player into a prince.
**/
/datum/antagonist/vampire/proc/princify()
	SSvsociety.princedatum = WEAKREF(src)

	rank_up(8, TRUE) // Rank up a lot.
	to_chat(owner.current, span_cultbold("As a true prince, you find some of your old power returning to you!"))
	set_antag_hud(owner.current, "prince")
	prince = TRUE

	for(var/datum/antagonist/vampire as anything in GLOB.all_vampires)
		to_chat(vampire.owner.current, span_narsiesmall("[owner.current] has claimed the role of Prince!"))

	grant_power(new /datum/action/vampire/targeted/scourgify)

	var/datum/objective/vampire/prince/prince_objective = new()
	objectives += prince_objective
	owner.announce_objectives()

	message_admins("[owner.current] has received the role of Vampire Prince. ([get_princely_score()] princely score, with [my_clan?.princely_score_bonus]/[min(50, owner.current?.client?.get_exp_living(TRUE) / 60) / 10] clan/hour bonus.)")
	log_game("[owner.current] has become the Vampire Prince. ([get_princely_score()] princely score, with [my_clan?.princely_score_bonus]/[min(50, owner.current?.client?.get_exp_living(TRUE) / 60) / 10] clan/hour bonus.)")

	tgui_alert(owner.current, "Congratulations, you have been chosen for Princedom.\nPlease note that this entails a certain responsibility. Your job, now, is to keep order, and to enforce the masquerade.", "Welcome, my Prince.", list("I understand"), 30 SECONDS, TRUE)

/**
 * Turns the player into a scourge.
**/
/datum/antagonist/vampire/proc/scourgify()
	ASSERT(!prince, "Somehow a prince was going to be turned into a scourge") // Literally how would this happen. Still, just in case.

	rank_up(4, TRUE) // Rank up less.
	to_chat(owner.current, span_cultbold("As a camarilla scourge, your newfound purpose empowers you!"))
	set_antag_hud(owner.current, "scourge")
	scourge = TRUE

	var/datum/objective/vampire/scourge/scourge_objective = new()
	objectives += scourge_objective
	owner.announce_objectives()

	for(var/datum/antagonist/vampire as anything in GLOB.all_vampires)
		to_chat(vampire.owner.current, span_cultbigbold("Under authority of the Prince, [owner.current] has been raised to the duty of the Scourge!"))

	message_admins("[owner.current] has been made a Scourge of the Vampires!")
	log_game("[owner.current] has become a Scourge of the Vampires.")

/**
 * Returns the princyness of this vampire.
 * get the players hours, convert it into a 10 point scale, 0-100 hours.
 * get their clans default princely score. 0-10(mostly).
 * Add those together.
**/
/datum/antagonist/vampire/proc/get_princely_score()
	var/calculated_hour_score = min(50, owner.current?.client?.get_exp_living(TRUE) / 60) / 10

	var/clan_bonus = my_clan?.princely_score_bonus || -10

	return clan_bonus + calculated_hour_score

// We could put this in objectives but like, it's just two tiny hardcoded things. It's fine here.
/datum/objective/vampire/scourge
	name = "Camarilla Scourge"
	explanation_text = "Obey your prince! Ensure order! Safeguard the Masquerade!"

/datum/objective/vampire/prince
	name = "Camarilla Prince"
	explanation_text = "Rule your fellow kindred with an iron fist! Ensure the sanctity of the Masquerade, at ALL costs!"
