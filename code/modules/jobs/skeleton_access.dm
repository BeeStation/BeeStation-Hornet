#define SKELETON_ACCESS_GRACE (5 MINUTES)

/// Lowpop access for the recipient jobs while the jobs they cover are empty
/datum/skeleton_access
	/// Only recipients in this department are notified. Null notifies all recipients
	var/datum/department_group/department
	/// Titles of the jobs that get the access. Null means everyone
	var/list/recipients
	/// Titles of the jobs being covered for. The rule is off while any of them is filled
	var/list/covered_jobs = list()
	/// Shown instead of the covered jobs when they make up a whole department
	var/datum/department_group/covered_department
	var/list/access
	/// The rule is off once the crew count reaches this
	var/population_limit = LOWPOP_JOB_LIMIT
	/// Includes the grace period
	var/enabled = FALSE
	var/revoke_timer
	var/cause
	/// Never give assignment after this assignment integer
	var/revoke_after_assignment

/// Why the rule should be off, or null if it should be on
/datum/skeleton_access/proc/get_inactive_reason()
	for(var/title in covered_jobs)
		if(!SSjob.is_job_empty(title))
			return "[title] reported for duty"
		if(SSjob.has_acting_head(title))
			return "Acting [title] appointed"
	if(SSjob.get_crew_count() >= population_limit)
		return "Crew levels restored"
	return null

/// its possible to get the job after the handover starts, so for the love of god avoid giving them access
/datum/skeleton_access/proc/excludes(obj/item/card/id/card)
	return !isnull(revoke_after_assignment) && card.job_assignment_id > revoke_after_assignment

/datum/skeleton_access/proc/applies_to(job_title)
	return job_title && (isnull(recipients) || (job_title in recipients))

/datum/skeleton_access/proc/notifies(job_title)
	if(!department)
		return TRUE
	var/datum/job/job = SSjob.get_job(job_title)
	return department in job?.departments_list

/datum/skeleton_access/proc/access_names(list/accesses = access)
	return english_list(get_access_descs(accesses))

/datum/skeleton_access/proc/covering_for()
	if(covered_department)
		return initial(covered_department.department_name)
	if(length(covered_jobs))
		return english_list(covered_jobs)
	return "an understaffed station"

/datum/skeleton_access/proc/end_condition()
	if(covered_department)
		return "ends when department has staff or total crew reaches [population_limit]"
	if(length(covered_jobs))
		return "ends when position has staff or total crew reaches [population_limit]"
	return "ends when total crew reaches [population_limit]"

/// I have colored it by department chat colors in lieu of having anything else
/datum/skeleton_access/proc/get_colour_class()
	var/datum/department_group/colour_department = covered_department || department
	var/channel = colour_department && initial(colour_department.dept_radio_channel)
	return channel && get_radio_span(channel)

/datum/skeleton_access/proc/briefing_prefix()
	var/colour_class = get_colour_class()
	if(!colour_class)
		return "Covering for [covering_for()]: "
	return "Covering for <span class='[colour_class]'>[covering_for()]</span>: "

/datum/skeleton_access/proc/get_briefing()
	return "Covering for [covering_for()]: [access_names()] access authorized ([end_condition()])."

/datum/skeleton_access/proc/get_examine_reason()
	return "Covering for [covering_for()]"

/datum/skeleton_access/proc/timing_text()
	if(revoke_timer)
		return "handing over in [DisplayTimeText(timeleft(revoke_timer))]"
	return end_condition()

