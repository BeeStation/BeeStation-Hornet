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
	for(var/mob/living/silicon/robot/R as anything in GLOB.cyborg_list)
		if(R.stat != DEAD)
			borgcount--
	return borgcount <= 0

/datum/objective/crew/research //inspired by old hippie's research level objective.
	explanation_text = "Make sure the research for (something broke, yell on GitHub) is available on the R&D server by the end of the shift."
	jobs = list(
		JOB_NAME_RESEARCHDIRECTOR,
		JOB_NAME_SCIENTIST,
	)

	var/static/list/possible_target_designs_list
	var/datum/design/target_design_type

/datum/objective/crew/research/New()
	. = ..()
	if(!possible_target_designs_list)
		fill_out_target_list()
	target_design_type = pick(possible_target_designs_list)
	update_explanation_text()

/datum/objective/crew/research/proc/fill_out_target_list()
	possible_target_designs_list = list()
	for(var/possible_design_path, _possible_design in SSresearch.techweb_designs)
		var/datum/design/possible_design = _possible_design
		if(!(RND_CATEGORY_INITIAL in possible_design.category))
			possible_target_designs_list += possible_design_path

/datum/objective/crew/research/update_explanation_text()
	. = ..()
	explanation_text = "Make sure the research for [target_design_type::name] is available on the R&D server by the end of the shift."

/datum/objective/crew/research/check_completion()
	var/datum/techweb/science_web = locate(/datum/techweb/science) in SSresearch.techwebs
	return ..() || science_web.researched_designs[target_design_type]
