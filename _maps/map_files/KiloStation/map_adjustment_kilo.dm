//Kilo aint neither the time nor place for prisoners, pardner.

/datum/map_adjustment/kilo_station
	map_file_name = "KiloStation.dmm"
	blacklisted_jobs = list(JOB_NAME_PRISONER)

/datum/map_adjustment/kilo_station/on_department_init()
	// ADD_MAP_ACCESS(/datum/map_exclusive_access/psychotherapy) // Kilo doesn't have this
	ADD_MAP_ACCESS(/datum/map_exclusive_access/kilo/commissary)

/datum/map_exclusive_access/kilo/commissary
	access_code = ACCESS_KILO_COMMISSARY
	access_name = "+Commissary (Janitorial)"
	department_codes = DEPT_NAME_SERVICE
	jobs_for_base_access  = JOB_NAME_HEADOFPERSONNEL
