/datum/star_system
	var/name = "Sol"
	var/map_x = 100	//Between 0 and 1000
	var/map_y = 100 //Between 0 and 1000
	var/list/linked_stars = list()

	var/star_color = "#ffffff"
	var/star_difficulty = 3

/datum/star_system/New()
	. = ..()
	//Get a realistic star colour
	star_color = pick(STAR_COLORS)
