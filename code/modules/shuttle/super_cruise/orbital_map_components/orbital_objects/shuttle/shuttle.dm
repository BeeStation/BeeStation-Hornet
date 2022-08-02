/datum/orbital_object/shuttle
	name = "Shuttle"
	collision_type = COLLISION_SHUTTLES
	//Collision is handled by z-linked.
	collision_flags = NONE
	render_mode = RENDER_MODE_SHUTTLE
	priority = 10
	var/shuttle_port_id
	//Shuttle data
	var/datum/shuttle_data/shuttle_data
	//Controls
	var/thrust = 0
	var/angle = 0
	//Valid docking locations
	var/list/valid_docks = list()

	//Crashing
	var/is_crashing = FALSE
	/// World time since crashing started
	var/crash_time

	//Once we start docking, we can't release
	var/is_docking = FALSE

	//Docking
	var/docking_frozen = FALSE
	var/datum/orbital_object/z_linked/can_dock_with
	var/datum/orbital_object/z_linked/docking_target

	var/desired_vel_x = 0
	var/desired_vel_y = 0

	//They go faster
	velocity_multiplier = 3

	var/obj/docking_port/mobile/port

	//Semi-Autopilot controls
	var/datum/orbital_vector/shuttleTargetPos

	//AUTOPILOT CONTROLS.
	//Cheating autopilots never fail
	var/cheating_autopilot = FALSE

	//The timer to stop docking
	var/timer_id

/datum/orbital_object/shuttle/New(datum/orbital_vector/position, datum/orbital_vector/velocity, orbital_map_index, obj/docking_port/mobile/port)
	if(port)
		link_shuttle(port)
	//Stop processin the AI pilot (Flight mode)
	STOP_PROCESSING(SSorbits, shuttle_data.ai_pilot)
	. = ..()

/datum/orbital_object/shuttle/Destroy()
	if(shuttle_data)
		UnregisterSignal(shuttle_data, COMSIG_PARENT_QDELETING)
	//Start processing the AI pilot (Combat mode)
	if(shuttle_data)
		START_PROCESSING(SSorbits, shuttle_data.ai_pilot)
	. = ..()

/datum/orbital_object/shuttle/is_distress()
	return SSorbits.assoc_distress_beacons["[port?.virtual_z]"]

/datum/orbital_object/shuttle/stealth
	stealth = TRUE

/datum/orbital_object/shuttle/stealth/infiltrator

/datum/orbital_object/shuttle/stealth/steel_rain
	//We never miss our mark
	cheating_autopilot = TRUE

/datum/orbital_object/shuttle/aux_base
	cheating_autopilot = TRUE

/datum/orbital_object/shuttle/Destroy()
	port = null
	can_dock_with = null
	docking_target = null
	valid_docks = null
	if(timer_id)
		deltimer(timer_id)
	UnregisterSignal(src, COMSIG_SPACE_LEVEL_GENERATED)
	. = ..()
	SSorbits.assoc_shuttles.Remove(shuttle_port_id)

//Dont fly into the sun idiot.
/datum/orbital_object/shuttle/explode()
	if(port)
		port.jumpToNullSpace()
	qdel(src)

/datum/orbital_object/shuttle/process()
	if(check_stuck())
		return

	//Process AI action
	if(shuttle_data.ai_pilot)
		shuttle_data.ai_pilot.handle_ai_flight_action(src)

	if(!QDELETED(docking_target))
		velocity.x = 0
		velocity.y = 0
		MOVE_ORBITAL_BODY(src, docking_target.position.x, docking_target.position.y)
		//Disable autopilot and thrust while docking to prevent fuel usage.
		thrust = 0
		angle = 0
		return
	else
		//If our docking target was deleted, null it to prevent docking interface etc.
		docking_target = null
	//I hate that I have to do this, but people keep flying them away.
	if(position.x > 20000 || position.x < -20000 || position.y > 20000 || position.y < -20000)
		SEND_SIGNAL(src, COMSIG_ORBITAL_BODY_MESSAGE, "Local bluespace anomaly detected, shuttle has been transported to a new location.")
		MOVE_ORBITAL_BODY(src, rand(-2000, 2000), rand(-2000, 2000))
		velocity.x = 0
		velocity.y = 0
		thrust = 0
	//Process shuttle fuel consumption
	if(shuttle_data && !cheating_autopilot)
		shuttle_data.process_flight(thrust)
		if(shuttle_data.is_stranded())
			strand_shuttle()
			return
	//AUTOPILOT
	handle_autopilot()
	//Do thrust
	var/thrust_amount = thrust * shuttle_data.get_thrust_force() / 100
	var/thrust_x = cos(angle) * thrust_amount
	var/thrust_y = sin(angle) * thrust_amount
	accelerate_towards(new /datum/orbital_vector(thrust_x, thrust_y), ORBITAL_UPDATE_RATE_SECONDS)
	//Do gravity and movement
	can_dock_with = null
	. = ..()

