/datum/objective/prevent_greentext
	name = "prevent greentext"
	explanation_text = "Prevent the round's primary antagonist (possible modes are listed in the security report) from completing their mission."

/datum/objective/prevent_greentext/check_completion()
	if (..())
		return TRUE
	for (var/datum/dynamic_ruleset/gamemode/gamemode in SSdynamic.gamemode_executed_rulesets)
		for (var/datum/mind/mind in SSticker.minds)
			var/datum/antagonist/antag_datum = mind.has_antag_datum(gamemode.antag_datum)
			if (!antag_datum)
				continue
			var/victory = TRUE
			var/has_objectives = FALSE
			for (var/datum/objective/objective in antag_datum.get_objectives())
				has_objectives = TRUE
				if (!objective.check_completion())
					victory = FALSE
			if (victory && has_objectives)
				return FALSE
	return TRUE
