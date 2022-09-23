/atom/proc/get_orbital_loc()
	var/turf/current_turf = get_turf(src)
	if (is_reserved_level(current_turf.z))
		//Handle shuttle grabbing
		var/area/shuttle/shuttle_area = get_area(current_turf)
		if(!istype(shuttle_area))
			return null
		return SSorbits.assoc_shuttles[shuttle_area.mobile_port.id]
	else
		return SSorbits.assoc_z_levels["[current_turf.z]"]

/atom/proc/get_orbital_distance(atom/target)
	if (get_virtual_z_level() == target.get_virtual_z_level())
		return get_dist(src, target)
	var/datum/orbital_object/our_object = get_orbital_loc()
	var/datum/orbital_object/their_object = target.get_orbital_loc()
	if(!our_object || !their_object)
		return INFINITY
	return our_object.position.DistanceTo(their_object.position)

/atom/proc/get_minimal_orbital_distance(target)
	if (islist(target))
		. = INFINITY
		for (var/subtarget in target)
			. = min(., get_orbital_distance(subtarget))
	else
		return get_orbital_distance(target)