/// Turning off waits out SKELETON_ACCESS_GRACE
/datum/skeleton_access/proc/refresh(mob/living/arrival)
	var/inactive_reason = get_inactive_reason()
	if(isnull(inactive_reason))
		if(revoke_timer)
			deltimer(revoke_timer)
			revoke_timer = null
			SSjob.update_skeleton_access()
			log_id("Skeleton crew access to [access_names()] continues.")
			announce("Handover cancelled: ", " access continues ([end_condition()]).")
			revoke_after_assignment = null
		else if(!enabled)
			enabled = TRUE
			SSjob.update_skeleton_access()
			log_id("Skeleton crew access on. [get_briefing()]")
			announce(briefing_prefix(), " access authorized ([end_condition()]).")
		return
	if(!enabled || revoke_timer)
		return
	cause = inactive_reason
	var/obj/item/card/id/arrival_card = arrival?.get_idcard(hand_first = FALSE)
	revoke_after_assignment = arrival_card ? arrival_card.job_assignment_id - 1 : SSjob.job_assignment_count
	revoke_timer = addtimer(CALLBACK(src, PROC_REF(finish_revoke)), SKELETON_ACCESS_GRACE, TIMER_STOPPABLE)
	SSjob.update_skeleton_access()
	log_id("Skeleton crew access to [access_names()] ends in [DisplayTimeText(SKELETON_ACCESS_GRACE)], [cause].")
	announce("[cause]. Finish up and hand over: ", " access ends in [DisplayTimeText(SKELETON_ACCESS_GRACE)].", warning = TRUE)

/datum/skeleton_access/proc/finish_revoke()
	revoke_timer = null
	enabled = FALSE
	SSjob.update_skeleton_access()
	log_id("Skeleton crew access to [access_names()] withdrawn, [cause].")
	announce("[cause]: ", " access handed over. Thanks for covering.")
	revoke_after_assignment = null

/// what access has changed
/datum/skeleton_access/proc/announce(prefix, suffix, warning = FALSE)
	for(var/datum/mind/crew_mind as anything in get_crewmember_minds())
		var/obj/item/card/id/card = crew_mind.current?.get_idcard(hand_first = FALSE)
		if(!card || !applies_to(card.job_title) || !notifies(card.job_title))
			continue
		if(excludes(card))
			continue
		var/list/changed = access - card.get_non_skeleton_access() - card.withheld_skeleton_access
		for(var/datum/skeleton_access/rule as anything in SSjob.get_skeleton_rules_for(card.job_title))
			// grace period sanity check
			if(rule != src && !(revoke_timer && rule.revoke_timer))
				changed -= rule.access
		if(length(changed))
			card.card_talk("[prefix][access_names(changed)][suffix]", warning)

// Engineering

/datum/skeleton_access/chief_engineer
	department = /datum/department_group/engineering
	recipients = list(JOB_NAME_STATIONENGINEER)
	covered_jobs = list(JOB_NAME_CHIEFENGINEER)
	access = list(ACCESS_CE)
	population_limit = COMMAND_POPULATION_MINIMUM

/datum/skeleton_access/atmospheric_technician
	department = /datum/department_group/engineering
	recipients = list(JOB_NAME_STATIONENGINEER)
	covered_jobs = list(JOB_NAME_ATMOSPHERICTECHNICIAN)
	access = list(ACCESS_ATMOSPHERICS)

/datum/skeleton_access/station_engineer
	department = /datum/department_group/engineering
	recipients = list(JOB_NAME_ATMOSPHERICTECHNICIAN)
	covered_jobs = list(JOB_NAME_STATIONENGINEER)
	access = list(ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_TECH_STORAGE)

// Medical

/datum/skeleton_access/chief_medical_officer
	department = /datum/department_group/medical
	recipients = list(JOB_NAME_MEDICALDOCTOR)
	covered_jobs = list(JOB_NAME_CHIEFMEDICALOFFICER)
	access = list(ACCESS_CMO)
	population_limit = COMMAND_POPULATION_MINIMUM

/datum/skeleton_access/chemist
	department = /datum/department_group/medical
	recipients = list(JOB_NAME_MEDICALDOCTOR)
	covered_jobs = list(JOB_NAME_CHEMIST)
	access = list(ACCESS_CHEMISTRY)

/datum/skeleton_access/geneticist
	department = /datum/department_group/medical
	recipients = list(JOB_NAME_MEDICALDOCTOR)
	covered_jobs = list(JOB_NAME_GENETICIST)
	access = list(ACCESS_GENETICS)

