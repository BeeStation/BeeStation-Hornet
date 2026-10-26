#define SKELETON_ACCESS_GRACE (5 MINUTES)

/// Lowpop access for the recipient jobs while the jobs they cover are empty
/datum/skeleton_access
	/// Colors the rule. With no recipients set, only this department is notified
	var/datum/department_group/department
	/// Titles of the jobs that get the access. Null means everyone
	var/list/recipients
	/// Titles of the jobs being covered for. The rule is off while any of them is filled
	var/list/covered_jobs = list()
	/// Covers every job in this department instead of covered_jobs
	var/datum/department_group/covered_department
	var/list/access
	/// The rule is off once the crew count reaches this
	var/population_limit = LOWPOP_JOB_LIMIT
	/// Includes the grace period. Change it with set_enabled()
	var/enabled = FALSE
	var/timer_id
	var/revoking = FALSE
	var/cause
	/// Cards that got their job after this job_assignment_id don't get the access. Null means no cutoff
	var/revoke_after_assignment

/datum/skeleton_access/proc/get_covered_jobs()
	RETURN_TYPE(/list)
	if(!covered_department)
		return covered_jobs
	var/datum/department_group/department_datum = SSdepartment.department_datums_by_type[covered_department]
	return SSdepartment.get_job_titles_by_dept_id(department_datum.dept_id)

/// Why the rule should be off, or null if it should be on
/datum/skeleton_access/proc/get_inactive_reason()
	for(var/title in get_covered_jobs())
		if(!SSjob.is_job_empty(title))
			return "[title] reported for duty"
		if(SSjob.has_acting_head(title))
			return "Acting [title] appointed"
	if(SSjob.get_crew_count() >= population_limit)
		return "Crew levels restored"
	return null

/// Whether the card gets this rule's access while the rule is on
/datum/skeleton_access/proc/gives_to(obj/item/card/id/card)
	if(!card.job_title || (!isnull(recipients) && !(card.job_title in recipients)))
		return FALSE
	// Someone hired after the handover started shouldn't get access that's already ending
	return isnull(revoke_after_assignment) || card.job_assignment_id <= revoke_after_assignment

/datum/skeleton_access/proc/notifies(job_title)
	if(recipients || !department)
		return TRUE
	var/datum/job/job = SSjob.get_job(job_title)
	return department in job?.departments_list

/datum/skeleton_access/proc/get_color_class()
	var/datum/department_group/color_department = covered_department || department
	var/channel = color_department && initial(color_department.dept_radio_channel)
	return channel && get_radio_span(channel)

/datum/skeleton_access/proc/covering_text(colored = FALSE)
	var/subject
	if(covered_department)
		subject = initial(covered_department.department_name)
	else if(length(covered_jobs))
		subject = english_list(covered_jobs)
	else
		subject = "an understaffed station"
	var/color_class = colored && get_color_class()
	if(color_class)
		subject = "<span class='[color_class]'>[subject]</span>"
	return "Covering for [subject]"

/datum/skeleton_access/proc/timing_text()
	if(revoking)
		return "handing over in [DisplayTimeText(timeleft(timer_id))]"
	if(covered_department)
		return "ends when department has staff or total crew reaches [population_limit]"
	if(length(covered_jobs))
		return "ends when position has staff or total crew reaches [population_limit]"
	return "ends when total crew reaches [population_limit]"

/// Turning off waits out SKELETON_ACCESS_GRACE
/datum/skeleton_access/proc/refresh(mob/living/arrival)
	var/inactive_reason = get_inactive_reason()
	if(isnull(inactive_reason))
		if(revoking)
			revoking = FALSE
			deltimer(timer_id)
			timer_id = null
			revoke_after_assignment = null
			log_id("Skeleton crew. [covering_text()]: handover cancelled, [get_access_desc(access)] access continues.")
			var/list/changes = get_notified_changes()
			for(var/obj/item/card/id/card as anything in changes)
				card.card_talk("Handover cancelled: [get_access_desc(changes[card])] access continues ([timing_text()]).")
			return
		if(!enabled)
			set_enabled(TRUE)
			log_id("Skeleton crew. [covering_text()]: [get_access_desc(access)] access authorized ([timing_text()]).")
			var/list/changes = get_notified_changes()
			for(var/obj/item/card/id/card as anything in changes)
				card.card_talk("[covering_text(TRUE)]: [get_access_desc(changes[card])] access authorized ([timing_text()]).")
		return
	if(!enabled || revoking)
		return
	revoking = TRUE
	cause = inactive_reason
	var/obj/item/card/id/arrival_card = arrival?.get_idcard(hand_first = FALSE)
	revoke_after_assignment = arrival_card?.job_assignment_id ? arrival_card.job_assignment_id - 1 : SSjob.job_assignment_count
	timer_id = addtimer(CALLBACK(src, PROC_REF(finish_revoke)), SKELETON_ACCESS_GRACE, TIMER_STOPPABLE)
	log_id("Skeleton crew. [covering_text()]: [get_access_desc(access)] access ends in [DisplayTimeText(SKELETON_ACCESS_GRACE)], [cause].")
	var/list/changes = get_notified_changes()
	for(var/obj/item/card/id/card as anything in changes)
		card.card_talk("[cause]. Finish up and hand over: [get_access_desc(changes[card])] access ends in [DisplayTimeText(SKELETON_ACCESS_GRACE)].", warning = TRUE)

