/*
			< ATTENTION >
	If you need to add more map_adjustment, check 'map_adjustment_include.dm'
	These 'map_adjustment.dm' files shouldn't be included in 'dme'
*/

/datum/map_adjustment/echo_station
	map_file_name = "EchoStation.dmm"
	blacklisted_jobs = list(
		JOB_NAME_ATMOSPHERICTECHNICIAN,
		JOB_NAME_BARTENDER,
		JOB_NAME_BRIGPHYSICIAN,
		JOB_NAME_EXPLORATIONCREW,
		JOB_NAME_GENETICIST,
		JOB_NAME_PARAMEDIC,
		JOB_NAME_VIROLOGIST,
		JOB_NAME_PRISONER)

/datum/map_adjustment/echo_station/job_change()
	change_job_position(JOB_NAME_COOK, 1)
	change_job_position(JOB_NAME_CHEMIST, 1)
	change_job_position(JOB_NAME_JANITOR, 1)
	change_job_position(JOB_NAME_LAWYER, 1)
	change_job_position(JOB_NAME_BOTANIST, 1)
	change_job_position(JOB_NAME_SHAFTMINER, 1)
	change_job_access(JOB_NAME_ASSISTANT, ACCESS_MAINT_TUNNELS) // sample code

/datum/map_adjustment/echo_station/on_mapping_init()
	exclude_tagger_destination("Virology")
	exclude_tagger_destination("Law Office")
