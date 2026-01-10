/datum/objective/vampire
	martyr_compatible = TRUE

/datum/objective/vampire/New()
	update_explanation_text()
	return ..()

//////////////////////////////////////////////////////////////////////////////////////
//	//						   EGO OBJECTIVES 									//	//
//////////////////////////////////////////////////////////////////////////////////////
/datum/objective/vampire/ego
	name = "Dominion"
	explanation_text = "You crave power, the authority to rule:"

//////////////////////////////////////////////////       Lair
////////////////////////////////////////////////////////////////////

/datum/objective/vampire/ego/lair
	name = "Claim a Lair"

/datum/objective/vampire/ego/lair/update_explanation_text()
	. = ..()
	explanation_text = "[initial(explanation_text)] Establish a lair to rule from and hold it until the shift ends."

// WIN CONDITIONS?
/datum/objective/vampire/ego/lair/check_completion()
	var/datum/antagonist/vampire/vampire_datum = IS_VAMPIRE(owner.current)
	if(!vampire_datum)
		return FALSE

	if(vampire_datum.coffin && vampire_datum.vampire_lair_area)
		return TRUE

	return FALSE


////////////////////////////////////////////////// Department Vassal
////////////////////////////////////////////////////////////////////

/datum/objective/vampire/ego/department_vassal
	name = "Bind a Department"

	///The selected department we have to vassalize.
	var/target_department
	///List of all departments that can be selected for the objective.
	var/static/list/possible_departments = list(
		"engineering" = DEPT_BITFLAG_ENG,
		"medical" = DEPT_BITFLAG_MED,
		"science" = DEPT_BITFLAG_SCI,
		"cargo" = DEPT_BITFLAG_CAR,
		"service" = DEPT_BITFLAG_SRV,
	)

/datum/objective/vampire/ego/department_vassal/New()
	target_department = pick(possible_departments)
	target_amount = 1
	return ..()

/datum/objective/vampire/ego/department_vassal/update_explanation_text()
	explanation_text = "[initial(explanation_text)] Convert a crew member from the [target_department] department into your vassal."
	return ..()

/datum/objective/vampire/ego/department_vassal/proc/get_vassal_occupations()
	var/datum/antagonist/vampire/vampire_datum = IS_VAMPIRE(owner.current)
	if(!length(vampire_datum?.vassals))
		return FALSE

	var/list/all_vassal_jobs = list()
	for(var/datum/antagonist/vassal/vassal_datum in vampire_datum.vassals)
		if(!vassal_datum.owner)
			continue

		var/datum/mind/vassal_mind = vassal_datum.owner

		// Mind Assigned
		if(vassal_mind.assigned_role)
			all_vassal_jobs += SSjob.GetJob(vassal_mind.assigned_role)
			continue
		// Mob Assigned
		if(vassal_mind.current?.job)
			all_vassal_jobs += SSjob.GetJob(vassal_mind.current.job)
			continue
		// PDA Assigned
		if(ishuman(vassal_mind.current))
			var/mob/living/carbon/human/human_vassal = vassal_mind.current
			all_vassal_jobs += SSjob.GetJob(human_vassal.get_assignment())
			continue

	return all_vassal_jobs

/datum/objective/vampire/ego/department_vassal/check_completion()
	var/list/vassal_jobs = get_vassal_occupations()
	var/converted_count = 0
	for(var/datum/job/checked_job in vassal_jobs)
		if(checked_job.departments & target_department)
			converted_count++
	if(converted_count >= target_amount)
		return TRUE
	return FALSE


//////////////////////////////////////////////////    Big Places
////////////////////////////////////////////////////////////////////

/datum/objective/vampire/ego/bigplaces
	name = "Ascend the Ranks"

/datum/objective/vampire/ego/bigplaces/update_explanation_text()
	. = ..()
	explanation_text = "[initial(explanation_text)] Rise in power, reach prince or scourge, or prey on enough mortals to rank up as much as possible. You must reach at least rank 8 by the end of the shift!"

