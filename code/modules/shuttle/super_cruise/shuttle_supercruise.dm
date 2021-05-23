/obj/docking_port/mobile/proc/enter_supercruise()
	//Must be idle to supercruise.
	if(mode != SHUTTLE_IDLE)
		return
	//Inherit orbital velocity of the place we are leaving
	var/datum/space_level/z_level = SSmapping.get_level(z)
	if(!z_level || !z_level.orbital_body)
		//Cannot enter supercruise from this place
		return
	//Start moving
	destination = null
	mode = SHUTTLE_IGNITING
	setTimer(ignitionTime)
	//Enter the orbital system
	var/datum/orbital_object/shuttle/our_orbital_body = new()
	//Linkup
	our_orbital_body.link_shuttle(src)
	our_orbital_body.velocity = new(z_level.orbital_body.velocity.x, z_level.orbital_body.velocity.y)
	our_orbital_body.position = new(z_level.orbital_body.position.x + our_orbital_body.velocity.x, z_level.orbital_body.position.y + our_orbital_body.velocity.y)
	return our_orbital_body
