/*
			< ATTENTION >
	If you need to add more map_adjustment, check 'map_adjustment_include.dm'
	These 'map_adjustment.dm' files shouldn't be included in 'dme'
*/

/datum/map_adjustment/meta_station
	map_file_name = "MetaStation.dmm"

/datum/map_adjustment/meta_station/on_department_init()
	change_department_access(DEPT_NAME_SERVICE, list(ACCESS_META_VACANT, ACCESS_META_COMMISSARY))
