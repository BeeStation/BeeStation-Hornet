/datum/map_template/shuttle/ship/golem
	faction = /datum/faction/golems

/datum/map_template/shuttle/ship/golem/free_golem_ship
	name = "Free Golem Ship"
	id = "golem_ship"
	suffix = "golem_ship"
	port_id = "encounter"

	difficulty = 30

	amount_left = 1

/datum/map_template/shuttle/ship/golem/free_golem_ship/can_place()
	//Cannot spawn if we already exist
	for(var/landmark in GLOB.ruin_landmarks)
		var/obj/effect/landmark/ruin/L = landmark
		if(istype(L.ruin_template, /datum/map_template/ruin/lavaland/free_golem))
			return FALSE
	return ..()
