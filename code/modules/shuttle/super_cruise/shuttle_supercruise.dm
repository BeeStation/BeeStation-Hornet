/obj/docking_port/mobile/proc/enter_supercruise()
	//Must be idle to supercruise.
	if(mode != SHUTTLE_IDLE)
		return
	//Inherit orbital velocity of the place we are leaving
	var/datum/space_level/z_level = SSmapping.get_level(z)
	var/datum/orbital_object/orbital_body
	if(!z_level || !z_level.orbital_body)
		message_admins("Error: Shuttle is entering supercruise from a bad location. Shuttle: [name]")
		log_runtime("Error: Shuttle is entering supercruise from a bad location. Shuttle: [name]")
		orbital_body = SSorbits.orbital_map.center
	else
		orbital_body = z_level.orbital_body
	//Start moving
	destination = null
	mode = SHUTTLE_IGNITING
	setTimer(ignitionTime)
	//Enter the orbital system
	var/datum/orbital_object/shuttle/our_orbital_body = new shuttle_object_type()
	//Linkup
	our_orbital_body.link_shuttle(src)
	our_orbital_body.velocity = new(orbital_body.velocity.x, orbital_body.velocity.y)
	our_orbital_body.position = new(orbital_body.position.x + our_orbital_body.velocity.x, orbital_body.position.y + our_orbital_body.velocity.y)
	return our_orbital_body
