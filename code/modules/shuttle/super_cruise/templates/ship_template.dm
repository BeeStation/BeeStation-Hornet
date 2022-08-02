/datum/map_template/shuttle/supercruise
	prefix = "_maps/shuttles/supercruise/"
	port_id = "encounter"
	//A list of types that this ship can belong to
	var/list/valid_factions
	//Weight of this map
	var/weight = 0

///Place put returns the port
/datum/map_template/shuttle/supercruise/proc/place_port(turf/T, centered, register=TRUE, positionX, positionY)
	var/list/coords = load(T, centered, register)
	if(!coords)
		return
	var/list/turfs = block(	locate(coords[MAP_MINX], coords[MAP_MINY], coords[MAP_MINZ]),
							locate(coords[MAP_MAXX], coords[MAP_MAXY], coords[MAP_MAXZ]))
	for(var/i in 1 to turfs.len)
		var/turf/place = turfs[i]
		if(istype(place, /turf/open/space)) // This assumes all shuttles are loaded in a single spot then moved to their real destination.
			continue
		var/obj/docking_port/mobile/port = locate() in place
		if(port)
			. = port
			port.enter_supercruise(new /datum/orbital_vector(positionX, positionY))
			break
