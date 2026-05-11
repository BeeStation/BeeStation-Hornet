#define MURDERBONE_PROB 10

/datum/antagonist/traitor/forge_objectives()
	if(length(GLOB.joined_player_list) >= CONFIG_GET(number/murderbone_min_pop) && prob(MURDERBONE_PROB))
		var/special_pick = rand(1, 3)
		switch(special_pick)
			if(1)
				add_objective(new /datum/objective/hijack())
			if(2)
				add_objective(new /datum/objective/martyr())
			if(3)
				add_objective(new /datum/objective/romerol())
				add_objective(new /datum/objective/escape())

		setup_backstories(murderbone = TRUE)
	else
		// Traitors primarily use priority directives
		add_objective(new /datum/objective/gain_reputation())
		add_objective(new /datum/objective/escape())

		setup_backstories(murderbone = FALSE)

#undef MURDERBONE_PROB
