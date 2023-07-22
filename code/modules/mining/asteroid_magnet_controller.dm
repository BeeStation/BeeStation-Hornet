
/obj/machinery/computer/asteroid_magnet_controller
	name = "asteroid magnet controller"
	desc = "A computer which links to and controls an asteroid magnet setup, allowing for asteroids in nearby space to be pulled in."

	/// The zone that we are currently linked to
	var/datum/asteroid_magnet_zone/linked_zone
	/// The range of the asteroid magnet in orbital units
	var/range = 500

/obj/machinery/computer/asteroid_magnet_controller/ComponentInitialize()
	. = ..()
	RegisterSignal(src, COMSIG_PARENT_RECIEVE_BUFFER, PROC_REF(handle_buffer_action))

/obj/machinery/computer/asteroid_magnet_controller/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AsteroidMagnet", name)
		ui.set_autoupdate(TRUE)
		ui.open()

/obj/machinery/computer/asteroid_magnet_controller/ui_data(mob/user)
	var/list/data = list()
	data["area_connected"] = !!linked_zone
	data["area_width"] = linked_zone?.maxx - linked_zone?.minx + 1
	data["area_height"] = linked_zone?.maxy - linked_zone?.miny + 1
	data["nearby_objects"] = list()
	// Find our current orbital object to get the map we are working on
	var/turf/location = get_turf(src)
	var/datum/orbital_object/current_object = SSorbits.assoc_z_levels["[location.get_virtual_z_level()]"]
	// Not linked to any orbital object
	if (!current_object)
		return data
	var/datum/orbital_map/current_map = SSorbits.orbital_maps[current_object.orbital_map_index]
	for (var/datum/orbital_object/object in current_map.get_bodies_in_range(current_object, range))
		if (object == current_object || object.static_object)
			continue
		data["nearby_objects"] += list(list(
			"name" = object.name,
			"distance" = current_object.position.DistanceTo(object.position),
		))
	return data

/obj/machinery/computer/asteroid_magnet_controller/ui_act(action, params)
	. = ..()
	if (.)
		return FALSE
	switch (action)
		if ("activate")
			// Assign the z-level to the selected object
			// Check for the things that we can attract
			// Pick on of these things and suck them in
			var/target_body_name = params["target"]
			var/datum/orbital_zone/zone = get_magnet_target(target_body_name)
			if (!zone)
				say("Target out of range or unable to be pulled.")
				return FALSE
			if (is_zone_blocked())
				say("Zone blocked")
				return FALSE
			say("engaging asteroid magnet...")
			pull_asteroid(zone.z, zone.left, zone.right, zone.bottom, zone.top)
			return TRUE
		if ("eject")
			eject_asteroid()
			return TRUE
		if ("scan")
			return TRUE

/obj/machinery/computer/asteroid_magnet_controller/proc/handle_buffer_action(datum/source, mob/user, datum/buffer, obj/item/buffer_parent)
	if (istype(buffer, /obj/machinery/asteroid_magnet_border_marker))
		var/obj/machinery/asteroid_magnet_border_marker/border_marker = buffer
		if (border_marker.linked_zone)
			linked_zone = border_marker.linked_zone
			to_chat(user, "<span class='notice'>You successfully link [src] to the asteroid magnet zone.</span>")
		else
			to_chat(user, "<span class='warning'>The stored border marker doesn't form a rectangular zone.</span>")
		return COMPONENT_BUFFER_RECIEVED
	else if (TRY_STORE_IN_BUFFER(buffer_parent, src))
		to_chat(user, "<span class='notice'>You successfully store [src] into [buffer_parent]'s buffer.</span>")
		return COMPONENT_BUFFER_RECIEVED

/obj/machinery/computer/asteroid_magnet_controller/proc/get_magnet_target(target_name)
	// Find our current orbital object to get the map we are working on
	var/turf/location = get_turf(src)
	var/datum/orbital_object/current_object = SSorbits.assoc_z_levels["[location.get_virtual_z_level()]"]
	// Not linked to any orbital object
	if (!current_object)
		return null
	var/datum/orbital_map/current_map = SSorbits.orbital_maps[current_object.orbital_map_index]
	for (var/datum/orbital_object/object in current_map.get_bodies_in_range(current_object, range))
		if (object == current_object || object.static_object || object.name != target_name)
			continue
		if (!length(object.contained_zones))
			if (istype(object, /datum/orbital_object/z_linked/beacon/ruin))
				var/datum/orbital_object/z_linked/beacon/ruin/ruin_location = object
				ruin_location.assign_z_level()
				if (!length(object.contained_zones))
					continue
		return pick(object.contained_zones)
	return null

