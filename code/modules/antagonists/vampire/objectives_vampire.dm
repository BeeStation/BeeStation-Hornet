/datum/objective/vampire
	martyr_compatible = TRUE

/datum/objective/vampire/New()
	update_explanation_text()
	return ..()

//////////////////////////////////////////////////////////////////////////////////////
//	//							 OBJECTIVES 									//	//
//////////////////////////////////////////////////////////////////////////////////////

/**
 * Claim a haven
 */
/datum/objective/vampire/haven
	name = "claimhaven"
	explanation_text = "Create a haven by claiming a coffin, and protect it until the end of the shift."

// WIN CONDITIONS?
/datum/objective/vampire/haven/check_completion()
	var/datum/antagonist/vampire/vampire_datum = IS_VAMPIRE(owner.current)
	if(!vampire_datum)
		return FALSE

	if(vampire_datum.coffin && vampire_datum.vampire_haven_area)
		return TRUE

	return FALSE

/// ghoulize a certain person / people
/datum/objective/vampire/conversion
	name = "ghoulization"

/// Check ghouls and get their occupations
/datum/objective/vampire/conversion/proc/get_ghoul_occupations()
	var/datum/antagonist/vampire/vampire_datum = IS_VAMPIRE(owner.current)
	if(!length(vampire_datum?.ghouls))
		return FALSE

	var/list/all_ghoul_jobs = list()
	for(var/datum/antagonist/ghoul/ghoul_datum in vampire_datum.ghouls)
		if(!ghoul_datum.owner)
			continue

		var/datum/mind/ghoul_mind = ghoul_datum.owner

		// Mind Assigned
		if(ghoul_mind.assigned_role)
			all_ghoul_jobs += SSjob.GetJob(ghoul_mind.assigned_role)
			continue
		// Mob Assigned
		if(ghoul_mind.current?.job)
			all_ghoul_jobs += SSjob.GetJob(ghoul_mind.current.job)
			continue
		// PDA Assigned
		if(ishuman(ghoul_mind.current))
			var/mob/living/carbon/human/human_ghoul = ghoul_mind.current
			all_ghoul_jobs += SSjob.GetJob(human_ghoul.get_assignment())
			continue

	return all_ghoul_jobs
/**
 * ghoulize crewmembers in a specific department
 */
/datum/objective/vampire/conversion/department
	name = "ghoulize department"

	///The selected department we have to ghoulize.
	var/target_department
	///List of all departments that can be selected for the objective.
	var/static/list/possible_departments = list(
		"engineering" = DEPT_BITFLAG_ENG,
		"medical" = DEPT_BITFLAG_MED,
		"science" = DEPT_BITFLAG_SCI,
		"cargo" = DEPT_BITFLAG_CAR,
		"service" = DEPT_BITFLAG_SRV,
	)

// GENERATE!
/datum/objective/vampire/conversion/department/New()
	target_department = pick(possible_departments)
	target_amount = 1
	return ..()

// EXPLANATION
/datum/objective/vampire/conversion/department/update_explanation_text()
	explanation_text = "Have a ghoul in the [target_department] department."
	return ..()

// WIN CONDITIONS?
/datum/objective/vampire/conversion/department/check_completion()
	var/list/ghoul_jobs = get_ghoul_occupations()
	var/converted_count = 0
	for(var/datum/job/checked_job in ghoul_jobs)
		if(checked_job.departments & target_department)
			converted_count++
	if(converted_count >= target_amount)
		return TRUE
	return FALSE

/**
* # IMPORTANT NOTE!!
*
* Look for Job Values on mobs! This is assigned at the start, but COULD be changed via the HoP
* ALSO - Search through all jobs (look for prefs earlier that look for all jobs, and search through all jobs to see if their head matches the head listed, or it IS the head)
* ALSO - registered_account in _vending.dm for banks, and assigning new ones.
*/

//////////////////////////////////////////////////////////////////////////////////////

// NOTE: Look up /steal in objective.dm for inspiration.
/// Steal hearts. You just really wanna have some hearts.
/datum/objective/vampire/heartthief
	name = "heartthief"

// GENERATE!
/datum/objective/vampire/heartthief/New()
	target_amount = rand(2,3)
	return ..()

// EXPLANATION
/datum/objective/vampire/heartthief/update_explanation_text()
	. = ..()
	explanation_text = "Steal and keep [target_amount] organic heart\s."

// WIN CONDITIONS?
/datum/objective/vampire/heartthief/check_completion()
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

//////////////////////////////////////////////////////////////////////////////////////

///Eat blood from a lot of people
/datum/objective/vampire/gourmand
	name = "gourmand"

// GENERATE!
/datum/objective/vampire/gourmand/New()
	target_amount = rand(450,650)
	return ..()

// EXPLANATION
/datum/objective/vampire/gourmand/update_explanation_text()
	. = ..()
	explanation_text = "Using your Feed ability, drink [target_amount] units of Blood."

// WIN CONDITIONS?
/datum/objective/vampire/gourmand/check_completion()
	var/datum/antagonist/vampire/vampiredatum = owner.current.mind.has_antag_datum(/datum/antagonist/vampire)
	if(!vampiredatum)
		return FALSE
	var/stolen_blood = vampiredatum.total_blood_drank
	if(stolen_blood >= target_amount)
		return TRUE
	return FALSE

// HOW: Track each feed (if human). Count victory.

/**
 * ghoul
 */
/datum/objective/vampire/ghoul
	name = "assist master"
	explanation_text = "You crave the blood of your sire! Obey and protect them at all costs!"

/datum/objective/vampire/ghoul/check_completion()
	var/datum/antagonist/ghoul/ghoul_datum = IS_GHOUL(owner.current)
	return ghoul_datum.master?.owner?.current?.stat != DEAD
