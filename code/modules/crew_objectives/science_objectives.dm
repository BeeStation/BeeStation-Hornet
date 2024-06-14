/*				SCIENCE OBJECTIVES				*/

/datum/objective/crew/cyborgs //Ported from old Hippie
	explanation_text = "Ensure there are at least (Yell on GitHub, something broke) functioning cyborgs or AI shells when the shift ends."
	jobs = list(
		JOB_NAME_RESEARCHDIRECTOR,
		JOB_NAME_ROBOTICIST,
	)

/datum/objective/crew/cyborgs/New()
	. = ..()
	target_amount = rand(1,3)
	update_explanation_text()

/datum/objective/crew/cyborgs/update_explanation_text()
	. = ..()
	explanation_text = "Ensure there [target_amount == 1 ? "is" : "are"] at least [target_amount] functioning cyborg\s or AI shell\s when the shift ends."

/datum/objective/crew/cyborgs/check_completion()
	if(..())
		return TRUE
	var/borgcount = target_amount
	for(var/mob/living/silicon/robot/R in GLOB.alive_mob_list)
		if(R.stat != DEAD)
			borgcount--
	return borgcount <= 0

/datum/objective/crew/research //inspired by old hippie's research level objective.
	var/datum/design/target_design
	var/static/list/possible_target_designs_list
	explanation_text = "Make sure the research for (something broke, yell on GitHub) is available on the R&D server by the end of the shift."
	jobs = list(
		JOB_NAME_RESEARCHDIRECTOR,
		JOB_NAME_SCIENTIST,
	)

/datum/objective/crew/research/New()
	. = ..()
	if(!possible_target_designs_list)
		fill_out_target_list()
	target_design = pick(possible_target_designs_list)
	update_explanation_text()

/datum/objective/crew/research/proc/fill_out_target_list()
	possible_target_designs_list = list()
	var/list/temp_list = subtypesof(/datum/design)
	for(var/found_design in temp_list)
		var/datum/design/temp_design = new found_design
		var/list/category_list = temp_design.category
		if(!("initial" in category_list))
			possible_target_designs_list.Add(found_design)

/datum/objective/crew/research/update_explanation_text()
	. = ..()
	explanation_text = "Make sure the research for [initial(target_design.name)] is available on the R&D server by the end of the shift."

/datum/objective/crew/research/check_completion()
	return ..() || SSresearch.science_tech.isDesignResearchedID(initial(target_design.id))
