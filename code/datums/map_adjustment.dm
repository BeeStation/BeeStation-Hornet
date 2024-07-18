/datum/map_adjustment
	/// Check /datum/map_config/var/map_file
	var/map_file_name = "some_station_map.dmm" // change yourself
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
		job.base_access += access_to_give

//// ---- RAD STATION ---- ////
/datum/map_adjustment/RadStation
	map_file_name = "RadStation.dmm"
	no_lavaland = TRUE
	central_orbit = /datum/orbital_object/z_linked/station

//// ---- ECHO STATION ---- ////
/datum/map_adjustment/EchoStation
	map_file_name = "EchoStation.dmm"
	no_lavaland = TRUE
	central_orbit = /datum/orbital_object/z_linked/station
	blacklisted_jobs = list(
		JOB_NAME_ATMOSPHERICTECHNICIAN,
		JOB_NAME_BARTENDER,
		JOB_NAME_BRIGPHYSICIAN,
		JOB_NAME_EXPLORATIONCREW,
		JOB_NAME_GENETICIST,
		JOB_NAME_PARAMEDIC,
		JOB_NAME_VIROLOGIST)

/datum/map_adjustment/EchoStation/job_change()
	change_job_position(JOB_NAME_COOK, 1)
	change_job_position(JOB_NAME_CHEMIST, 1)
	change_job_position(JOB_NAME_JANITOR, 1)
	change_job_position(JOB_NAME_LAWYER, 1)
	change_job_position(JOB_NAME_BOTANIST, 1)
	change_job_access(JOB_NAME_ASSISTANT, ACCESS_MAINT_TUNNELS) // sample code
