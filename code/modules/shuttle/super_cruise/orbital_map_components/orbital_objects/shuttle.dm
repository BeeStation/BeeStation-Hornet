/datum/orbital_object/shuttle
	name = "Shuttle"
	var/shuttle_port_id
	//Shuttle data
	var/max_thrust = 0.5
	//Controlls
	var/thrust = 0
	var/angle = 0
	//Docking
	var/datum/orbital_object/z_linked/can_dock_with
	var/datum/orbital_object/z_linked/docking_target

//Dont fly into the sun idiot.
/datum/orbital_object/shuttle/explode()
	var/obj/docking_port/mobile/port = SSshuttle.getShuttle(shuttle_port_id)
	if(port)
		port.jumpToNullSpace()
	qdel(src)

/datum/orbital_object/shuttle/process()
	if(docking_target)
		velocity.x = 0
		velocity.y = 0
		position.x = docking_target.position.x
		position.y = docking_target.position.y
		return
	//Do thrust
	var/thrust_amount = thrust * max_thrust / 100
	var/thrust_x = cos(angle) * thrust_amount
	var/thrust_y = sin(angle) * thrust_amount
	accelerate_towards(new /datum/orbital_vector(thrust_x, thrust_y), ORBITAL_UPDATE_RATE_SECONDS)
	//Do gravity and movement
	can_dock_with = null
	. = ..()

/datum/orbital_object/shuttle/proc/link_shuttle(obj/docking_port/mobile/dock)
	name = dock.name
	shuttle_port_id = dock.id
	stealth = dock.hidden

/datum/orbital_object/shuttle/proc/commence_docking(datum/orbital_object/z_linked/docking, forced = FALSE)
	//Check for valid docks on z-level
	if(!docking.forced_docking && !forced)
		can_dock_with = docking
		return
	//Begin docking.
	docking_target = docking