/obj/machinery/computer/asteroid_magnet_controller/proc/is_zone_blocked()
	if (!linked_zone)
		return TRUE
	return !!(locate(/turf/closed) in block(locate(linked_zone.minx, linked_zone.miny, linked_zone.z), locate(linked_zone.maxx, linked_zone.maxy, linked_zone.z)))

/// Similar to shuttle move, but very basic as it doens't need to deal with a lot of the same complexities
/obj/machinery/computer/asteroid_magnet_controller/proc/pull_asteroid(source_z, minx, maxx, miny, maxy)
	var/list/moved_areas = list()
	// Changeturfs on the asteroid magnet location to the asteroid turfs, adding baseturfs to mark where the asteroid is
	for (var/turf/T as() in block(locate(minx, miny, source_z), locate(maxx, maxy, source_z)))
		// Ignore space turfs
		if (isspaceturf(T))
			continue
		// Place at the new location
		var/dx = T.x - minx
		var/dy = T.y - miny
		var/turf/new_location = locate(linked_zone.minx + dx, linked_zone.miny + dy, linked_zone.z)
		// Put the skipover and then the asteroid on top of it
		var/list/baseturfs = list(/turf/baseturf_skipover/asteroid)
		for (var/baseturf in T.baseturfs)
			if (ispath(baseturfs, /turf/baseturf_bottom))
				continue
			baseturfs += baseturf
		if (!length(new_location.baseturfs))
			if (new_location.baseturfs)
				new_location.baseturfs = list(new_location.baseturfs)
			else
				new_location.baseturfs = list()
		new_location.baseturfs += new_location.type
		new_location.baseturfs += baseturfs
		T.copyTurf(new_location)
		// TODO: Deal with onShuttleMove
		// Transfer objects from the previous location
		for (var/atom/movable/thing as() in contents)
			thing.onShuttleMove(new_location, T, list(), NORTH, null, null)
		// Remove the turfs from the previous location
		T.TransferComponents(new_location)
		SSexplosions.wipe_turf(T)
		// Since we moved everything, just wipe the entire turf
		T.empty()
	// Deal with telling the areas that they were moved
	// Clear the previous location's orbital location if there is nothing there

/obj/machinery/computer/asteroid_magnet_controller/proc/eject_asteroid()
	if (!linked_zone)
		return
	var/list/asteroid_turfs = list()
	var/eject_mob = FALSE
	// For each turf, eject everything above the baseturf marker.
	// If a player is on the asteroid, place it on a z-level and create a new dynamic z for it.
	// Otherwise, just delete everything there, ignoring indestructible objects
	for (var/turf/T as() in block(locate(linked_zone.minx, linked_zone.miny, linked_zone.z), locate(linked_zone.maxx, linked_zone.maxy, linked_zone.z)))
		if (!(/turf/baseturf_skipover/asteroid in T.baseturfs))
			continue
		asteroid_turfs += T
		// Check if we need to eject mobs
		if (eject_mob)
			continue
		for (var/mob/living/L in T)
			if (!L.move_on_shuttle)
				continue
			if (!L.mind)
				continue
			eject_mob = TRUE
	// Eject the asteroid to space, and send the mobs with it
	if (eject_mob)
		eject_asteroid_to_space(asteroid_turfs)
		return
	// Delete the asteroid
	for (var/turf/T as() in asteroid_turfs)
		var/depth = 1
		while (T.baseturfs.len + 1 - depth > 1 && T.baseturfs[T.baseturfs.len + 1 - depth] != /turf/baseturf_skipover/asteroid)
			depth ++
		// Clear the items and then scrape away the turfs
		// Remove all atoms except observers, landmarks, docking ports
		var/static/list/ignored_atoms = typecacheof(list(/mob/dead, /obj/effect/landmark, /obj/docking_port, /atom/movable/lighting_object))
		var/list/allowed_contents = typecache_filter_list_reverse(T.contents, ignored_atoms)
		allowed_contents -= src
		for(var/i in 1 to allowed_contents.len)
			var/obj/thing = allowed_contents[i]
			// If the thing is indestructible, ignore it.
			if (istype(thing) && (thing.resistance_flags & INDESTRUCTIBLE))
				continue
			qdel(thing, force=TRUE)
		T.ScrapeAway(depth)

/obj/machinery/computer/asteroid_magnet_controller/proc/eject_asteroid_to_space(list/turfs)
	CRASH("Not implemented")
