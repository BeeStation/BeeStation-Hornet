/datum/orbital_object/shuttle
	name = "Shuttle"
	var/shuttle_port_id
	//Shuttle data
	var/max_thrust = 0.5
	//Controls
	var/thrust = 0
	var/angle = 0
	//Valid docking locations
	var/list/valid_docks = list()
	//Docking
	var/datum/orbital_object/z_linked/can_dock_with
	var/datum/orbital_object/z_linked/docking_target

	//AUTOPILOT CONTROLS.
	//Is autopilot enabled.
	var/autopilot = FALSE
	//The target, speeds are calulated relative to this.
	var/datum/orbital_object/shuttleTarget

/datum/orbital_object/shuttle/stealth/infiltrator
	max_thrust = 1.5

/datum/orbital_object/shuttle/stealth/steel_rain
	max_thrust = 3

/datum/orbital_object/shuttle/stealth
	stealth = TRUE

/datum/orbital_object/shuttle/Destroy()
	. = ..()
	SSorbits.assoc_shuttles.Remove(shuttle_port_id)

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
	//AUTOPILOT
	handle_autopilot()
	//Do thrust
	var/thrust_amount = thrust * max_thrust / 100
	var/thrust_x = cos(angle) * thrust_amount
	var/thrust_y = sin(angle) * thrust_amount
	accelerate_towards(new /datum/orbital_vector(thrust_x, thrust_y), ORBITAL_UPDATE_RATE_SECONDS)
	//Do gravity and movement
	can_dock_with = null
	. = ..()

/datum/orbital_object/shuttle/proc/handle_autopilot()
	if(!autopilot || docking_target || !shuttleTarget)
		return

	//Relative velocity to target needs to point towards target.
	var/distance_to_target = position.Distance(shuttleTarget.position)
	var/shortest_distance = distance_to_target
	var/datum/orbital_object/object_in_path

	for(var/datum/orbital_object/z_linked/object in SSorbits.orbital_map.bodies)
		//Dont care about non forced docking objects.
		if(!object.forced_docking)
			continue
		//Dont avoid colliding with the thing we want to collide with.
		if(object == shuttleTarget)
			continue
		//Calculate shortest distance and check if we will collide.
		if(object.position.ShortestDistanceToLine(position, velocity) < object.radius)
			//Make sure we are closer to our target than this object, otherwise the colliding object is behind the target.
			var/distance_to_object = position.Distance(object.position)
			if(distance_to_object < shortest_distance)
				object_in_path = object
				shortest_distance = distance_to_object

	//If there is an object in the way, we need to fly around it.
	var/datum/orbital_vector/next_position
	if(object_in_path)
		var/datum/orbital_vector/normalized_velocity = new(-object_in_path.velocity.x, -object_in_path.velocity.y)
		normalized_velocity.Normalize()
		normalized_velocity.Scale(object_in_path.radius * 2)
		next_position = new(object_in_path.position.x + normalized_velocity.x, object_in_path.position.y + normalized_velocity.y)
	else
		//Fly in a straight line towards target.
		next_position = shuttleTarget.position

	//Adjust our speed to target to point towards it.
	var/datum/orbital_vector/desired_velocity = new(next_position.x - position.x, next_position.y - position.y)
	var/desired_speed = max(distance_to_target * 0.05, target_orbital_body.velocity.Length() + 0.5)
	desired_velocity.Normalize()
	desired_velocity.Scale(desired_speed)

	//Adjust thrust to make our velocity = desired_velocity
	var/thrust_dir_x = desired_velocity.x - velocity.x
	var/thrust_dir_y = desired_velocity.y - velocity.y

	//message_admins("Thrusting in dir: [thrust_dir_y], [thrust_dir_x]")
	//message_admins("Next pos: [next_position.x], [next_position.y]")

	if(!thrust_dir_x)
		if(!thrust_dir_y)
			thrust = 0
			return
		angle = thrust_dir_y > 0 ? 90 : -90
	else
		angle = arctan(thrust_dir_y / thrust_dir_x)
		//Account for ambiguous cases
		if(thrust_dir_x < 0)
			angle = 90 + angle

	//FULL SPEED
	thrust = 100
	//Auto dock
	if(can_dock_with == shuttleTarget)
		commence_docking(shuttleTarget, TRUE)

/datum/orbital_object/shuttle/proc/link_shuttle(obj/docking_port/mobile/dock)
	name = dock.name
	shuttle_port_id = dock.id
	stealth = dock.hidden
	SSorbits.assoc_shuttles[shuttle_port_id] = src

/datum/orbital_object/shuttle/proc/commence_docking(datum/orbital_object/z_linked/docking, forced = FALSE)
	//Check for valid docks on z-level
	if(!docking.forced_docking && !forced)
		can_dock_with = docking
		return
	//Begin docking.
	docking_target = docking
