//A datum for the generation settings of a ruin
/datum/generator_settings
	//Probability of this generator being chosen.
	var/probability = 0
	//Probability of breaking the floor
	var/floor_break_prob = 0
	//Probability of applying damage to structures
	var/structure_damage_prob = 0

//Gets shit to place on floors
/datum/generator_settings/proc/get_floortrash()
	return list()

//Get directional stuff that goes on walls.
/datum/generator_settings/proc/get_directional_walltrash()
	return list()

//Gets non directional stuff that goes on walls
/datum/generator_settings/proc/get_non_directional_walltrash()
	return list()

//A list of rooms that can be placed on the map.
//Assoc list.
//key = ruin part
//value = max occurrences
/datum/generator_settings/proc/get_valid_rooms()
	. = list()
	for(var/datum/map_template/ruin_part/ruinpart as() in GLOB.loaded_ruin_parts)
		.[ruinpart] = ruinpart.max_occurrences

//A list of rooms to force place on the map.
//Useful for stuff like making crutch fuel outposts that have plasma in them.
/datum/generator_settings/proc/get_required_rooms()
	return list()
