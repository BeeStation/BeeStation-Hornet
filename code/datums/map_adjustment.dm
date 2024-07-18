/datum/map_adjustment
	/// key of map_adjustment. It is used to check if '/datum/map_config/var/map_file' is matched
	var/map_file_name = "some_station_map.dmm" // change yourself
	/// Jobs that this station map won't use
	var/list/blacklisted_jobs
	/// if TRUE, we won't spawn lavaland
	var/no_lavaland
	/// Determines which orbital planet will become the centre of the universe
	var/central_orbit

/datum/map_adjustment/proc/job_change()
	return

/datum/map_adjustment/proc/change_job_position(job_name, spawn_positions, total_positions = null)
	var/datum/job/job = SSjob.GetJob(job_name)
	if(!job)
		CRASH("Failed to adjust a job position: [job_name]")
	job.spawn_positions = spawn_positions
	job.total_positions = total_positions || spawn_positions

/datum/map_adjustment/proc/change_job_access(job_name, list/access_to_give = null, list/access_to_remove = null) // it's fine not to be a list
	var/datum/job/job = SSjob.GetJob(job_name)
	if(!job)
		CRASH("Failed to adjust a job position: [job_name]")
	if(access_to_remove)
		job.base_access -= access_to_remove
	if(access_to_give)
		job.base_access |= access_to_give
