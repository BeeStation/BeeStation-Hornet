/*
			< ATTENTION >
	If you need to add more map_adjustment, check 'map_adjustment_include.dm'
	These 'map_adjustment.dm' files shouldn't be included in 'dme'
*/

/datum/map_adjustment/rad_station
	map_file_name = "RadStation.dmm"

/datum/map_adjustment/rad_station/on_department_init()
	ADD_MAP_ACCESS(/datum/map_exclusive_access/psychotherapy)
	ADD_MAP_ACCESS(/datum/map_exclusive_access/rad/vacant)
	ADD_MAP_ACCESS(/datum/map_exclusive_access/rad/commissary_west)
	ADD_MAP_ACCESS(/datum/map_exclusive_access/rad/commissary_south)

/datum/map_exclusive_access/rad/vacant
	access_code = ACCESS_BOX_VACANT
	access_name = "+Vacant Office (West)"
	department_codes = DEPT_NAME_SERVICE
	jobs_for_base_access  = JOB_NAME_HEADOFPERSONNEL

/datum/map_exclusive_access/rad/commissary_west
	access_code = ACCESS_RAD_COMMISSARY_WEST
	access_name = "+Commissary (West)"
	department_codes = DEPT_NAME_SERVICE
	jobs_for_base_access  = JOB_NAME_HEADOFPERSONNEL

/datum/map_exclusive_access/rad/commissary_south
	access_code = ACCESS_RAD_COMMISSARY_SOUTH
	access_name = "+Commissary (South)"
	department_codes = DEPT_NAME_SERVICE
	jobs_for_base_access  = JOB_NAME_HEADOFPERSONNEL
