/datum/objective/vampire
	martyr_compatible = TRUE

/datum/objective/vampire/New()
	update_explanation_text()
	return ..()

/// Look at all crew members, and for/loop through.
/datum/objective/vampire/proc/return_possible_targets()
	var/list/possible_targets = list()
	for(var/datum/mind/possible_target in get_crewmember_minds())
		// Check One: Default Valid User
		if(possible_target != owner && ishuman(possible_target.current) && possible_target.current.stat != DEAD)
			// Check Two: Am Vampire?
			if(IS_VAMPIRE(possible_target.current))
				continue
			possible_targets += possible_target

	return possible_targets

//////////////////////////////////////////////////////////////////////////////////////
//	//							 OBJECTIVES 									//	//
//////////////////////////////////////////////////////////////////////////////////////

/**
 * Claim a lair
 */
/datum/objective/vampire/lair
	name = "claimlair"
	explanation_text = "Create a lair by claiming a coffin, and protect it until the end of the shift."

// WIN CONDITIONS?
/datum/objective/vampire/lair/check_completion()
	var/datum/antagonist/vampire/vampire_datum = IS_VAMPIRE(owner.current)
	if(!vampire_datum)
		return FALSE

	if(vampire_datum.coffin && vampire_datum.vampire_lair_area)
		return TRUE

	return FALSE

/// Vassalize a certain person / people
/datum/objective/vampire/conversion
	name = "vassalization"

/// Check Vassals and get their occupations
/datum/objective/vampire/conversion/proc/get_vassal_occupations()
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

/**
 * Vassalize a head of staff
 */
/datum/objective/vampire/conversion/command
	name = "vassalizationcommand"
	explanation_text = "Guarantee a Vassal ends up as a Department Head or in a Leadership role."
	target_amount = 1

/datum/objective/vampire/conversion/command/check_completion()
	var/list/datum/job/vassal_jobs = get_vassal_occupations()
	for(var/datum/job/checked_job in vassal_jobs)
		if(checked_job.departments & DEPT_BITFLAG_COM)
			return TRUE

	return FALSE

/**
 * Vassalize crewmembers in a specific department
 */
/datum/objective/vampire/conversion/department
	name = "vassalize department"

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


// GENERATE!
/datum/objective/vampire/conversion/department/New()
	target_department = pick(possible_departments)

	// Don't assign more vassalizations than possible
	var/vassal_max = 0
	switch(length(GLOB.joined_player_list))
		if(1 to 20)
			vassal_max = 1
		if(21 to 30)
			vassal_max = 3
		if(31 to INFINITY)
			vassal_max = 4
	target_amount = min(rand(2, 3), vassal_max)
	return ..()

// EXPLANATION
/datum/objective/vampire/conversion/department/update_explanation_text()
	explanation_text = "Have [target_amount] Vassal\s in the [target_department] department."
	return ..()

// WIN CONDITIONS?
/datum/objective/vampire/conversion/department/check_completion()
	var/list/vassal_jobs = get_vassal_occupations()
	var/converted_count = 0
	for(var/datum/job/checked_job in vassal_jobs)
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

// NOTE: Look up /assassinate in objective.dm for inspiration.6
/// Vassalize a target.
/datum/objective/vampire/vassalhim
	name = "vassalhim"
	var/target_department_type = FALSE

/datum/objective/vampire/vassalhim/New()
	find_target()
	..()

// EXPLANATION
/datum/objective/vampire/vassalhim/update_explanation_text()
	. = ..()
	if(target?.current)
		explanation_text = "Ensure [target.name], the [target.assigned_role], is Vassalized via the Persuasion Rack."
	else
		explanation_text = "Free Objective"

/datum/objective/vampire/vassalhim/admin_edit(mob/admin)
	admin_simple_target_pick(admin)

// WIN CONDITIONS?
/datum/objective/vampire/vassalhim/check_completion()
	if(!target || target.has_antag_datum(/datum/antagonist/vassal))
		return TRUE
	return FALSE

//////////////////////////////////////////////
//                                          //
//              CLAN OBJECTIVES             //
//                                          //
//////////////////////////////////////////////

/**
 * Nosferatu
 */
/datum/objective/vampire/kindred
	name = "steal kindred"
	explanation_text = "Ensure Nosferatu steals and keeps control over the Archive of the Kindred."

/datum/objective/vampire/kindred/check_completion()
	for(var/datum/mind/vampire_minds as anything in get_antag_minds(/datum/antagonist/vampire))
		var/obj/item/book/kindred/the_book = locate() in vampire_minds.current.get_contents()
		if(the_book)
			return TRUE

	return FALSE

/**
 * Tremere
 */
/datum/objective/vampire/tremere_power
	name = "tremerepower"
	explanation_text = "Upgrade a Blood Magic power to the maximum level, remember that Vassalizing gives more Ranks!"

/datum/objective/vampire/tremere_power/check_completion()
	var/datum/antagonist/vampire/vampire_datum = IS_VAMPIRE(owner.current)
	for(var/datum/action/vampire/targeted/tremere/tremere_power in vampire_datum.powers)
		if(tremere_power.level_current >= 5)
			return TRUE

	return FALSE

/**
 * Ventrue
 */
/datum/objective/vampire/embrace
	name = "embrace"
	explanation_text = "Use the persuasion rack to Rank your Favorite Vassal up enough to become a Vampire."

// We set the objective to complete when we level up our favorite vassal into a vampire.

/**
 * Vassal
 */
/datum/objective/vampire/vassal
	name = "assist master"
	explanation_text = "Guarantee the success of your Master's mission!"

/datum/objective/vampire/vassal/check_completion()
	var/datum/antagonist/vassal/vassal_datum = IS_VASSAL(owner.current)
	return vassal_datum.master?.owner?.current?.stat != DEAD
