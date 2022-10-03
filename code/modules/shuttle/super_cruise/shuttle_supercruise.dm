/obj/docking_port/mobile/proc/enter_supercruise()
	//Must be idle to supercruise.
	if(mode != SHUTTLE_IDLE)
		return
	//Inherit orbital velocity of the place we are leaving
	var/datum/orbital_object/orbital_body = SSorbits.assoc_z_levels["[get_virtual_z_level()]"]
	if(!orbital_body)
		message_admins("Error: Shuttle is entering supercruise from a bad location. Shuttle: [name]")
		log_runtime("Error: Shuttle is entering supercruise from a bad location. Shuttle: [name]")
		var/datum/orbital_map/default_map = SSorbits.orbital_maps[PRIMARY_ORBITAL_MAP]
		orbital_body = default_map.center
	//Start moving
	destination = null
	mode = SHUTTLE_IGNITING
	setTimer(ignitionTime)
	//Enter the orbital system
	var/datum/orbital_object/shuttle/our_orbital_body = new shuttle_object_type(
		new /datum/orbital_vector(orbital_body.position.x + orbital_body.velocity.x, orbital_body.position.y + orbital_body.velocity.y),
		new /datum/orbital_vector(orbital_body.velocity.x, orbital_body.velocity.y)
	)
	//Linkup
	our_orbital_body.link_shuttle(src)
	return our_orbital_body
