#define MURDERBONE_PROB 50
#define YANDERE_PROB 50

/datum/antagonist/malf_ai/forge_objectives()
	var/datum/mind/assassination_target

	if(length(GLOB.joined_player_list) >= CONFIG_GET(number/murderbone_min_pop) && prob(MURDERBONE_PROB))
		var/special_pick = rand(1, 3)
		switch(special_pick)
			if(1)
				add_objective(new /datum/objective/block())
			if(2)
				add_objective(new /datum/objective/purge())
			if(3)
				add_objective(new /datum/objective/robot_army())
	else
		var/datum/objective/assassinate/assassinate_objective = new()
		add_objective(assassinate_objective, find_target = TRUE)
		assassination_target = assassinate_objective.get_target()

	// 50% chance to protect & maroon someone. Should hopefully make for some fun scenarios
	if(prob(YANDERE_PROB))
		var/datum/objective/protect/yandere_one = new()
		yandere_one.find_target(blacklist = list(assassination_target))
		add_objective(yandere_one)

		var/datum/objective/maroon/yandere_two = new()
		yandere_two.target = yandere_one.target
		yandere_two.update_explanation_text() // normally called in find_target()
		add_objective(yandere_two)

	add_objective(new /datum/objective/survive/malf())

#undef MURDERBONE_PROB
#undef YANDERE_PROB
