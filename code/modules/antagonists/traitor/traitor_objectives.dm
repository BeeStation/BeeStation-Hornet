/datum/antagonist/traitor/proc/forge_objectives()
	var/is_hijacker = FALSE
	if (GLOB.joined_player_list.len >= 30) // Less murderboning on lowpop thanks
		is_hijacker = prob(10)
	var/is_martyr = prob(5)

	var/objectives_to_assign = CONFIG_GET(number/traitor_objectives_amount)
	if(is_hijacker)
		objectives_to_assign--

	// Adds objectives_to_assign minus 1 objectives, since this is an exclusive range.
	for(var/i in 1 to objectives_to_assign)
		forge_single_human_objective(is_martyr)
		objectives_to_assign--

	// Add our 'finale' objective.
	var/martyr_compatibility = TRUE
	if(is_hijacker)
		if (!(locate(/datum/objective/hijack) in objectives))
			var/datum/objective/hijack/hijack_objective = new
			hijack_objective.owner = owner
			add_objective(hijack_objective)
	else
		// This check is just extra insurance now, we shouldn't assign non-martyr objectives in the first place.
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
	// Finally, set up our traitor's backstory!
	setup_backstories(!is_hijacker && is_martyr && martyr_compatibility, is_hijacker)

/datum/antagonist/traitor/proc/forge_single_human_objective(is_martyr) //Returns how many objectives are added
	.=1
	// Lower chance of spawning due to the few open objectives there are
	if(prob(20))
		var/static/list/selectable_objectives
		if (!selectable_objectives)
			selectable_objectives = list()
			for (var/datum/objective/open/objective as() in subtypesof(/datum/objective/open))
				selectable_objectives[objective] = initial(objective.weight)
		var/created_type = pick_weight(selectable_objectives)
		var/valid = TRUE
		// Check if the objective conflicts with any other ones
		// We don't want to have the same open objectives multiple times
		// If we don't want this objective, fall back to normal ones
		for (var/datum/objective/obj in objectives)
			if (obj.type == created_type)
				valid = FALSE
				break
		if (valid)
			var/datum/objective/obj = new created_type
			obj.owner = owner
			obj.find_target()
			add_objective(obj)
			return

	if(is_martyr || prob(50)) // martyr can't steal stuff, since they die, so they have to have a kill objective
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
