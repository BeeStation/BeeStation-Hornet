/datum/team/frostwings
	name = "Frostwings"
	show_roundend_report = FALSE

/datum/antagonist/frostwing
	name = "Frostwing"
	job_rank = ROLE_LAVALAND
	show_in_antagpanel = FALSE
	show_to_ghosts = TRUE
	prevent_roundtype_conversion = FALSE
	antagpanel_category = "Frostwings"
	delay_roundend = FALSE
	count_against_dynamic_roll_chance = FALSE
	var/datum/team/frostwings/frost_team

/datum/antagonist/frostwing/greet()
	to_chat(owner.current, "<span class='bold'>You are an agile, cunning frostwing. Grow your homestead.</span>")
	to_chat(owner.current, "<span>The ice is your home, the sprawling ravine your domain. The intruding space station caused major losses to your kind, you can no longer reproduce. \
	However, with your great cunning you built an incubator, powered by synthflesh, with materials scavenged from a shipwreck, in order to ensure the survival of your species. \
	Now you must grow your homestead using resources from the station, using your agility and cunning.</span>")
	to_chat(owner.current, "<span class='bold'>As a frostwing, your knowledge of the station and its technology is adequate. You have lived on the ice plains for a long time, and you have watched the station from afar. Human culture and language, however, is a mystery to you.</span>")
	to_chat(owner.current, "<span class='bold'>What the station makes of your intrusion is up to you.</span>")
	to_chat(owner.current, "<span class='big warning bold'>You should NOT be killing people for no reason, you're an intelligent being with respect for other lifeforms. Self-defense is the only valid reason to kill.</span>")

/datum/antagonist/frostwing/create_team(datum/team/team)
	if(team)
		frost_team = team
		objectives |= frost_team.objectives
	else
		frost_team = new

/datum/antagonist/frostwing/get_team()
	return frost_team

/datum/antagonist/frostwing/on_gain()
	. = ..()
	give_objectives()
	owner.announce_objectives()

/datum/antagonist/frostwing/proc/give_objectives()
	var/datum/objective/newobjective = new
	newobjective.explanation_text = "Obtain resources and technology from the station in order to expand your home."
	newobjective.owner = owner
	objectives += newobjective
	log_objective(owner, newobjective.explanation_text)
	var/datum/objective/newobjective2 = new
	newobjective2.explanation_text = "Acquire synthflesh for the egg synthesizers. Grow in numbers, and regain your footing as the natives of the ice moon."
	newobjective2.owner = owner
	objectives += newobjective2
	log_objective(owner, newobjective2.explanation_text)
