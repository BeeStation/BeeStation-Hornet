/*				SCIENCE OBJECTIVES				*/

/datum/objective/crew/botmaker //Ported from old Hippie
	explanation_text = "Ensure there are at least (Yell on GitHub, something broke) functioning bots when the shift ends. The roundstarting ones don't count."
	jobs = "researchdirector,roboticist"
	var/static/roundstartcount

/datum/objective/crew/botmaker/New()
	. = ..()
	target_amount = rand(4,16)
	if(isnull(roundstartcount))
		roundstartcount = 0
		for(var/mob/living/simple_animal/bot/B in GLOB.alive_mob_list)
			roundstartcount++
	target_amount += roundstartcount
	update_explanation_text()

/datum/objective/crew/botmaker/update_explanation_text()
	. = ..()
	explanation_text = "Ensure there are at least [target_amount-roundstartcount] functioning bots when the shift ends. The roundstarting ones don't count."


/datum/objective/crew/botmaker/check_completion()
	var/botcount = target_amount
	for(var/mob/living/simple_animal/bot/B in GLOB.alive_mob_list)
		if(!(B.stat == DEAD))
			botcount--
		if(botcount <= 0)
			return TRUE
	return ..()

/datum/objective/crew/servertech //Ported from old Hippie
	explanation_text = "reach the 4 tech tier from the station R&D server when the shift ends."
	jobs = "researchdirector,scientist,explorationcrew"

/datum/objective/crew/servertech/check_completion()
	var/datum/techweb/stored_research = SSresearch.science_tech
	if(stored_research.current_tier >= 4)
		return TRUE
	return ..()

//TODO: make the research objective work with techwebs
/*
/datum/objective/crew/research //inspired by old hippie's research level objective.
	var/datum/design/targetdesign
	explanation_text = "Make sure the research required to produce a (something broke, yell on GitHub) is available on the R&D server by the end of the shift."
	jobs = "researchdirector,scientist"

/datum/objective/crew/research/New()
	. = ..()
	targetdesign = pick(subtypesof(/datum/design))
	update_explanation_text()

/datum/objective/crew/research/update_explanation_text()
	. = ..()
	explanation_text = "Make sure the research required to produce a [initial(targetdesign.name)] is available on the R&D server by the end of the shift."

/datum/objective/crew/research/check_completion()
	for(var/obj/machinery/r_n_d/server/S in GLOB.machines)
		if(S?.files?.known_designs)
			if(targetdesign in S.files.known_designs)
				return TRUE
	return ..()
*/
