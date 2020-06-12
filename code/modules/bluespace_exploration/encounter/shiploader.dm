/datum/map_template/shuttle/ship
	var/faction = "unset"

	var/allowed_weapons = list()

	var/id = null
	var/difficulty = 0

	prefix = "_maps/shuttles/exploration/"
	suffix = null

	can_be_bought = FALSE

/datum/map_template/shuttle/ship/proc/try_to_place(z,allowed_areas)
	//To give unique ids to all the spawned ships
	var/static/shuttles_spawned = 0
	var/sanity = PLACEMENT_TRIES
	while(sanity > 0)
		sanity--
		var/width_border = TRANSITIONEDGE + SPACERUIN_MAP_EDGE_PAD + round(width / 2)
		var/height_border = TRANSITIONEDGE + SPACERUIN_MAP_EDGE_PAD + round(height / 2)
		var/turf/central_turf = locate(rand(width_border, world.maxx - width_border), rand(height_border, world.maxy - height_border), z)
		var/valid = TRUE

		for(var/turf/check in get_affected_turfs(central_turf,1))
			var/area/new_area = get_area(check)
			if(!(istype(new_area, allowed_areas)) || check.flags_1 & NO_RUINS_1)
				valid = FALSE
				break

		if(!valid)
			CHECK_TICK
			continue

		testing("Ruin \"[name]\" placed at ([central_turf.x], [central_turf.y], [central_turf.z])")

		for(var/i in get_affected_turfs(central_turf, 1))
			var/turf/T = i
			for(var/mob/living/simple_animal/monster in T)
				qdel(monster)
			for(var/obj/structure/flora/ash/plant in T)
				qdel(plant)

		var/list/places = load(central_turf,centered = TRUE)
		var/list/turfs = block(	locate(places[MAP_MINX], places[MAP_MINY], places[MAP_MINZ]),
							locate(places[MAP_MAXX], places[MAP_MAXY], places[MAP_MAXZ]))

		loaded++

		var/located_port

		for(var/turf/T in get_affected_turfs(central_turf, 1))
			T.flags_1 |= NO_RUINS_1

		for(var/turf/T in turfs)
			//Locate the shuttle dock
			for(var/obj/docking_port/mobile/port in T)
				port.id = "[port.id][shuttles_spawned++]"
				located_port = port
				message_admins("Located docking port :)")
		message_admins("Spawned [name]")
		return located_port
	return null
