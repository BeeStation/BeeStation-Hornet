#define SHUTTLE_INTERDICTION_TIME 3 MINUTES

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
	var/force_crash = FALSE

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

	//Time of the world when launch immunity wears off (Cannot lose fuel for 10 seconds afterwards)
	var/immunity_time

	//The timer to stop docking
	var/timer_id

	//Is the shuttle breaking?
	var/breaking = FALSE

/datum/orbital_object/shuttle/New(datum/orbital_vector/position, datum/orbital_vector/velocity, orbital_map_index, obj/docking_port/mobile/port)
	if(port)
		link_shuttle(port)
	//Grant 10 seconds of immunity to running out of fuel
	immunity_time = world.time + 10 SECONDS
	. = ..()

/datum/orbital_object/shuttle/Destroy()
	if(shuttle_data)
		UnregisterSignal(shuttle_data, COMSIG_PARENT_QDELETING)
		//Disable autopilot
		shuttle_data.try_override_pilot()
		//Start processing the AI pilot (Combat mode)
		if(shuttle_data.ai_pilot)
			START_PROCESSING(SSorbits, shuttle_data.ai_pilot)
	port = null
	can_dock_with = null
	docking_target = null
	valid_docks = null
	if(timer_id)
		deltimer(timer_id)
	UnregisterSignal(src, COMSIG_SPACE_LEVEL_GENERATED)
	. = ..()
	SSorbits.assoc_shuttles.Remove(shuttle_port_id)

/datum/orbital_object/shuttle/is_distress()
	return SSorbits.assoc_distress_beacons["[port?.virtual_z]"]

/datum/orbital_object/shuttle/stealth/steel_rain
	//We never miss our mark
	cheating_autopilot = TRUE

/datum/orbital_object/shuttle/aux_base
	cheating_autopilot = TRUE

//Dont fly into the sun idiot.
/datum/orbital_object/shuttle/explode()
	if(port)
		port.jumpToNullSpace()
	qdel(src)

/datum/orbital_object/shuttle/process(delta_time)
	if(check_stuck())
		return

	//Destroyed, awaiting to dock at stranded location
	if (!shuttle_data)
		velocity.Set(0, 0)
		strand_shuttle()
		return

	//Process AI action
	if(shuttle_data.ai_pilot)
		shuttle_data.ai_pilot.handle_ai_flight_action(src)

	if(!QDELETED(docking_target))
		velocity.Set(0, 0)
		MOVE_ORBITAL_BODY(src, docking_target.position.GetX(), docking_target.position.GetY())
		//Disable autopilot and thrust while docking to prevent fuel usage.
		thrust = 0
		angle = 0
		//Redisable collisions so if we undock, we aren't flung by gravity
		collision_ignored = TRUE
		return
	else
		//If our docking target was deleted, null it to prevent docking interface etc.
		docking_target = null
	//I hate that I have to do this, but people keep flying them away.
	if(position.GetX() > 20000 || position.GetX() < -20000 || position.GetY() > 20000 || position.GetY() < -20000)
		SEND_SIGNAL(src, COMSIG_ORBITAL_BODY_MESSAGE, "Local bluespace anomaly detected, shuttle has been transported to a new location.")
		MOVE_ORBITAL_BODY(src, rand(-2000, 2000), rand(-2000, 2000))
		velocity.Set(0, 0)
		thrust = 0
	//Handle breaking
	if(breaking)
		//Reduce velocity
		velocity.ScaleSelf(0.8)
		//Disable thrust
		thrust = 0
		var/angle = velocity.AngleFrom(new /datum/orbital_vector(0, 0))
		//Throw shuttle mobs
		for(var/mob/living/L in GLOB.mob_living_list)
			if(get_area(L) in port.shuttle_areas)
				var/turf/target = get_edge_target_turf(L, angle2dir(-angle))
				L.throw_at(target, 3, 5, force = MOVE_FORCE_EXTREMELY_STRONG)
		//Stop breaking
		if(velocity.Length() < 20)
			breaking = FALSE
		return
	//Process shuttle fuel consumption
	if(shuttle_data && !cheating_autopilot)
		shuttle_data.process_flight(thrust, delta_time)
		if(shuttle_data.is_stranded())
			if(world.time > immunity_time)
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
	SEND_SIGNAL(src, COMSIG_ORBITAL_BODY_MESSAGE, "Shuttle can no longer sustain supercruise flight mode, please check your engines for correct setup and fuel reserves.")
	if(!docking_target)
		//Dock with the current location
		if(can_dock_with)
			commence_docking(can_dock_with, TRUE, FALSE, TRUE)
			message_admins("Shuttle [shuttle_port_id] is dropping to a random location at [can_dock_with.name] due to running out of fuel/incorrect engine configuration. (EXPLOSION INCOMMING!!)")
		//Create a new orbital waypoint to drop at
		else
			var/datum/orbital_object/z_linked/beacon/stranded_shuttle/shuttle_location = new(new /datum/orbital_vector(position.GetX(), position.GetY()))
			shuttle_location.name = "Stranded [name]"
			commence_docking(shuttle_location, TRUE, TRUE, TRUE)
	//No more custom docking
	docking_frozen = TRUE
	if(!random_drop(docking_target.linked_z_level[1].z_value))
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
	var/datum/orbital_vector/desired_velocity = new(next_position.GetX() - position.GetX(), next_position.GetY() - position.GetY())
	var/desired_speed = distance_to_target * 0.02 + 10
	desired_velocity.NormalizeSelf()
	desired_velocity.ScaleSelf(desired_speed)

	//Adjust thrust to make our velocity = desired_velocity
	var/thrust_dir_x = desired_velocity.GetX() - velocity.GetX()
	var/thrust_dir_y = desired_velocity.GetY() - velocity.GetY()

	desired_vel_x = desired_velocity.GetX()
	desired_vel_y = desired_velocity.GetY()

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

	thrust = CLAMP((desired_vel_x - velocity.GetX()) / (ORBITAL_UPDATE_RATE_SECONDS * cos(angle) * (shuttle_data.get_thrust_force() / 100)), 0, 100)

	//Fuck all that, we cheat anyway
	if(cheating_autopilot)
		velocity.Set(desired_vel_x, desired_vel_y)

