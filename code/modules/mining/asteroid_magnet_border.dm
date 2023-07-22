/**
 * The asteroid magnet, grabs nearby orbital objects which will fit into the dock space
 * and then pulls them in.
 * These define the borders of the area that the asteroid magnet can place its captured objects.
 */

GLOBAL_LIST_EMPTY(asteroid_magnet_borders)

/obj/machinery/asteroid_magnet_border_marker
	name = "asteroid magnet zone marker"
	desc = "A beacon which links to an asteroid magnet super-structure. When 4 of these are placed in a rectangular shape, they define the area in which asteroids will be placed when attracted using the asteroid magnet controller."
	icon = 'icons/obj/machines/field_generator.dmi'
	icon_state = "Field_Gen"
	// The zone that we have created
	var/datum/asteroid_magnet_zone/linked_zone

/obj/machinery/asteroid_magnet_border_marker/Initialize(mapload)
	. = ..()
	GLOB.asteroid_magnet_borders += src

/obj/machinery/asteroid_magnet_border_marker/ComponentInitialize()
	. = ..()
	RegisterSignal(src, COMSIG_PARENT_RECIEVE_BUFFER, PROC_REF(handle_buffer_action))

/obj/machinery/asteroid_magnet_border_marker/Destroy()
	GLOB.asteroid_magnet_borders -= src
	// Delete the linked zone
	if (linked_zone)
		qdel(linked_zone)
	return ..()

/obj/machinery/asteroid_magnet_border_marker/Moved(atom/OldLoc, Dir)
	. = ..()
	// Delete the linked zone
	if (linked_zone)
		qdel(linked_zone)

/obj/machinery/asteroid_magnet_border_marker/examine(mob/user)
	. = ..()
	. += "Link with a <b>multitool</b> to link the zone to a controller."

/obj/machinery/asteroid_magnet_border_marker/proc/handle_buffer_action(datum/source, mob/user, datum/buffer, obj/item/buffer_parent)
	// Attempt to build our asteroid magnet border area
	if (!linked_zone)
		// Try to build the area
		try_build_area()
		if (!linked_zone)
			to_chat(user, "<span class='warning'>\The [src] does not form a complete rectangular zone. Markers need to be placed in all 4 corners to form a zone.</span>")
			return NONE
	if (istype(buffer, /obj/machinery/computer/asteroid_magnet_controller))
		var/obj/machinery/computer/asteroid_magnet_controller/border_controller = buffer
		border_controller.linked_zone = linked_zone
		to_chat(user, "<span class='notice'>You successfully link [border_controller] into to the asteroid magnet zone.</span>")
		return COMPONENT_BUFFER_RECIEVED
	else if (TRY_STORE_IN_BUFFER(buffer_parent, src))
		to_chat(user, "<span class='notice'>You successfully store [src] into [buffer_parent]'s buffer.</span>")
		return COMPONENT_BUFFER_RECIEVED

/obj/machinery/asteroid_magnet_border_marker/proc/show_area()
	if (!linked_zone)
		return
	var/turf/bl = locate(linked_zone.minx - 1, linked_zone.miny - 1, z)
	var/turf/tl = locate(linked_zone.minx - 1, linked_zone.maxy + 1, z)
	var/turf/br = locate(linked_zone.maxx + 1, linked_zone.miny - 1, z)
	var/turf/tr = locate(linked_zone.maxx + 1, linked_zone.maxy + 1, z)
	bl.Beam(tl)
	bl.Beam(br)
	tl.Beam(tr)
	br.Beam(tr)

