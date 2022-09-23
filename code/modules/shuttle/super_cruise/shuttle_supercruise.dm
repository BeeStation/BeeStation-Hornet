/obj/docking_port/mobile/proc/enter_supercruise(datum/orbital_vector/spawn_position_param = null)
	//Must be idle to supercruise.
	if(mode != SHUTTLE_IDLE)
		return
	//Inherit orbital velocity of the place we are leaving
	var/datum/orbital_vector/spawn_position = new()
	var/datum/orbital_vector/spawn_velocity = new()
	var/datum/orbital_object/orbital_body = SSorbits.assoc_z_levels["[get_virtual_z_level()]"]
	if(!orbital_body)
		message_admins("Error: Shuttle is entering supercruise from a bad location. Shuttle: [name]")
		log_runtime("Error: Shuttle is entering supercruise from a bad location. Shuttle: [name]")
		var/datum/orbital_map/default_map = SSorbits.orbital_maps[PRIMARY_ORBITAL_MAP]
		orbital_body = default_map.center
	spawn_position.Set(orbital_body.position.GetX() + orbital_body.velocity.GetX(), orbital_body.position.GetY() + orbital_body.velocity.GetY())
	spawn_velocity.Set(orbital_body.velocity.GetX(), orbital_body.velocity.GetY())
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
