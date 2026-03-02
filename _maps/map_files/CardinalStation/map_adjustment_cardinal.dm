/*
			< ATTENTION >
	If you need to add more map_adjustment, check 'map_adjustment_include.dm'
	These 'map_adjustment.dm' files shouldn't be included in 'dme'
*/

/datum/map_adjustment/cardinal_station
	map_file_name = "CardinalStation.dmm"

/datum/map_adjustment/cardinal_station/on_department_init()
	ADD_MAP_ACCESS(/datum/map_exclusive_access/psychotherapy)
