/obj/docking_port/mobile/proc/enter_supercruise(datum/orbital_vector/spawn_position_param = null)
	//Must be idle to supercruise.
	if(mode != SHUTTLE_IDLE)
		return
	//Inherit orbital velocity of the place we are leaving
	var/datum/space_level/z_level = SSmapping.get_level(z)
	var/datum/orbital_object/orbital_body
	var/datum/orbital_vector/spawn_position = new()
	var/datum/orbital_vector/spawn_velocity = new()
	if(!spawn_position)
		if((!z_level || !z_level.orbital_body))
			message_admins("Error: Shuttle is entering supercruise from a bad location. Shuttle: [name]")
			log_runtime("Error: Shuttle is entering supercruise from a bad location. Shuttle: [name]")
			var/datum/orbital_map/default_map = SSorbits.orbital_maps[PRIMARY_ORBITAL_MAP]
			spawn_position.x = default_map.center.position.x
			spawn_position.y = default_map.center.position.y
		else
			spawn_position.x = z_level.orbital_body.position.x + z_level.orbital_body.velocity.x
			spawn_position.y = z_level.orbital_body.position.y + z_level.orbital_body.velocity.y
			spawn_velocity.x = z_level.orbital_body.velocity.x
			spawn_velocity.y = z_level.orbital_body.velocity.y
	else
		spawn_position.x = spawn_position_param.x
		spawn_position.y = spawn_position_param.y
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
