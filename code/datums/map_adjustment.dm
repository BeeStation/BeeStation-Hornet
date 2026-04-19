/*
 *	[What does this do?]
 * 		It supports to make adjustment for each map
 *
 * 	[Why don't you just make this with map json file?]
 * 		Some stuff is easy to mistake.
 * 		Being a part of DM files can make a failsafe.
 *
 * 		For example, let's say "Paramedic" is removed from the game.
 * 		But json file will still keep it.
 * 		Or let's say you mistype Pamadic
 * 		Using job defines will be safe
 *
 * 	[I want to add a map adjustment for a map]
 * 		There is a live sample with 'EchoStation'
 *
*/
/datum/map_adjustment
	/// key of map_adjustment. It is used to check if '/datum/map_config/var/map_file' is matched
	var/map_file_name = "some_station_map.dmm" // change yourself
	/// Jobs that this station map won't use
	var/list/blacklisted_jobs

/// called on map config is loaded.
/// You need to change things manually here.
/datum/map_adjustment/proc/on_mapping_init()
	return

/// called upon SSdepartment initialization. Override this proc to change.
/datum/map_adjustment/proc/on_department_init()
	return

/// called upon job datum creation. Override this proc to change.
/datum/map_adjustment/proc/job_change()
	return

/// * job_name<string/JOB_DEFINES>: 	JOB_NAME macros from jobs.dm
/// * total_positions<number>: 	Sets the number of total positions of this job, including roundstart and latejoin
/datum/map_adjustment/proc/change_job_position(job_name, total_positions)
	SHOULD_NOT_OVERRIDE(TRUE) // no reason to override for a new behaviour
	PROTECTED_PROC(TRUE) // no reason to call this outside of /map_adjustment datum. (I didn't add _underbar_ to the proc name because you use this frequently)
	var/datum/job/job = SSjob.GetJob(job_name)
	if(!job)
		CRASH("Failed to adjust a job position: [job_name]")
	job.total_positions = total_positions

/// * job_name<string/JOB_DEFINES>: 		JOB_NAME macros from jobs.dm
/// * access_to_give<number/ACCESS_DEFINES, list/[ACCESS_DEFINES], null>: 	gives new access(es) to this job in this station map
/// * access_to_remove<number/ACCESS_DEFINES, list/[ACCESS_DEFINES], null>:	removes existing access(es) from this job in this station map
/datum/map_adjustment/proc/change_job_access(job_name, list/access_to_give = null, list/access_to_remove = null) // it's fine not to be a list
	SHOULD_NOT_OVERRIDE(TRUE) // no reason to override for a new behaviour
	PROTECTED_PROC(TRUE) // no reason to call this outside of /map_adjustment datum. (I didn't add _underbar_ to the proc name because you use this frequently)
	var/datum/job/job = SSjob.GetJob(job_name)
	if(!job)
		CRASH("Failed to adjust a job position: [job_name]")
	if(access_to_remove)
		job.base_access -= access_to_remove
	if(access_to_give)
		job.base_access |= access_to_give




// ------------------------------------------------------------------------------------
// a datum that is automatically managed upon New(). The access will be given to the access list of department and job.
// After adding the access to the game, the datum will be automatically qdeleted.
/datum/map_exclusive_access
	/// access_to_give<number/ACCESS_DEFINES> : target access. Do not put /list
	var/access_code
	/// a dedicated access name. This is necessary for GLOB.access_desc_list
	var/access_name
	/// department_name<string/DEPARTMENT_DEFINES[accepts list]> : Department name macros from department.dm
	var/list/department_codes
	// Note: Captain will always have AA regardless of the jobs list
	/// jobs_for_base_access<string/JOB_DEFINES[accepts list]>: gives the access to the jobs (base access)
	var/list/jobs_for_base_access
	/// jobs_for_extra_access<string/JOB_DEFINES[accepts list]>: gives the access to the jobs (extra access)
	var/list/jobs_for_extra_access
	/// If set TRUE, the access will be given to Security officer who spawns in a security departmental post
	var/grant_to_department_security_officer = FALSE

// a simple sample for Psychiatrist's room
/datum/map_exclusive_access/therapy_den
	access_code = ACCESS_ALLMAP_THERAPY_DEN
	access_name = "Therapy Den"
	department_codes = DEPT_NAME_MEDICAL
	jobs_for_base_access  = list(JOB_NAME_PSYCHIATRIST, JOB_NAME_CHIEFMEDICALOFFICER, JOB_NAME_MEDICALDOCTOR)
	jobs_for_extra_access = list(JOB_NAME_PARAMEDIC, JOB_NAME_CHEMIST, JOB_NAME_GENETICIST, JOB_NAME_VIROLOGIST)
	grant_to_department_security_officer = FALSE // Human right, Officer!!!


/datum/map_exclusive_access/New()
	if(islist(access_code))
		CRASH("You did the code wrong - [type] should not be /list. Use a single access macro.")

	if(GLOB.access_desc_list["[access_code]"])
		stack_trace("'GLOB.access_desc_list' already has the access [access_code] ([type]) (Name: [access_name])")
	else if(access_name)
		GLOB.access_desc_list["[access_code]"] = access_name
	else
		stack_trace("The access [access_code] ([type]) has no name")

	// department_codes part
	if(istext(department_codes))
		department_codes = list(department_codes)
	for(var/each_dept_code in department_codes)
		var/datum/department_group/dept = SSdepartment.get_department_by_dept_id(each_dept_code)
		dept.access_list |= access_code

		// Giving access to security officers
		if(grant_to_department_security_officer)
			var/datum/job/security_officer/security_officer = SSjob.GetJob(JOB_NAME_SECURITYOFFICER)
			switch(each_dept_code)
				if(DEPT_NAME_CARGO)
					security_officer.dept_access_supply |= access_code
				if(DEPT_NAME_MEDICAL)
					security_officer.dept_access_medical |= access_code
				if(DEPT_NAME_ENGINEERING)
					security_officer.dept_access_science |= access_code
				if(DEPT_NAME_SCIENCE)
					security_officer.dept_access_engineering |= access_code
				if(DEPT_NAME_SERVICE, DEPT_NAME_CIVILIAN)
					pass() // we do not have this yet

	// Managing job access by map adjustment is cleaner more than doing that in individual jobs
	// jobs_for_base_access part
	if(istext(jobs_for_base_access))
		jobs_for_base_access = list(jobs_for_base_access)
	for(var/each_job_name in jobs_for_base_access)
		var/datum/job/job = SSjob.GetJob(each_job_name)
		if(!job)
			CRASH("Failed to adjust access for jobs: [each_job_name]")
		job.base_access |= access_code

	// // jobs_for_extra_access part
	if(istext(jobs_for_extra_access))
		jobs_for_extra_access = list(jobs_for_extra_access)
	for(var/each_job_name in jobs_for_extra_access)
		var/datum/job/job = SSjob.GetJob(each_job_name)
		if(!job)
			CRASH("Failed to adjust access for jobs: [each_job_name]")
		job.extra_access |= access_code

	// self-qdel process
	department_codes = null
	jobs_for_base_access = null
	jobs_for_extra_access = null
	qdel(src)
