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
/// * access_to_remove<number/ACCESS_DEFINES, list/[ACCESS_DEFINES], null>:	removes existing access(es) to this job in this station map
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
