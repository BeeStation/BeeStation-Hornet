/*
			< ATTENTION >
	If you need to add more map_adjustment, check 'map_adjustment_include.dm'
	These 'map_adjustment.dm' files shouldn't be included in 'dme'
*/

/datum/map_adjustment/box_station
	map_file_name = "BoxStation.dmm"

/datum/map_adjustment/box_station/on_department_init()
	ADD_MAP_ACCESS(/datum/map_exclusive_access/psychotherapy)
	ADD_MAP_ACCESS(/datum/map_exclusive_access/box/vacant)
	ADD_MAP_ACCESS(/datum/map_exclusive_access/box/commissary)

/datum/map_exclusive_access/box/vacant
	access_code = ACCESS_BOX_VACANT
	access_name = "+Vacant Office (Arrival)"
	department_codes = DEPT_NAME_SERVICE
	jobs_for_base_access = JOB_NAME_HEADOFPERSONNEL

/datum/map_exclusive_access/box/commissary
	access_code = ACCESS_BOX_COMMISSARY
	access_name = "+Commissary (Cargo)"
	department_codes = DEPT_NAME_SERVICE
	jobs_for_base_access = JOB_NAME_HEADOFPERSONNEL
