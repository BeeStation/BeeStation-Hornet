/*
			< ATTENTION >
	If you need to add more map_adjustment, check 'map_adjustment_include.dm'
	These 'map_adjustment.dm' files shouldn't be included in 'dme'
*/

/datum/map_adjustment/echo_station/job_change()
	change_job_position(JOB_NAME_SCIENTIST, 3)
	change_job_position(JOB_NAME_STATIONENGINEER, 4)