/datum/skeleton_access/medical_doctor
	department = /datum/department_group/medical
	recipients = list(JOB_NAME_PARAMEDIC, JOB_NAME_CHEMIST, JOB_NAME_GENETICIST, JOB_NAME_VIROLOGIST)
	covered_jobs = list(JOB_NAME_MEDICALDOCTOR)
	access = list(ACCESS_SURGERY, ACCESS_CLONING, ACCESS_VIROLOGY)

// Science

/datum/skeleton_access/research_director
	department = /datum/department_group/science
	recipients = list(JOB_NAME_SCIENTIST)
	covered_jobs = list(JOB_NAME_RESEARCHDIRECTOR)
	access = list(ACCESS_RD, ACCESS_RD_SERVER)
	population_limit = COMMAND_POPULATION_MINIMUM

/datum/skeleton_access/roboticist
	department = /datum/department_group/science
	recipients = list(JOB_NAME_SCIENTIST)
	covered_jobs = list(JOB_NAME_ROBOTICIST)
	access = list(ACCESS_ROBOTICS)

/datum/skeleton_access/exploration_crew
	department = /datum/department_group/science
	recipients = list(JOB_NAME_SCIENTIST)
	covered_jobs = list(JOB_NAME_EXPLORATIONCREW)
	access = list(ACCESS_EXPLORATION)

/datum/skeleton_access/scientist
	department = /datum/department_group/science
	recipients = list(JOB_NAME_ROBOTICIST, JOB_NAME_EXPLORATIONCREW)
	covered_jobs = list(JOB_NAME_SCIENTIST)
	access = list(ACCESS_TOX, ACCESS_TOX_STORAGE, ACCESS_XENOBIOLOGY)

/datum/skeleton_access/science_tech_storage
	department = /datum/department_group/science
	recipients = list(JOB_NAME_SCIENTIST)
	access = list(ACCESS_TECH_STORAGE)

// Security

/datum/skeleton_access/armory
	department = /datum/department_group/security
	recipients = list(JOB_NAME_SECURITYOFFICER)
	covered_jobs = list(JOB_NAME_HEADOFSECURITY, JOB_NAME_WARDEN)
	access = list(ACCESS_ARMORY)
	population_limit = COMMAND_POPULATION_MINIMUM

/datum/skeleton_access/detective
	department = /datum/department_group/security
	recipients = list(JOB_NAME_SECURITYOFFICER)
	covered_jobs = list(JOB_NAME_DETECTIVE)
	access = list(ACCESS_FORENSICS_LOCKERS, ACCESS_MORGUE)

/datum/skeleton_access/brig_physician
	department = /datum/department_group/security
	recipients = list(JOB_NAME_SECURITYOFFICER)
	covered_jobs = list(JOB_NAME_BRIGPHYSICIAN)
	access = list(ACCESS_BRIGPHYS)

/datum/skeleton_access/security_maintenance
	department = /datum/department_group/security
	recipients = list(JOB_NAME_SECURITYOFFICER)
	access = list(ACCESS_MAINT_TUNNELS)

// Cargo

/datum/skeleton_access/quartermaster
	department = /datum/department_group/cargo
	recipients = list(JOB_NAME_CARGOTECHNICIAN)
	covered_jobs = list(JOB_NAME_QUARTERMASTER)
	access = list(ACCESS_QM, ACCESS_VAULT)

/datum/skeleton_access/shaft_miner
	department = /datum/department_group/cargo
	recipients = list(JOB_NAME_CARGOTECHNICIAN)
	covered_jobs = list(JOB_NAME_SHAFTMINER)
	access = list(ACCESS_GATEWAY, ACCESS_MINING, ACCESS_MINING_STATION)

/datum/skeleton_access/cargo_technician
	department = /datum/department_group/cargo
	recipients = list(JOB_NAME_SHAFTMINER)
	covered_jobs = list(JOB_NAME_CARGOTECHNICIAN)
	access = list(ACCESS_CARGO)

/datum/skeleton_access/cargo_gateway
	department = /datum/department_group/cargo
	recipients = list(JOB_NAME_CARGOTECHNICIAN)
	access = list(ACCESS_GATEWAY)

// Service