/datum/skeleton_access/proc/set_enabled(new_enabled)
	enabled = new_enabled
	if(enabled)
		SSjob.enabled_skeleton_rules |= src
	else
		SSjob.enabled_skeleton_rules -= src

/datum/skeleton_access/proc/finish_revoke()
	timer_id = null
	revoking = FALSE
	set_enabled(FALSE)
	log_id("Skeleton crew. [covering_text()]: [get_access_desc(access)] access withdrawn, [cause].")
	var/list/changes = get_notified_changes()
	for(var/obj/item/card/id/card as anything in changes)
		card.card_talk("[cause]: [get_access_desc(changes[card])] access handed over. Thanks for covering.")
	revoke_after_assignment = null

/// Cards to tell about this rule's change, each mapped to the access it changes on that card
/datum/skeleton_access/proc/get_notified_changes()
	RETURN_TYPE(/list)
	. = list()
	for(var/datum/mind/crew_mind as anything in get_crewmember_minds())
		var/obj/item/card/id/card = crew_mind.current?.get_idcard(hand_first = FALSE)
		if(!card || !gives_to(card) || !notifies(card.job_title))
			continue
		var/list/changed = get_changed_access(card)
		if(length(changed))
			.[card] = changed

/// Access this rule's change affects on the card, leaving out access another rule keeps giving it
/datum/skeleton_access/proc/get_changed_access(obj/item/card/id/card)
	RETURN_TYPE(/list)
	. = card.get_skeleton_gain(access)
	var/already_ended = !enabled
	for(var/datum/skeleton_access/other as anything in card.get_skeleton_rules())
		if(other == src)
			continue
		// Only announce access the card actually loses. A rule also handing over won't keep it, unless this rule has already ended
		var/outlasts_change = !other.revoking || already_ended
		if(outlasts_change)
			. -= other.access

/datum/skeleton_access/engineering
	abstract_type = /datum/skeleton_access/engineering
	department = /datum/department_group/engineering
	recipients = list(JOB_NAME_STATIONENGINEER)

/datum/skeleton_access/engineering/chief_engineer
	covered_jobs = list(JOB_NAME_CHIEFENGINEER)
	access = list(ACCESS_CE)
	population_limit = COMMAND_POPULATION_MINIMUM

/datum/skeleton_access/engineering/atmospheric_technician
	covered_jobs = list(JOB_NAME_ATMOSPHERICTECHNICIAN)
	access = list(ACCESS_ATMOSPHERICS)

/datum/skeleton_access/engineering/station_engineer
	recipients = list(JOB_NAME_ATMOSPHERICTECHNICIAN)
	covered_jobs = list(JOB_NAME_STATIONENGINEER)
	access = list(ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_TECH_STORAGE)

/datum/skeleton_access/medical
	abstract_type = /datum/skeleton_access/medical
	department = /datum/department_group/medical
	recipients = list(JOB_NAME_MEDICALDOCTOR)

/datum/skeleton_access/medical/chief_medical_officer
	covered_jobs = list(JOB_NAME_CHIEFMEDICALOFFICER)
	access = list(ACCESS_CMO)
	population_limit = COMMAND_POPULATION_MINIMUM

/datum/skeleton_access/medical/chemist
	covered_jobs = list(JOB_NAME_CHEMIST)
	access = list(ACCESS_CHEMISTRY)

/datum/skeleton_access/medical/geneticist
	covered_jobs = list(JOB_NAME_GENETICIST)
	access = list(ACCESS_GENETICS)

/datum/skeleton_access/medical/medical_doctor
	recipients = list(JOB_NAME_PARAMEDIC, JOB_NAME_CHEMIST, JOB_NAME_GENETICIST, JOB_NAME_VIROLOGIST)
	covered_jobs = list(JOB_NAME_MEDICALDOCTOR)
	access = list(ACCESS_SURGERY, ACCESS_CLONING, ACCESS_VIROLOGY)

/datum/skeleton_access/science
	abstract_type = /datum/skeleton_access/science
	department = /datum/department_group/science
	recipients = list(JOB_NAME_SCIENTIST)

/datum/skeleton_access/science/research_director
	covered_jobs = list(JOB_NAME_RESEARCHDIRECTOR)
	access = list(ACCESS_RD, ACCESS_RD_SERVER)
	population_limit = COMMAND_POPULATION_MINIMUM

/datum/skeleton_access/science/roboticist
	covered_jobs = list(JOB_NAME_ROBOTICIST)
	access = list(ACCESS_ROBOTICS)

