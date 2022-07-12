/datum/map_template/shuttle/supercruise
	prefix = "_maps/shuttles/supercruise/encounters"
	var/list/valid_factions

///Place put returns the port
/datum/map_template/shuttle/supercruise/proc/place_port(turf/T, centered, register=TRUE)
	var/list/coords = load(T, centered, register)
	if(!coords)
		return
	var/list/turfs = block(	locate(.[MAP_MINX], .[MAP_MINY], .[MAP_MINZ]),
							locate(.[MAP_MAXX], .[MAP_MAXY], .[MAP_MAXZ]))
	for(var/i in 1 to turfs.len)
		var/turf/place = turfs[i]
		if(istype(place, /turf/open/space)) // This assumes all shuttles are loaded in a single spot then moved to their real destination.
			continue
		var/obj/docking_port/mobile/port = locate() in place
		if(port)
			. = port
			port.enter_supercruise()
			break