///Public
///Link this abstract shuttle datum to a physical mobile dock.
///Parameters:
/// - dock: The docking port that this shuttle object is linked to
/datum/orbital_object/shuttle/proc/link_shuttle(obj/docking_port/mobile/dock)
	name = dock.name
	shuttle_port_id = dock.id
	port = dock
	SSorbits.assoc_shuttles[shuttle_port_id] = src
	shuttle_data = SSorbits.get_shuttle_data(dock.id)
	if (dock.hidden)
		shuttle_data.stealth = TRUE
	RegisterSignal(shuttle_data, COMSIG_PARENT_QDELETING, PROC_REF(handle_shuttle_data_deletion))
	//Stop processin the AI pilot (Flight mode)
	if(shuttle_data.ai_pilot)
		STOP_PROCESSING(SSorbits, shuttle_data.ai_pilot)

/datum/orbital_object/shuttle/proc/handle_shuttle_data_deletion(datum/source, force)
	UnregisterSignal(shuttle_data, COMSIG_PARENT_QDELETING)
	strand_shuttle()
	shuttle_data = null

///Perform an interdiction
/datum/orbital_object/shuttle/proc/perform_interdiction()
	if(docking_target || can_dock_with)
		SEND_SIGNAL(src, COMSIG_ORBITAL_BODY_MESSAGE, "Cannot use interdictor while docking.")
		return FALSE
	if(is_stealth())
		SEND_SIGNAL(src, COMSIG_ORBITAL_BODY_MESSAGE, "Cannot use interdictor on stealthed shuttles.")
		return FALSE
	var/list/interdicted_shuttles = list()
	for(var/shuttleportid in SSorbits.assoc_shuttles)
		var/datum/orbital_object/shuttle/other_shuttle = SSorbits.assoc_shuttles[shuttleportid]
		//Do this last
		if(other_shuttle == src)
			continue
		if(other_shuttle?.position?.DistanceTo(position) <= shuttle_data.interdiction_range && !other_shuttle.is_stealth())
			interdicted_shuttles += other_shuttle
	if(!length(interdicted_shuttles))
		SEND_SIGNAL(src, COMSIG_ORBITAL_BODY_MESSAGE, "No targets to interdict in range.")
		return FALSE
	SEND_SIGNAL(src, COMSIG_ORBITAL_BODY_MESSAGE, "Interdictor activated, shuttle throttling down...")
	//Create the site of interdiction
	var/datum/orbital_object/z_linked/beacon/z_linked = new /datum/orbital_object/z_linked/beacon/interdiction(
		new /datum/orbital_vector(position.GetX(), position.GetY())
	)
	z_linked.name = "Interdiction Site"
	//Lets tell everyone about it
	priority_announce("Supercruise interdiction detected, interdicted shuttles have been registered onto local GPS units. Source: [name]")
	//Get all shuttle objects in range
	for(var/datum/orbital_object/shuttle/other_shuttle in interdicted_shuttles)
		other_shuttle.commence_docking(z_linked, TRUE, FALSE, TRUE)
		other_shuttle.random_drop(z_linked.linked_z_level[1].z_value)
		SSorbits.interdicted_shuttles[other_shuttle.shuttle_port_id] = world.time + SHUTTLE_INTERDICTION_TIME
	commence_docking(z_linked, TRUE, FALSE, TRUE)
	random_drop(z_linked.linked_z_level[1].z_value)
	SSorbits.interdicted_shuttles[shuttle_port_id] = world.time + SHUTTLE_INTERDICTION_TIME
	return TRUE

/datum/orbital_object/shuttle/get_locator_name()
	return "([shuttle_data.faction.faction_tag]) Shuttle #[unique_id]"

/datum/orbital_object/shuttle/is_stealth()
	if (!shuttle_data)
		return FALSE
	return shuttle_data.stealth

/datum/orbital_object/shuttle/get_name()
	return "([shuttle_data.faction.faction_tag]) [shuttle_data.shuttle_name]"
