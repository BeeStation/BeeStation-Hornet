/*				SCIENCE OBJECTIVES				*/

/datum/objective/crew/cyborgs //Ported from old Hippie
	explanation_text = "Ensure there are at least (Yell on GitHub, something broke) functioning cyborgs when the shift ends."
	jobs = "researchdirector,roboticist"

/datum/objective/crew/cyborgs/New()
	. = ..()
	target_amount = rand(3,10)
	update_explanation_text()

/datum/objective/crew/cyborgs/update_explanation_text()
	. = ..()
	explanation_text = "Ensure there are at least [target_amount] functioning cyborgs when the shift ends."

/datum/objective/crew/cyborgs/check_completion()
	var/borgcount = target_amount
	for(var/mob/living/silicon/robot/R in GLOB.alive_mob_list)
		if(!(R.stat == DEAD))
			borgcount--
	if(borgcount <= 0)
		return TRUE
	else
		return FALSE

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
	return FALSE
*/
