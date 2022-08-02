/obj/docking_port/mobile/proc/enter_supercruise(datum/orbital_vector/spawn_position_param = null)
	//Must be idle to supercruise.
	if(mode != SHUTTLE_IDLE)
		return
	//Inherit orbital velocity of the place we are leaving
	var/datum/space_level/z_level = SSmapping.get_level(z)
	var/datum/orbital_vector/spawn_position = new()
	var/datum/orbital_vector/spawn_velocity = new()
	if(!spawn_position_param)
		if((!z_level || !z_level.orbital_body))
			message_admins("Error: Shuttle is entering supercruise from a bad location. Shuttle: [name]")
			log_runtime("Error: Shuttle is entering supercruise from a bad location. Shuttle: [name]")
			var/datum/orbital_map/default_map = SSorbits.orbital_maps[PRIMARY_ORBITAL_MAP]
			spawn_position.Set(default_map.center.position.GetX(), default_map.center.position.GetY())
		else
			spawn_position.Set(z_level.orbital_body.position.GetX() + z_level.orbital_body.velocity.GetX(), z_level.orbital_body.position.GetY() + z_level.orbital_body.velocity.GetY())
			spawn_velocity.Set(z_level.orbital_body.velocity.GetX(), z_level.orbital_body.velocity.GetY())
	else
		spawn_position.Set(spawn_position_param.GetX(), spawn_position_param.GetY())
	//Start moving
	destination = null
	mode = SHUTTLE_IGNITING
	setTimer(ignitionTime)
	//Enter the orbital system
	var/datum/orbital_object/shuttle/our_orbital_body = new shuttle_object_type(
		spawn_position,
		spawn_velocity,
		PRIMARY_ORBITAL_MAP,
		src
	)
	return our_orbital_body
