/datum/map_adjustment
	/// key of map_adjustment. It is used to check if '/datum/map_config/var/map_file' is matched
	var/map_file_name = "some_station_map.dmm" // change yourself
	/// Jobs that this station map won't use
	var/list/blacklisted_jobs
	/// if TRUE, we won't spawn lavaland
	var/no_lavaland
	/// Determines which orbital planet will become the centre of the universe
	/// * If not specified, "/datum/orbital_object/z_linked/lavaland" is default
	var/datum/orbital_object/central_orbit

/// called upon job datum creation. Override this proc to change.
/datum/map_adjustment/proc/job_change()
	return

/// * job_name[string/JOB_DEFINES]: 	JOB_NAME macros from jobs.dm
/// * spawn_positions[number]: 		how many positions of this job will be spawned at roundstart
/// * total_positions[number, null]: 	how many positions will be available from this map. If not specified, uses spawn_positions.
/datum/map_adjustment/proc/change_job_position(job_name, spawn_positions, total_positions = null)
	SHOULD_NOT_OVERRIDE(TRUE)
	var/datum/job/job = SSjob.GetJob(job_name)
	if(!job)
		CRASH("Failed to adjust a job position: [job_name]")
	job.spawn_positions = spawn_positions
	job.total_positions = total_positions || spawn_positions

/// * job_name[string/JOB_DEFINES]: 	JOB_NAME macros from jobs.dm
/// * access_to_give[number, list, null]:		which access this job will additionally be given
/// * access_to_remove[number, list, null]:
/datum/map_adjustment/proc/change_job_access(job_name, list/access_to_give = null, list/access_to_remove = null) // it's fine not to be a list
	SHOULD_NOT_OVERRIDE(TRUE)
	var/datum/job/job = SSjob.GetJob(job_name)
	if(!job)
		CRASH("Failed to adjust a job position: [job_name]")
	if(access_to_remove)
		job.base_access -= access_to_remove
	if(access_to_give)
		job.base_access |= access_to_give