/datum/skeleton_access/cook
	department = /datum/department_group/service
	covered_jobs = list(JOB_NAME_COOK)
	access = list(ACCESS_KITCHEN)

/datum/skeleton_access/bartender
	department = /datum/department_group/service
	recipients = list(JOB_NAME_ASSISTANT)
	covered_jobs = list(JOB_NAME_BARTENDER)
	access = list(ACCESS_BAR, ACCESS_JANITOR)

/datum/skeleton_access/botanist
	department = /datum/department_group/service
	recipients = list(JOB_NAME_ASSISTANT)
	covered_jobs = list(JOB_NAME_BOTANIST)
	access = list(ACCESS_HYDROPONICS)

/datum/skeleton_access/clown
	department = /datum/department_group/service
	recipients = list(JOB_NAME_ASSISTANT)
	covered_jobs = list(JOB_NAME_CLOWN)
	access = list(ACCESS_THEATRE)

/datum/skeleton_access/curator
	department = /datum/department_group/service
	recipients = list(JOB_NAME_ASSISTANT)
	covered_jobs = list(JOB_NAME_CURATOR)
	access = list(ACCESS_LIBRARY)

// Civilian

/datum/skeleton_access/assistant_maintenance
	department = /datum/department_group/civilian
	recipients = list(JOB_NAME_ASSISTANT)
	access = list(ACCESS_EVA, ACCESS_MAINT_TUNNELS, ACCESS_AUX_BASE)

// Station unlock. Everyone covers for departments with nobody in them

/datum/skeleton_access/station_unlock
	population_limit = STATION_UNLOCK_POPULATION
	access = list(
		ACCESS_MAINT_TUNNELS,
		ACCESS_EXTERNAL_AIRLOCKS,
		ACCESS_CHAPEL_OFFICE, ACCESS_BAR, ACCESS_JANITOR, ACCESS_CREMATORIUM, ACCESS_KITCHEN, ACCESS_HYDROPONICS, ACCESS_LIBRARY,ACCESS_THEATRE, //service
		ACCESS_MAILSORTING, ACCESS_MINING_STATION, ACCESS_GATEWAY, ACCESS_MINERAL_STOREROOM, ACCESS_MINING, //cargo
		ACCESS_CONSTRUCTION, //engi
	)

/datum/skeleton_access/station_unlock/cargo
	covered_jobs = list(JOB_NAME_QUARTERMASTER, JOB_NAME_CARGOTECHNICIAN, JOB_NAME_SHAFTMINER)
	covered_department = /datum/department_group/cargo
	access = list(ACCESS_CARGO)

/datum/skeleton_access/station_unlock/science
	covered_jobs = list(JOB_NAME_RESEARCHDIRECTOR, JOB_NAME_SCIENTIST, JOB_NAME_ROBOTICIST, JOB_NAME_EXPLORATIONCREW)
	covered_department = /datum/department_group/science
	access = list(
		ACCESS_TOX, ACCESS_TOX_STORAGE, ACCESS_ROBOTICS,
		ACCESS_RESEARCH, ACCESS_EXPLORATION, ACCESS_XENOBIOLOGY
	)

/datum/skeleton_access/station_unlock/engineering
	covered_jobs = list(JOB_NAME_CHIEFENGINEER, JOB_NAME_STATIONENGINEER, JOB_NAME_ATMOSPHERICTECHNICIAN)
	covered_department = /datum/department_group/engineering
	access = list(ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_ATMOSPHERICS)

/datum/skeleton_access/station_unlock/medical
	covered_jobs = list(JOB_NAME_CHIEFMEDICALOFFICER, JOB_NAME_MEDICALDOCTOR, JOB_NAME_PARAMEDIC, JOB_NAME_CHEMIST, JOB_NAME_GENETICIST, JOB_NAME_VIROLOGIST)
	covered_department = /datum/department_group/medical
	access = list(
		ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_GENETICS,
		ACCESS_CHEMISTRY, ACCESS_VIROLOGY, ACCESS_SURGERY,
		ACCESS_CLONING
	)

#undef SKELETON_ACCESS_GRACE
