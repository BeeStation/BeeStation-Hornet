/datum/star_system
	var/name = "Sol"
	var/unique_id = 0
	var/map_x = 100	//Between 0 and 1000
	var/map_y = 100 //Between 0 and 1000
	var/list/linked_stars = list()

	var/visited = FALSE
	var/star_color = "#ffffff"

	var/is_station_z = FALSE

	//572 possible names
	var/static/list/first_symbols = list(
		"h", "v", "c", "e", "g", "d", "r", "n", "h", "o", "p",
		"ra", "so", "at", "il", "ta", "sh", "ya", "te", "sh", "ol", "ma", "om", "ig", "ni", "in"
	)
	var/static/list/second_symbols = list(
		"na", "ba", "da", "ne", "le", "la", "ol",
		"nar", "nie", "bie", "bar", "nar", "raw", "car", "lar", "lim", "dim", "rak",
		"romeda", "retigo", "liga", "risoft"
	)

	var/distance_from_center = 0

	var/datum/star_system_data/system_data

	//After generation
	var/datum/faction/system_alignment
	var/calculated_threat
	var/calculated_research_potential = 0

	//Which ruin pool to pull from
	var/bluespace_ruins = FALSE

/datum/star_system/New(distance)
	. = ..()
	distance_from_center = distance
	var/static/stars = 0
	unique_id = stars ++
	//Get a realistic star colour
	star_color = pick(STAR_COLORS)
	//Generate a name (We will just use nar'sian names because it sounds ok)
	name = capitalize("[pick(first_symbols)][pick(second_symbols)]-[pick(GLOB.hex_characters)][pick(GLOB.hex_characters)]")
	//Generate things
	generate_encounters()

/datum/star_system/proc/generate_encounters()
	var/zerotoonehundred = normalize_difficulty()
	//Faction Selection
	//Base difficulty + random variance
	switch(rand(0, zerotoonehundred) + rand(-20, 20))
		if(-INFINITY to 0)
			//Peaceful faction
			system_alignment = SSbluespace_exploration.get_faction(/datum/faction/nanotrasen)
		if(0 to 20)
			system_alignment = SSbluespace_exploration.get_faction(/datum/faction/nanotrasen)
		if(20 to 50)
			system_alignment = SSbluespace_exploration.get_faction(pick(/datum/faction/spider_clan, /datum/faction/independant))
		if(50 to 70)
			system_alignment = SSbluespace_exploration.get_faction(pick(subtypesof(/datum/faction/syndicate) - /datum/faction/syndicate/elite))
		if(70 to 100)
			system_alignment = SSbluespace_exploration.get_faction(/datum/faction/syndicate/elite)
	//Set other factors
	calculated_threat = CLAMP(rand(0, zerotoonehundred) + rand(-40, 20), 0, 40)
	calculated_research_potential = CLAMP(rand(0, zerotoonehundred), 0, 50) - rand(0, 10)
	message_admins("Distance = [distance_from_center] | Zerotohundred = [zerotoonehundred]")

/datum/star_system/proc/normalize_difficulty()
	return 100 * (1 - sin(1 / (abs(distance_from_center / 5) + (1 / 1.57))))
