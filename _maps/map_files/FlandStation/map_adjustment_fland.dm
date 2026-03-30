/*
			< ATTENTION >
	If you need to add more map_adjustment, check 'map_adjustment_include.dm'
	These 'map_adjustment.dm' files shouldn't be included in 'dme'
*/

/datum/map_adjustment/fland_station
	map_file_name = "FlandStation.dmm"

/datum/map_adjustment/fland_station/on_department_init()
	ADD_MAP_ACCESS(/datum/map_exclusive_access/psychotherapy)
	ADD_MAP_ACCESS(/datum/map_exclusive_access/fland/commissary_medical)
	ADD_MAP_ACCESS(/datum/map_exclusive_access/fland/commissary_general)
	ADD_MAP_ACCESS(/datum/map_exclusive_access/fland/commissary_evac)

/datum/map_exclusive_access/fland/commissary_medical
	access_code = ACCESS_FLAND_COMMISSARY_MEDICAL
	access_name = "+Commissary (Medical)"
	department_codes = DEPT_NAME_SERVICE
	jobs_for_base_access  = JOB_NAME_HEADOFPERSONNEL

/datum/map_exclusive_access/fland/commissary_general
	access_code = ACCESS_FLAND_COMMISSARY_GENERAL
	access_name = "+Commissary (General)"
	department_codes = DEPT_NAME_SERVICE
	jobs_for_base_access  = JOB_NAME_HEADOFPERSONNEL

/datum/map_exclusive_access/fland/commissary_evac
	access_code = ACCESS_FLAND_COMMISSARY_EVAC
	access_name = "+Commissary (EVAC)"
	department_codes = DEPT_NAME_SERVICE
	jobs_for_base_access  = JOB_NAME_HEADOFPERSONNEL