/datum/orbital_object/shuttle/proc/strand_shuttle()
	PRIVATE_PROC(TRUE)
	SEND_SIGNAL(src, COMSIG_ORBITAL_BODY_MESSAGE, "Shuttle can no longer sustain supercruise flight mode, please check your engines for correct setup and fuel reserves.")
	var/explosive_landing = FALSE
	if(!docking_target)
		//Dock with the current location
		if(can_dock_with)
			commence_docking(can_dock_with, TRUE, FALSE, TRUE)
			message_admins("Shuttle [shuttle_port_id] is dropping to a random location at [can_dock_with.name] due to running out of fuel/incorrect engine configuration. (EXPLOSION INCOMMING!!)")
			explosive_landing = TRUE
		//Create a new orbital waypoint to drop at
		else
			var/datum/orbital_object/z_linked/beacon/ruin/stranded_shuttle/shuttle_location = new(new /datum/orbital_vector(position.x, position.y))
			shuttle_location.name = "Stranded [name]"
			commence_docking(shuttle_location, TRUE, FALSE, TRUE)
	//No more custom docking
	docking_frozen = TRUE
	if(!random_drop(docking_target.linked_z_level[1].z_value, explosive_landing))
		SEND_SIGNAL(src, COMSIG_ORBITAL_BODY_MESSAGE,
			"Shuttle failed to dock at a random location.")
		message_admins("Shuttle [shuttle_port_id] failed to drop at a random location as a result of running out of fuel/incorrect engine configuration.")
	docking_frozen = FALSE

/datum/orbital_object/shuttle/proc/check_stuck()
	if(!port)
		return FALSE
	if(!is_reserved_level(port.z) && port.mode == SHUTTLE_IDLE)
		message_admins("Shuttle [shuttle_port_id] is not on a reserved Z-Level but is somehow registered as in flight! Automatically fixing...")
		log_runtime("Shuttle [shuttle_port_id] is not on a reserved Z-Level but is somehow registered as in flight! Removing shuttle object.")
		qdel(src)
		return TRUE
	return FALSE

/datum/orbital_object/shuttle/proc/handle_autopilot()
	if(docking_target || !shuttleTargetPos)
		return

	//Relative velocity to target needs to point towards target.
	var/distance_to_target = position.DistanceTo(shuttleTargetPos)

	//Cheat and slow down.
	//Remove this if you make better autopilot logic ever.
	if(distance_to_target < 100 && velocity.Length() > 25)
		velocity.NormalizeSelf()
		velocity.ScaleSelf(20)

	//If there is an object in the way, we need to fly around it.
	var/datum/orbital_vector/next_position = shuttleTargetPos

	//Adjust our speed to target to point towards it.
	var/datum/orbital_vector/desired_velocity = new(next_position.x - position.x, next_position.y - position.y)
	var/desired_speed = distance_to_target * 0.02 + 10
	desired_velocity.NormalizeSelf()
	desired_velocity.ScaleSelf(desired_speed)

	//Adjust thrust to make our velocity = desired_velocity
	var/thrust_dir_x = desired_velocity.x - velocity.x
	var/thrust_dir_y = desired_velocity.y - velocity.y

	desired_vel_x = desired_velocity.x
	desired_vel_y = desired_velocity.y

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
			if(thrust_dir_y > 0)
				angle = -180 + angle
			else
				angle = 180 + angle

	//FULL SPEED
	thrust = 100

	//Fuck all that, we cheat anyway
	if(cheating_autopilot)
		velocity.x = desired_vel_x
		velocity.y = desired_vel_y

///Public
///Link this abstract shuttle datum to a physical mobile dock.
///Parameters:
/// - dock: The docking port that this shuttle object is linked to
/datum/orbital_object/shuttle/proc/link_shuttle(obj/docking_port/mobile/dock)
	name = dock.name
	shuttle_port_id = dock.id
	port = dock
	stealth = dock.hidden
	SSorbits.assoc_shuttles[shuttle_port_id] = src
	shuttle_data = SSorbits.get_shuttle_data(dock.id)
	RegisterSignal(shuttle_data, COMSIG_PARENT_QDELETING, .proc/handle_shuttle_data_deletion)

/datum/orbital_object/shuttle/proc/handle_shuttle_data_deletion(datum/source, force)
	UnregisterSignal(shuttle_data, COMSIG_PARENT_QDELETING)
	shuttle_data = null
