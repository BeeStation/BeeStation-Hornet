/datum/objective/vampire
	martyr_compatible = TRUE

// GENERATE
/datum/objective/vampire/New()
	update_explanation_text()
	..()

//////////////////////////////////////////////////////////////////////////////
//	//							 PROCS 									//	//

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

/// Check Vassals and get their occupations
/datum/objective/vampire/proc/get_vassal_occupations()
	var/datum/antagonist/vampire/vampiredatum = owner.has_antag_datum(/datum/antagonist/vampire)
	if(!length(vampiredatum?.vassals))
		return FALSE
	var/list/all_vassal_jobs = list()
	var/vassal_job
	for(var/datum/antagonist/vassal/vampire_vassals in vampiredatum.vassals)
		if(!vampire_vassals || !vampire_vassals.owner)	// Must exist somewhere, and as a vassal.
			continue
		// Mind Assigned
		if(vampire_vassals.owner?.assigned_role)
			vassal_job = vampire_vassals.owner.assigned_role
		// Mob Assigned
		else if(vampire_vassals.owner?.current?.job)
			vassal_job = SSjob.GetJob(vampire_vassals.owner.current.job)
		// PDA Assigned
		else if(vampire_vassals.owner?.current && ishuman(vampire_vassals.owner.current))
			var/mob/living/carbon/human/vassal = vampire_vassals.owner.current
			vassal_job = SSjob.GetJob(vassal.get_assignment())
		if(vassal_job)
			all_vassal_jobs += vassal_job
	return all_vassal_jobs

//////////////////////////////////////////////////////////////////////////////////////
//	//							 OBJECTIVES 									//	//
//////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////
//    DEFAULT OBJECTIVES    //
//////////////////////////////

/datum/objective/vampire/lair
	name = "claimlair"

// EXPLANATION
/datum/objective/vampire/lair/update_explanation_text()
	explanation_text = "Create a lair by claiming a coffin, and protect it until the end of the shift."//  Make sure to keep it safe!"

// WIN CONDITIONS?
/datum/objective/vampire/lair/check_completion()
	var/datum/antagonist/vampire/vampiredatum = owner.has_antag_datum(/datum/antagonist/vampire)
	if(vampiredatum && vampiredatum.coffin && vampiredatum.vampire_lair_area)
		return TRUE
	return FALSE

//////////////////////////////////////////////////////////////////////////////////////

// WIN CONDITIONS?
// Handled by parent

//////////////////////////////////////////////////////////////////////////////////////


/// Vassalize a certain person / people
/datum/objective/vampire/conversion
	name = "vassalization"

/////////////////////////////////

// Vassalize a head of staff
/datum/objective/vampire/conversion/command
	name = "vassalizationcommand"
	explanation_text = "Guarantee a Vassal ends up as a Department Head or in a Leadership role."
	target_amount = 1

// WIN CONDITIONS?
/datum/objective/vampire/conversion/command/check_completion()
	var/list/vassal_jobs = get_vassal_occupations()
	for(var/datum/job/checked_job in vassal_jobs)
		if(checked_job.departments & DEPT_BITFLAG_COM)
			return TRUE // We only need one, so we stop as soon as we get a match
	return FALSE

/////////////////////////////////

// Vassalize crewmates in a department
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
	target_amount = rand(2, 3)
	return ..()

// EXPLANATION
/datum/objective/vampire/conversion/department/update_explanation_text()
	explanation_text = "Have [target_amount] Vassal[target_amount == 1 ? "" : "s"] in the [target_department] department."
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
	..()

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
	..()

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



//////////////////////////////
//     CLAN OBJECTIVES      //
//////////////////////////////

/// Steal the Archive of the Kindred - Nosferatu Clan objective
/datum/objective/vampire/kindred
	name = "steal kindred"

// EXPLANATION
/datum/objective/vampire/kindred/update_explanation_text()
	. = ..()
	explanation_text = "Ensure Nosferatu steals and keeps control over the Archive of the Kindred."

// WIN CONDITIONS?
/datum/objective/vampire/kindred/check_completion()
	if(!owner.current)
		return FALSE
	var/datum/antagonist/vampire/vampiredatum = owner.current.mind.has_antag_datum(/datum/antagonist/vampire)
	if(!vampiredatum)
		return FALSE

	for(var/datum/mind/vampire_minds as anything in get_antag_minds(/datum/antagonist/vampire))
		var/obj/item/book/kindred/the_book = locate() in vampire_minds.current.get_contents()
		if(the_book)
			return TRUE
	return FALSE

//////////////////////////////////////////////////////////////////////////////////////

/// Max out a Tremere Power - Tremere Clan objective
/datum/objective/vampire/tremere_power
	name = "tremerepower"

// EXPLANATION
/datum/objective/vampire/tremere_power/update_explanation_text()
	explanation_text = "Upgrade a Blood Magic power to the maximum level, remember that Vassalizing gives more Ranks!"

// WIN CONDITIONS?
/datum/objective/vampire/tremere_power/check_completion()
	var/datum/antagonist/vampire/vampiredatum = owner.has_antag_datum(/datum/antagonist/vampire)
	for(var/datum/action/vampire/targeted/tremere/tremere_powers in vampiredatum.powers)
		if(tremere_powers.level_current >= 5)
			return TRUE
	return FALSE

//////////////////////////////////////////////////////////////////////////////////////

/// Convert a crewmate - Ventrue Clan objective
/datum/objective/vampire/embrace
	name = "embrace"

// EXPLANATION
/datum/objective/vampire/embrace/update_explanation_text()
	. = ..()
	explanation_text = "Use the persuasion rack to Rank your Favorite Vassal up enough to become a Vampire."

// WIN CONDITIONS?
/datum/objective/vampire/embrace/check_completion()
	var/datum/antagonist/vampire/vampiredatum = owner.current.mind.has_antag_datum(/datum/antagonist/vampire)
	if(!vampiredatum)
		return FALSE
	for(var/datum/antagonist/vassal/vassaldatum in vampiredatum.vassals)
		if(IS_FAVORITE_VASSAL(vassaldatum.owner.current))
			if(vassaldatum.owner.has_antag_datum(/datum/antagonist/vampire))
				return TRUE
	return FALSE



//////////////////////////////
//     VASSAL OBJECTIVES    //
//////////////////////////////

/datum/objective/vampire/vassal

// EXPLANATION
/datum/objective/vampire/vassal/update_explanation_text()
	. = ..()
	explanation_text = "Guarantee the success of your Master's mission!"

// WIN CONDITIONS?
/datum/objective/vampire/vassal/check_completion()
	var/datum/antagonist/vassal/antag_datum = owner.has_antag_datum(/datum/antagonist/vassal)
	return antag_datum.master?.owner?.current?.stat != DEAD
