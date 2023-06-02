
/datum/objective_backstory
	var/title
	var/personal_text
	var/faction_text
	/// A list of backstory typepaths this is recommended for
	var/list/datum/objective_backstory/recommended_backstories
	/// A list of factions this is valid for
	var/list/allowed_factions
	/// If this is recommended for forced backstories
	var/recommend_forced_only = FALSE
	/// If this is recommended for free backstories
	var/recommend_free_only = FALSE
	/// If this is recommended for money-motivated backstories
	var/recommend_money_only = FALSE

/datum/objective_backstory/proc/is_recommended(datum/traitor_backstory/backstory, faction)
	if(!is_allowed(backstory, faction))
		return FALSE
	if(recommend_forced_only && !backstory.has_motivation(TRAITOR_MOTIVATION_FORCED))
		return FALSE
	if(recommend_free_only && backstory.has_motivation(TRAITOR_MOTIVATION_NOT_FORCED))
		return FALSE
	if(recommend_money_only && !backstory.has_motivation(TRAITOR_MOTIVATION_MONEY))
		return FALSE
	if(islist(recommended_backstories) && !(backstory.type in recommended_backstories))
		return FALSE
	return TRUE

/datum/objective_backstory/proc/is_allowed(datum/traitor_backstory/backstory, faction)
	return islist(allowed_factions) && (faction in allowed_factions)
