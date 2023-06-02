/datum/antagonist/traitor/proc/forge_human_objectives()
	var/is_hijacker = FALSE
	if (GLOB.joined_player_list.len >= 30) // Less murderboning on lowpop thanks
		is_hijacker = prob(10)
	var/is_martyr = prob(15)

	var/objectives_to_assign = CONFIG_GET(number/traitor_objectives_amount)
	if(is_hijacker)
		objectives_to_assign--
	if(CONFIG_GET(flag/use_gimmick_objectives))
		objectives_to_assign--


 	//Set up an exchange if there are enough traitors
	if(!SSticker.mode.exchange_blue && SSticker.mode.traitors.len >= 8)
		if(!SSticker.mode.exchange_red)
			SSticker.mode.exchange_red = owner
		else
			SSticker.mode.exchange_blue = owner
			assign_exchange_role(SSticker.mode.exchange_red)
			assign_exchange_role(SSticker.mode.exchange_blue)
		objectives_to_assign-- //Exchange counts towards number of objectives

	for(var/i in 1 to objectives_to_assign) // minus 1
		forge_single_human_objective(is_martyr)
		objectives_to_assign--

	if(CONFIG_GET(flag/use_gimmick_objectives))
		//Add a gimmick objective
		var/datum/objective/gimmick/gimmick_objective = new
		gimmick_objective.owner = owner
		gimmick_objective.find_target()
		gimmick_objective.update_explanation_text()
		add_objective(gimmick_objective) //Does not count towards the number of objectives, to allow hijacking as well

	var/martyr_compatibility = TRUE
	if(is_hijacker)
		if (!(locate(/datum/objective/hijack) in objectives))
			var/datum/objective/hijack/hijack_objective = new
			hijack_objective.owner = owner
			add_objective(hijack_objective)
	else
		for(var/datum/objective/O in objectives)
			if(!O.martyr_compatible) // You can't succeed in stealing if you're dead.
				martyr_compatibility = FALSE
				break

		if(is_martyr && martyr_compatibility)
			var/datum/objective/martyr/martyr_objective = new
			martyr_objective.owner = owner
			add_objective(martyr_objective)
		else if(!(locate(/datum/objective/escape) in objectives))
			var/datum/objective/escape/escape_objective = new
			escape_objective.owner = owner
			add_objective(escape_objective)
	setup_backstories(!is_hijacker && is_martyr && martyr_compatibility, is_hijacker)

/datum/antagonist/traitor/proc/forge_single_human_objective(is_martyr)
	if(prob(50) || is_martyr) // martyr can't steal stuff, since they die, so they have to have a kill objective
		var/list/active_ais = active_ais()
		if(active_ais.len && prob(100/GLOB.joined_player_list.len))
			var/datum/objective/destroy/destroy_objective = new
			destroy_objective.owner = owner
			destroy_objective.find_target()
			add_objective(destroy_objective)
		else if(prob(30))
			var/datum/objective/maroon/maroon_objective = new
			maroon_objective.owner = owner
			maroon_objective.find_target()
			add_objective(maroon_objective)
		else
			var/datum/objective/assassinate/kill_objective = new
			kill_objective.owner = owner
			kill_objective.find_target()
			add_objective(kill_objective)
	else
		if(prob(15) && !(locate(/datum/objective/download) in objectives) && !(owner.assigned_role in list(JOB_NAME_RESEARCHDIRECTOR, JOB_NAME_SCIENTIST, JOB_NAME_ROBOTICIST)))
			var/datum/objective/download/download_objective = new
			download_objective.owner = owner
			download_objective.gen_amount_goal()
			add_objective(download_objective)
		else
			var/datum/objective/steal/steal_objective = new
			steal_objective.owner = owner
			steal_objective.find_target()
			add_objective(steal_objective)