// WIN CONDITIONS?
/datum/objective/vampire/ego/bigplaces/check_completion()
	var/datum/antagonist/vampire/vampire_datum = IS_VAMPIRE(owner.current)
	if(!vampire_datum)
		return FALSE

	if(vampire_datum.vampire_level + vampire_datum.vampire_level_unspent >= 8)
		return TRUE

	return FALSE


//////////////////////////////////////////////////////////////////////////////////////
//	//						 HEDONISM OBJECTIVES 								//	//
//////////////////////////////////////////////////////////////////////////////////////

/datum/objective/vampire/hedonism
	name = "Hunger"
	explanation_text = "You crave depravity, to sate your thirst on the mortals:"


//////////////////////////////////////////////////     Heart Thief
////////////////////////////////////////////////////////////////////

/datum/objective/vampire/hedonism/heartthief
	name = "Collect Hearts"

/datum/objective/vampire/hedonism/heartthief/New()
	target_amount = rand(2,3)
	return ..()

/datum/objective/vampire/hedonism/heartthief/update_explanation_text()
	. = ..()
	explanation_text = "[initial(explanation_text)] Keep [target_amount] organic hearts close at hand. They shall be symbols of your dominion."

/datum/objective/vampire/hedonism/heartthief/check_completion()
	if(!owner.current)
		return FALSE

	var/list/all_items = owner.current.get_contents()
	var/heart_count = 0
	for(var/obj/item/organ/heart/current_hearts in all_items)
		if(current_hearts.organ_flags & ORGAN_SYNTHETIC) // No robo-hearts allowed
			continue
		heart_count++

	if(heart_count >= target_amount)
		return TRUE
	return FALSE


//////////////////////////////////////////////////     Gourmand
////////////////////////////////////////////////////////////////////

/datum/objective/vampire/hedonism/gourmand
	name = "Gorge"

/datum/objective/vampire/hedonism/gourmand/New()
	target_amount = rand(500, 1000) // This is blood, not vitae.
	return ..()

/datum/objective/vampire/hedonism/gourmand/update_explanation_text()
	. = ..()
	explanation_text = "[initial(explanation_text)] Consume at least [target_amount] units of blood to sate your ravenous thirst."

/datum/objective/vampire/hedonism/gourmand/check_completion()
	var/datum/antagonist/vampire/vampiredatum = owner.current.mind.has_antag_datum(/datum/antagonist/vampire)
	if(!vampiredatum)
		return FALSE
	var/stolen_blood = vampiredatum.total_blood_drank
	if(stolen_blood >= target_amount)
		return TRUE
	return FALSE

//////////////////////////////////////////////////     Thirster
////////////////////////////////////////////////////////////////////

/datum/objective/vampire/hedonism/thirster
	name = "Complete Drain"

/datum/objective/vampire/hedonism/thirster/update_explanation_text()
	. = ..()
	explanation_text = "[initial(explanation_text)] Drain a mortal completely, letting their lifeblood become your sustenance and their body fall cold and spent."

/datum/objective/vampire/hedonism/thirster/check_completion()
	var/datum/antagonist/vampire/vampiredatum = owner.current.mind.has_antag_datum(/datum/antagonist/vampire)
	if(!vampiredatum)
		return FALSE

	if(vampiredatum.thirster_objective)
		return TRUE

	return FALSE

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////       MISC       //////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////

/datum/objective/survive/vampire
	name = "Endure"
	explanation_text = "Avoid final death at all costs."

/**
 * Vassal
 */
/datum/objective/vampire/vassal
	name = "assist master"
	explanation_text = "You crave the blood of your sire! Obey and protect them at all costs!"

/datum/objective/vampire/vassal/check_completion()
	var/datum/antagonist/vassal/vassal_datum = IS_VASSAL(owner.current)
	return vassal_datum.master?.owner?.current?.stat != DEAD
