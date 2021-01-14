/datum/map_template/shuttle/ship
	var/faction = /datum/faction/station

	var/id = null
	var/difficulty = 0

	prefix = "_maps/shuttles/exploration/"

	can_be_bought = FALSE

	var/amount_left = INFINITY

/datum/map_template/shuttle/ship/New()
	if(!islist(faction))
		var/base_faction = faction
		faction = subtypesof(base_faction)
		//If no subtypes, revert to default faction
		if(!LAZYLEN(faction))
			faction = list(base_faction)
	. = ..()

/datum/map_template/shuttle/ship/proc/can_place()
	return amount_left > 0

/datum/map_template/shuttle/ship/proc/try_to_place(z,allowed_areas)
	//To give unique ids to all the spawned ships
	var/static/shuttles_spawned = 0
	var/sanity = PLACEMENT_TRIES
	while(sanity > 0)
		sanity--
		var/width_border = TRANSITIONEDGE + SPACERUIN_MAP_EDGE_PAD + round(width * 0.5)
		var/height_border = TRANSITIONEDGE + SPACERUIN_MAP_EDGE_PAD + round(height * 0.5)
		var/turf/central_turf = locate(rand(width_border, world.maxx - width_border), rand(height_border, world.maxy - height_border), z)
		var/valid = TRUE

		var/list/affected_turfs = get_affected_turfs(central_turf,1)

		for(var/turf/check as() in affected_turfs)
			var/area/new_area = get_area(check)
			if(!(istype(new_area, allowed_areas)) || (check.flags_1 & NO_RUINS_1) || isclosedturf(check))
				valid = FALSE
				break

		if(!valid)
			CHECK_TICK
			continue

		testing("Ruin \"[name]\" placed at ([central_turf.x], [central_turf.y], [central_turf.z])")

		var/list/places = load(central_turf,centered = TRUE)
		var/list/turfs = block(	locate(places[MAP_MINX], places[MAP_MINY], places[MAP_MINZ]),
							locate(places[MAP_MAXX], places[MAP_MAXY], places[MAP_MAXZ]))

		loaded++

		var/located_port

		for(var/turf/T as() in affected_turfs)
			T.flags_1 |= NO_RUINS_1

		for(var/turf/T as() in turfs)
			//Locate the shuttle dock
			var/obj/docking_port/mobile/port = locate() in T
			if(port)
				port.id = "[port.id][shuttles_spawned++]"
				located_port = port
				break
		amount_left --
		return located_port
	return null
