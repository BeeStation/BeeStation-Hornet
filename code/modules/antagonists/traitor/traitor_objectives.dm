#define OBJECTIVE_HIJACK 0
#define OBJECTIVE_ROMEROL 1
#define OBJECTIVE_BRAINWASH 2
#define OBJECTIVE_HACK_AI 3

/datum/antagonist/traitor/proc/forge_objectives()
	var/list/valid_objectives = list()

	// Lowpop switch: Traitor needs to farm TC instead of do acts of killing
	// Set at a low value of 6, since the rounds with this number tend to grow
	// into having more people by the end of them
	// The less players there are, the more its an easy way out objective.
	if (length(GLOB.player_list) <= 6 || prob(max(20, 100 - 5 * length(GLOB.player_list))))
		var/datum/objective/gain_reputation/gain_reputation = new
		gain_reputation.owner = owner
		add_objective(gain_reputation)
		var/datum/objective/escape/escape_objective = new
		escape_objective.owner = owner
		add_objective(escape_objective)
		// Finally, set up our traitor's backstory, with murderbone options of course!
		setup_backstories(TRUE)
		return

	// Hijack: Catch-all objective, always available
	valid_objectives += OBJECTIVE_HIJACK

	// Hack AI: Requires an AI
	/*
	var/list/active_ais = active_ais()
	if (length(active_ais) > 0)
		valid_objectives += OBJECTIVE_HACK_AI
	*/

	// Romerol: Requires pop limit
	if (length(GLOB.joined_player_list) >= 12)
		valid_objectives += OBJECTIVE_ROMEROL

/*
	// Brainwash: Requires pop limit
	if (length(GLOB.joined_player_list) >= 8)
		valid_objectives += OBJECTIVE_BRAINWASH
		*/

	// Add the finale objective
	switch (pick(valid_objectives))
		if (OBJECTIVE_HIJACK)
			var/datum/objective/hijack/hijack_objective = new
			hijack_objective.owner = owner
			add_objective(hijack_objective)
		if (OBJECTIVE_ROMEROL)
			var/datum/objective/romerol/romerol_objective = new
			romerol_objective.owner = owner
			add_objective(romerol_objective)
			var/datum/objective/escape/escape_objective = new
			escape_objective.owner = owner
			add_objective(escape_objective)
			/*
		if (OBJECTIVE_BRAINWASH)
			var/datum/objective/brainwashing/brainwashing_objective = new
			brainwashing_objective.owner = owner
			brainwashing_objective.generate_amount()
			add_objective(brainwashing_objective)
			var/datum/objective/escape/escape_objective = new
			escape_objective.owner = owner
			add_objective(escape_objective)
			*/
	// Finally, set up our traitor's backstory, with murderbone options of course!
	setup_backstories(TRUE)

#undef OBJECTIVE_HIJACK
#undef OBJECTIVE_ROMEROL
#undef OBJECTIVE_BRAINWASH
#undef OBJECTIVE_HACK_AI
