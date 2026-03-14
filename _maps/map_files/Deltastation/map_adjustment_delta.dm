/*
			< ATTENTION >
	If you need to add more map_adjustment, check 'map_adjustment_include.dm'
	These 'map_adjustment.dm' files shouldn't be included in 'dme'
*/

/datum/map_adjustment/delta_station
	map_file_name = "DeltaStation2.dmm"

/datum/map_adjustment/delta_station/on_department_init()
	ADD_MAP_ACCESS(/datum/map_exclusive_access/psychotherapy)
	ADD_MAP_ACCESS(/datum/map_exclusive_access/delta/vacant)

/datum/map_exclusive_access/delta/vacant
	access_code = ACCESS_DELTA_VACANT
	access_name = "+Vacant Office (Library)"
	department_codes = DEPT_NAME_SERVICE
	jobs_for_base_access  = JOB_NAME_HEADOFPERSONNEL
