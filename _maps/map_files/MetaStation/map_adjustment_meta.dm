/*
			< ATTENTION >
	If you need to add more map_adjustment, check 'map_adjustment_include.dm'
	These 'map_adjustment.dm' files shouldn't be included in 'dme'
*/

/datum/map_adjustment/meta_station
	map_file_name = "MetaStation.dmm"

/datum/map_adjustment/meta_station/on_department_init()
	ADD_MAP_ACCESS(/datum/map_exclusive_access/psychotherapy)
	ADD_MAP_ACCESS(/datum/map_exclusive_access/meta/vacant)
	ADD_MAP_ACCESS(/datum/map_exclusive_access/meta/commissary)
	ADD_MAP_ACCESS(/datum/map_exclusive_access/meta/exhibit)

/datum/map_exclusive_access/meta/vacant
	access_code = ACCESS_META_VACANT
	access_name = "+Vacant Office (Arrival)"
	department_codes = DEPT_NAME_SERVICE
	jobs_for_base_access = JOB_NAME_HEADOFPERSONNEL

/datum/map_exclusive_access/meta/commissary
	access_code = ACCESS_META_COMMISSARY
	access_name = "+Commissary (Bridge)"
	department_codes = DEPT_NAME_SERVICE
	jobs_for_base_access = JOB_NAME_HEADOFPERSONNEL

/datum/map_exclusive_access/meta/exhibit
	access_code = ACCESS_META_EXHIBIT
	access_name = "+Exhibit"
	department_codes = DEPT_NAME_COMMAND
	jobs_for_base_access = list(
		JOB_NAME_HEADOFPERSONNEL,
		JOB_NAME_HEADOFSECURITY,
		JOB_NAME_CHIEFENGINEER,
		JOB_NAME_CHIEFMEDICALOFFICER,
		JOB_NAME_RESEARCHDIRECTOR,
	)