/datum/skeleton_access/science/exploration_crew
	covered_jobs = list(JOB_NAME_EXPLORATIONCREW)
	access = list(ACCESS_EXPLORATION)

/datum/skeleton_access/science/scientist
	recipients = list(JOB_NAME_ROBOTICIST, JOB_NAME_EXPLORATIONCREW)
	covered_jobs = list(JOB_NAME_SCIENTIST)
	access = list(ACCESS_TOX, ACCESS_TOX_STORAGE, ACCESS_XENOBIOLOGY)

/datum/skeleton_access/science/tech_storage
	access = list(ACCESS_TECH_STORAGE)

/datum/skeleton_access/security
	abstract_type = /datum/skeleton_access/security
	department = /datum/department_group/security
	recipients = list(JOB_NAME_SECURITYOFFICER)

/datum/skeleton_access/security/armory
	covered_jobs = list(JOB_NAME_HEADOFSECURITY, JOB_NAME_WARDEN)
	access = list(ACCESS_ARMORY)
	population_limit = COMMAND_POPULATION_MINIMUM

/datum/skeleton_access/security/detective
	covered_jobs = list(JOB_NAME_DETECTIVE)
	access = list(ACCESS_FORENSICS_LOCKERS, ACCESS_MORGUE)

/datum/skeleton_access/security/brig_physician
	covered_jobs = list(JOB_NAME_BRIGPHYSICIAN)
	access = list(ACCESS_BRIGPHYS)

/datum/skeleton_access/security/maintenance
	access = list(ACCESS_MAINT_TUNNELS)

/datum/skeleton_access/cargo
	abstract_type = /datum/skeleton_access/cargo
	department = /datum/department_group/cargo
	recipients = list(JOB_NAME_CARGOTECHNICIAN)

/datum/skeleton_access/cargo/quartermaster
	covered_jobs = list(JOB_NAME_QUARTERMASTER)
	access = list(ACCESS_QM, ACCESS_VAULT)

/datum/skeleton_access/cargo/shaft_miner
	covered_jobs = list(JOB_NAME_SHAFTMINER)
	access = list(ACCESS_GATEWAY, ACCESS_MINING, ACCESS_MINING_STATION)

/datum/skeleton_access/cargo/cargo_technician
	recipients = list(JOB_NAME_SHAFTMINER)
	covered_jobs = list(JOB_NAME_CARGOTECHNICIAN)
	access = list(ACCESS_CARGO)

/datum/skeleton_access/cargo/gateway
	access = list(ACCESS_GATEWAY)

/datum/skeleton_access/service
	abstract_type = /datum/skeleton_access/service
	department = /datum/department_group/service
	recipients = list(JOB_NAME_ASSISTANT)

/datum/skeleton_access/service/cook
	recipients = null
	covered_jobs = list(JOB_NAME_COOK)
	access = list(ACCESS_KITCHEN)

/datum/skeleton_access/service/bartender
	covered_jobs = list(JOB_NAME_BARTENDER)
	access = list(ACCESS_BAR, ACCESS_JANITOR)

/datum/skeleton_access/service/botanist
	covered_jobs = list(JOB_NAME_BOTANIST)
	access = list(ACCESS_HYDROPONICS)

/datum/skeleton_access/service/clown
	covered_jobs = list(JOB_NAME_CLOWN)
	access = list(ACCESS_THEATRE)

/datum/skeleton_access/service/curator
	covered_jobs = list(JOB_NAME_CURATOR)
	access = list(ACCESS_LIBRARY)

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
		ACCESS_CHAPEL_OFFICE, ACCESS_BAR, ACCESS_JANITOR, ACCESS_CREMATORIUM, ACCESS_KITCHEN, ACCESS_HYDROPONICS, ACCESS_LIBRARY,ACCESS_THEATRE,
		ACCESS_MAILSORTING, ACCESS_MINING_STATION, ACCESS_GATEWAY, ACCESS_MINERAL_STOREROOM, ACCESS_MINING,
		ACCESS_CONSTRUCTION,
	)

/datum/skeleton_access/station_unlock/cargo
	covered_department = /datum/department_group/cargo
	access = list(ACCESS_CARGO)

/datum/skeleton_access/station_unlock/science
	covered_department = /datum/department_group/science
	access = list(
		ACCESS_TOX, ACCESS_TOX_STORAGE, ACCESS_ROBOTICS,
		ACCESS_RESEARCH, ACCESS_EXPLORATION, ACCESS_XENOBIOLOGY
	)

/datum/skeleton_access/station_unlock/engineering
	covered_department = /datum/department_group/engineering
	access = list(ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_ATMOSPHERICS)

/datum/skeleton_access/station_unlock/medical
	covered_department = /datum/department_group/medical
	access = list(
		ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_GENETICS,
		ACCESS_CHEMISTRY, ACCESS_VIROLOGY, ACCESS_SURGERY,
		ACCESS_CLONING
	)

#undef SKELETON_ACCESS_GRACE
