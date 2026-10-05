#define SKELETON_ACCESS_GRACE (5 MINUTES)

/// Lowpop access for the recipient jobs while the jobs they cover are empty
/datum/skeleton_access
	/// Only recipients in this department are notified
	var/datum/department_group/department
	/// Titles of the jobs that get the access. Null means everyone
	var/list/recipients
	/// Titles of the jobs being covered for. The rule is off while any of them is filled
	var/list/covered_jobs = list()
	var/list/access
	/// The rule is off once the crew count reaches this
	var/population_limit = LOWPOP_JOB_LIMIT
	/// Includes the grace period
	var/enabled = FALSE
	var/revoke_timer
	var/cause

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

/datum/skeleton_access/proc/applies_to(job_title)
	return job_title && (isnull(recipients) || (job_title in recipients))

/datum/skeleton_access/proc/notifies(job_title)
	var/datum/job/job = SSjob.get_job(job_title)
	return department in job?.departments_list

/datum/skeleton_access/proc/access_names()
	return english_list(get_access_descs(access))

/datum/skeleton_access/proc/get_briefing()
	if(length(covered_jobs))
		return "No [english_list(covered_jobs)] on duty: [access_names()] access authorized."
	return "Station understaffed: [access_names()] access authorized."

/datum/skeleton_access/proc/get_examine_reason()
	if(length(covered_jobs))
		return "Skeleton crew protocol: no [english_list(covered_jobs)] on duty"
	return "Skeleton crew protocol: station understaffed"

/datum/skeleton_access/proc/timing_text()
	if(revoke_timer)
		return "ending in [DisplayTimeText(timeleft(revoke_timer))]"
	return "active until revoked"

/// Turning off waits out SKELETON_ACCESS_GRACE
/datum/skeleton_access/proc/refresh()
	var/inactive_reason = get_inactive_reason()
	if(isnull(inactive_reason))
		if(revoke_timer)
			deltimer(revoke_timer)
			revoke_timer = null
			log_id("Skeleton crew access to [access_names()] continues.")
			announce("[access_names()] access withdrawal cancelled.")
		else if(!enabled)
			enabled = TRUE
			SSjob.update_skeleton_access()
			log_id("Skeleton crew access on. [get_briefing()]")
			announce(get_briefing())
		return
	if(!enabled || revoke_timer)
		return
	cause = inactive_reason
	revoke_timer = addtimer(CALLBACK(src, PROC_REF(finish_revoke)), SKELETON_ACCESS_GRACE, TIMER_STOPPABLE)
	log_id("Skeleton crew access to [access_names()] ends in [DisplayTimeText(SKELETON_ACCESS_GRACE)], [cause].")
	announce("[cause]. [access_names()] access ends in [DisplayTimeText(SKELETON_ACCESS_GRACE)].", warning = TRUE)

/datum/skeleton_access/proc/finish_revoke()
	revoke_timer = null
	enabled = FALSE
	SSjob.update_skeleton_access()
	log_id("Skeleton crew access to [access_names()] withdrawn, [cause].")
	announce("[cause]. [access_names()] access withdrawn.", warning = TRUE)

/datum/skeleton_access/proc/announce(message, warning = FALSE)
	for(var/datum/mind/crew_mind as anything in get_crewmember_minds())
		var/obj/item/card/id/card = crew_mind.current?.get_idcard(hand_first = FALSE)
		if(card && applies_to(card.job_title) && notifies(card.job_title))
			card.card_talk(message, warning)

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

#undef SKELETON_ACCESS_GRACE
