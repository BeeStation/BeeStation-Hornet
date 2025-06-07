/*
			< ATTENTION >
	If you need to add more map_adjustment, check 'map_adjustment_include.dm'
	These 'map_adjustment.dm' files shouldn't be included in 'dme'
*/

/datum/map_adjustment/pubby_station
	map_file_name = "PubbyStation.dmm"

/datum/map_adjustment/pubby_station/job_change()
	change_job_access(JOB_NAME_EXPLORATIONCREW, ACCESS_MAINT_TUNNELS)
	change_job_access(JOB_NAME_HEADOFSECURITY, ACCESS_CREMATORIUM)
	change_job_access(JOB_NAME_WARDEN, ACCESS_CREMATORIUM)
	change_job_access(JOB_NAME_SECURITYOFFICER, ACCESS_CREMATORIUM)

/datum/map_adjustment/pubby_station/on_mapping_init()
	exclude_tagger_destination("Virology")
	exclude_tagger_destination("Library")
	exclude_tagger_destination("Chapel")
	exclude_tagger_destination("Xenobiology")
	exclude_tagger_destination("Testing Range")
