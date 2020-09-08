/*
 * Star system data
 * A datum that hold star system data
 * - Controlling Faction
 * - Difficulty
 * - Generation flags / features
*/

/datum/star_system_data
	//The controlling faction
	var/controlling_faction
	//Difficult (1 to 10)
	var/difficulty
	//Features of the place (asteroids etc.)
	var/list/features
