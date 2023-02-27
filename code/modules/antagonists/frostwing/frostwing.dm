/datum/team/frostwing
	name = "Frostwings"

/datum/team/frostwing/proc/gain_objectives()
	var/datum/objective/O = new
	O.explanation_text = "Obtain resources and technology from the station in order to expand your home."
	O.team = src
	objectives += O
	for(var/datum/mind/M in members)
		log_objective(M, O.explanation_text)

	var/datum/objective/objective_2 = new
	objective_2.explanation_text = "Acquire synthflesh for the egg synthesizers. Grow in numbers, and regain your footing as the natives of the ice moon."
	objective_2.team = src
	objectives += objective_2
	for(var/datum/mind/M in members)
		log_objective(M, objective_2.explanation_text)

/datum/team/frostwing/roundend_report()
	var/list/parts = list()
	if(members.len)
		parts += "<span class='header'>The Frostwings were:</span>"
		parts += printplayerlist(members)

	if(length(objectives))
		parts += "<span class='header'>The Frostwings' objectives were:</span>"
		var/count = 1
		for(var/datum/objective/objective in objectives)
			parts += "<b>Objective #[count]</b>: [objective.explanation_text]"
			count++

	return "<div class='panel redborder'>[parts.Join("<br>")]</div>"

/datum/antagonist/frostwing
	name = "Frostwing"
	job_rank = ROLE_FROSTWING
	show_in_antagpanel = FALSE
	show_to_ghosts = TRUE
	prevent_roundtype_conversion = FALSE
	antagpanel_category = "Frostwing"
	delay_roundend = FALSE
	count_against_dynamic_roll_chance = FALSE
	var/datum/team/frostwing/frost_team

/datum/antagonist/frostwing/on_gain()
	if(frost_team)
		objectives |= frost_team.objectives
	..()

/datum/antagonist/frostwing/greet()
	to_chat(owner.current, "<span class='bold'>You are an agile, cunning frostwing. Grow your homestead.</span>")
	to_chat(owner.current, "<span>The ice is your home, the sprawling ravine your domain. The intruding space station caused major losses to your kind, you can no longer reproduce. \
	However, with your great cunning you built an incubator, powered by synthflesh, with materials scavenged from a shipwreck, in order to ensure the survival of your species. \
	Now you must grow your homestead using resources from the station, using your agility and cunning.</span>")
	to_chat(owner.current, "<span class='bold'>As a frostwing, your knowledge of the station, its layout, and its technology is adequate for the purpose of locating the tech you need. You have lived on the ice plains for a long time, and you have watched the station from afar. Human culture and language, however, is a mystery to you.</span>")
	to_chat(owner.current, "<span class='bold'>What the station makes of your intrusion is up to you.</span>")
	to_chat(owner.current, "<span class='big warning bold'>You should NOT be killing people for no reason, you're an intelligent being with respect for other lifeforms. Self-defense is the only valid reason to kill.</span>")
	owner.announce_objectives()

/datum/antagonist/frostwing/get_team()
	return frost_team

/datum/antagonist/frostwing/create_team(datum/team/frostwing/new_team)
	if(!new_team)
		for(var/datum/antagonist/frostwing/S in GLOB.antagonists)
			if(!S.owner)
				continue
			if(S.frost_team)
				frost_team = S.frost_team
				return
		frost_team = new /datum/team/frostwing
		frost_team.gain_objectives()
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	frost_team = new_team
