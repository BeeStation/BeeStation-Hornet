/**
 * The asteroid magnet, grabs nearby orbital objects which will fit into the dock space
 * and then pulls them in.
 * These define the borders of the area that the asteroid magnet can place its captured objects.
 */

GLOBAL_LIST_EMPTY(asteroid_magnet_borders)

/obj/machinery/asteroid_magnet_border_marker
	name = "Asteroid magnet zone marker"
	desc = "A beacon which links to an asteroid magnet super-structure. When 4 of these are placed in a rectangular shape, they define the area in which asteroids will be placed when attracted using the asteroid magnet controller."

/obj/machinery/asteroid_magnet_border_marker/Initialize(mapload)
	. = ..()
	GLOB.asteroid_magnet_borders += src

/obj/machinery/asteroid_magnet_border_marker/Destroy()
	GLOB.asteroid_magnet_borders -= src
	return ..()

/obj/machinery/asteroid_magnet_border_marker/examine(mob/user)
	. = ..()
	. += "Link with a <b>multitool</b> to link the zone to a controller."

/// Locate the markers that we share a line with so that we can define the area which we fill in
/obj/machinery/asteroid_magnet_border_marker/proc/locate_nearest_markers()
	// Locate the markers that are lined up with us
	var/north_marker = null
	var/north_dist = INFINITY
	var/south_marker = null
	var/south_dist = INFINITY
	var/east_marker = null
	var/east_dist = INFINITY
	var/west_marker = null
	var/west_dist = INFINITY
	// Search through all the other magnets to see if they are in the same axis.
	// Not using as() since it is dangerous with hard deletes allowing null to enter the list.
	for (var/obj/machinery/asteroid_magnet_border_marker/marker in GLOB.asteroid_magnet_borders)
		if (marker == src || marker.z != z)
			continue
		var/x_dist = abs(marker.x - x)
		var/y_dist = abs(marker.y - y)
		if (marker.x == x)
			if (marker.y > y)
				// North
				if (y_dist > north_dist)
					continue
				north_dist = y_dist
				north_marker = marker
			else
				// South
				if (y_dist > south_dist)
					continue
				south_dist = y_dist
				south_marker = marker
		else if (marker.y == y)
			if (marker.x > x)
				// West
				if (x_dist > west_dist)
					continue
				west_dist = x_dist
				west_marker = marker
			else
				// East
				if (x_dist > east_dist)
					continue
				east_dist = x_dist
				esat_marker = marker
	. = list()
	if (!isnull(north_marker))
		. += north_marker
	if (!isnull(south_marker))
		. += south_marker
	if (!isnull(east_marker))
		. += east_marker
	if (!isnull(west_marker))
		. += west_marker
