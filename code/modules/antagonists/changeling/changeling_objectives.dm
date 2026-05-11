#define MURDERBONE_PROB 10
#define STEAL_IDENTITY_PROB 50
#define AI_MURDER_PROB 33

/datum/antagonist/changeling/forge_objectives()
	if(length(GLOB.joined_player_list) >= CONFIG_GET(number/murderbone_min_pop) && prob(MURDERBONE_PROB))
		var/datum/objective/survival_of_the_fittest/cull_objective = new()
		cull_objective.generate_amount()
		add_objective(cull_objective)
	else
		// Pick 2 unique objectives from 3 possibilities (steal, absorb, assassinate)
		var/list/possible_objectives = list(1, 2, 3)
		for(var/i = 1 to 2)
			var/special_pick = pick_n_take(possible_objectives)
			switch(special_pick)
				if(1)
					add_objective(new /datum/objective/steal(), find_target = TRUE)
				if(2)
					var/datum/objective/absorb/absorb_objective = new()
					absorb_objective.set_absorb_amount()
					add_objective(absorb_objective)
				if(3)
					// 1/3 chance to destroy the AI instead of a normal assassination
					if(length(active_ais()) && prob(AI_MURDER_PROB))
						add_objective(new /datum/objective/destroy(), find_target = TRUE)
					else
						add_objective(new /datum/objective/assassinate(), find_target = TRUE)

	// 50% chance to steal someone's identity
	if(prob(STEAL_IDENTITY_PROB))
		add_objective(new /datum/objective/escape/escape_with_identity())
	else
		add_objective(new /datum/objective/escape())

#undef MURDERBONE_PROB
#undef STEAL_IDENTITY_PROB
#undef AI_MURDER_PROB
