/*
			< ATTENTION >
	If you need to add more map_adjustment, check 'map_adjustment_include.dm'
	These 'map_adjustment.dm' files shouldn't be included in 'dme'
*/

/datum/map_adjustment/pubby_station
	map_file_name = "PubbyStation.dmm"

/datum/map_adjustment/pubby_station/job_change()
	change_job_access(JOB_NAME_EXPLORATION_CREW, ACCESS_MAINT_TUNNELS)
	change_job_access(JOB_NAME_HEAD_OF_SECURITY, ACCESS_CREMATORIUM)
	change_job_access(JOB_NAME_WARDEN, ACCESS_CREMATORIUM)
	change_job_access(JOB_NAME_SECURITY_OFFICER, ACCESS_CREMATORIUM)

/datum/map_adjustment/pubby_station/on_mapping_init()
	exclude_tagger_destination("Virology")
	exclude_tagger_destination("Library")
	exclude_tagger_destination("Chapel")
	exclude_tagger_destination("Xenobiology")
