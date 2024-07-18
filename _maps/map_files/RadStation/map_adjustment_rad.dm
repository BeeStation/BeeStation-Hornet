/*
			< ATTENTION >
	If you need to add more map_adjustment, check 'map_adjustment_include.dm'
	These 'map_adjustment.dm' files shouldn't be included in 'dme'
*/

/datum/map_adjustment/RadStation
	map_file_name = "RadStation.dmm"
	no_lavaland = TRUE
	central_orbit = /datum/orbital_object/z_linked/station