/// Attempts to build an area from this beacon and adjacent beacons, will return null if no area can be made.
/// If multiple areas can be made, the area that gets chosen to be generated is undefined
/obj/machinery/asteroid_magnet_border_marker/proc/try_build_area()
	var/list/adjacent_markers = locate_nearest_markers()
	// Determine if they are north or south
	var/list/vertical_markers = list()
	var/list/horizontal_markers = list()
	for (var/obj/machinery/asteroid_magnet_border_marker/marker as() in adjacent_markers)
		if (marker.x == x)
			vertical_markers += marker
		else if (marker.y == y)
			horizontal_markers += marker
	// Check if we can build squares and generate areas
	for (var/obj/machinery/asteroid_magnet_border_marker/vertical_marker as() in vertical_markers)
		for (var/obj/machinery/asteroid_magnet_border_marker/horizontal_marker as() in horizontal_markers)
			// Alright, we have 2 adjacent points, check if we can fill in the corner with a final beacon
			var/final_beacon_x = horizontal_marker.x
			var/final_beacon_y = vertical_marker.y
			var/obj/machinery/asteroid_magnet_border_marker/final_marker = locate() in locate(final_beacon_x, final_beacon_y, z)
			// Unable to complete the rectangular zone
			if (!final_marker)
				continue
			// Complete the rectangular zone
			return new /datum/asteroid_magnet_zone(src, vertical_marker, horizontal_marker, final_marker)
	return null

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
				east_marker = marker
	. = list()
	if (!isnull(north_marker))
		. += north_marker
	if (!isnull(south_marker))
		. += south_marker
	if (!isnull(east_marker))
		. += east_marker
	if (!isnull(west_marker))
		. += west_marker

/datum/asteroid_magnet_zone
	var/list/markers = list()
	var/minx
	var/maxx
	var/miny
	var/maxy
	var/z

/datum/asteroid_magnet_zone/New(obj/machinery/asteroid_magnet_border_marker/marker1, obj/machinery/asteroid_magnet_border_marker/marker2, obj/machinery/asteroid_magnet_border_marker/marker3, obj/machinery/asteroid_magnet_border_marker/marker4)
	. = ..()
	minx = min(min(min(marker1.x, marker2.x), marker3.x), marker4.x)
	miny = min(min(min(marker1.y, marker2.y), marker3.y), marker4.y)
	maxx = max(max(max(marker1.x, marker2.x), marker3.x), marker4.x)
	maxy = max(max(max(marker1.y, marker2.y), marker3.y), marker4.y)
	z = marker1.z
	// Error checking
	if ((marker1.x != minx && marker1.x != maxx) || (marker1.y != miny && marker1.y != maxy))
		CRASH("Asteroid magnet zone created with a non-rectangular size. Issue with marker 1")
	if ((marker2.x != minx && marker2.x != maxx) || (marker2.y != miny && marker2.y != maxy))
		CRASH("Asteroid magnet zone created with a non-rectangular size. Issue with marker 2")
	if ((marker3.x != minx && marker3.x != maxx) || (marker3.y != miny && marker3.y != maxy))
		CRASH("Asteroid magnet zone created with a non-rectangular size. Issue with marker 3")
	if ((marker4.x != minx && marker4.x != maxx) || (marker4.y != miny && marker4.y != maxy))
		CRASH("Asteroid magnet zone created with a non-rectangular size. Issue with marker 4")
	// Non-inclusive
	minx ++
	miny ++
	maxx --
	maxy --
	// Overwrite previous linked zones, or we bug out
	if (marker1.linked_zone)
		qdel(marker1.linked_zone)
	if (marker2.linked_zone)
		qdel(marker2.linked_zone)
	if (marker3.linked_zone)
		qdel(marker3.linked_zone)
	if (marker4.linked_zone)
		qdel(marker4.linked_zone)
	// Set the linked zone and display the zone
	marker1.linked_zone = src
	marker2.linked_zone = src
	marker3.linked_zone = src
	marker4.linked_zone = src
	marker1.show_area()

/datum/asteroid_magnet_zone/Destroy(force, ...)
	. = ..()
	for (var/obj/machinery/asteroid_magnet_border_marker/marker in markers)
		marker.linked_zone = null
	markers = null
