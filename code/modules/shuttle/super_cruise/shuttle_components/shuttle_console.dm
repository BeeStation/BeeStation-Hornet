/obj/machinery/computer/shuttle_flight
	name = "shuttle console"
	desc = "A shuttle control computer."
	icon_screen = "shuttle"
	icon_keyboard = "tech_key"
	light_color = LIGHT_COLOR_CYAN
	req_access = list( )
	var/shuttleId

	//Admin controlled shuttles
	var/admin_controlled = FALSE

	//Autopilot only shuttles
	//These shuttles have a list of possible ports to go to and will fly directly to them.
	var/autopilot_forced = FALSE
	//Is autopilot enabled.
	var/autopilot = FALSE

	//Used for mapping mainly
	var/possible_destinations = ""
	var/list/valid_docks = list("whiteship_home")

	var/angle
	var/thrust_percentage
	//Our orbital body.
	var/datum/orbital_object/shuttle/shuttleObject
	//The target, speeds are calulated relative to this.
	var/datum/orbital_object/shuttleTarget

/obj/machinery/computer/shuttle_flight/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()
	valid_docks = params2list(possible_destinations)
	//Enable autopilot.
	if(autopilot_forced)
		autopilot = TRUE

/obj/machinery/computer/shuttle_flight/process()
	. = ..()
	if(!shuttleTarget || !autopilot || !shuttleObject || shuttleObject.docking_target)
		return

	//Relative velocity to target needs to point towards target.
	var/distance_to_target = shuttleObject.position.Distance(shuttleTarget.position)
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
		if(object.position.ShortestDistanceToLine(shuttleObject.position, shuttleObject.velocity) < object.radius)
			//Make sure we are closer to our target than this object, otherwise the colliding object is behind the target.
			var/distance_to_object = shuttleObject.position.Distance(object.position)
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
	var/datum/orbital_vector/desired_velocity = new(next_position.x - shuttleObject.position.x, next_position.y - shuttleObject.position.y)
	var/desired_speed = max(distance_to_target * 0.2, 0.5)
	desired_velocity.Normalize()
	desired_velocity.Scale(desired_speed)

	//Adjust thrust to make our velocity = desired_velocity
	var/thrust_dir_x = desired_velocity.x - shuttleObject.velocity.x
	var/thrust_dir_y = desired_velocity.y - shuttleObject.velocity.y

	//message_admins("Thrusting in dir: [thrust_dir_y], [thrust_dir_x]")
	//message_admins("Next pos: [next_position.x], [next_position.y]")

	if(!thrust_dir_x)
		if(!thrust_dir_y)
			thrust_percentage = 0
			shuttleObject.thrust = thrust_percentage
			return
		angle = thrust_dir_y > 0 ? 90 : -90
	else
		angle = arctan(thrust_dir_y / thrust_dir_x)
		//Account for ambiguous cases
		if(thrust_dir_x < 0)
			if(thrust_dir_y < 0)
				angle = 180 - angle
			else
				angle = 90 - angle

	shuttleObject.angle = angle
	//FULL SPEED
	thrust_percentage = 100
	shuttleObject.thrust = thrust_percentage
	//Auto dock
	if(shuttleObject.can_dock_with == shuttleTarget)
		shuttleObject.commence_docking(shuttleTarget, TRUE)

/obj/machinery/computer/shuttle_flight/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/shuttle_flight/ui_interact(mob/user, datum/tgui/ui)
	//Ash walkers cannot use the console because they are unga bungas
	if(user.mind?.has_antag_datum(/datum/antagonist/ashwalker))
		to_chat(user, "<span class='warning'>This computer has been designed to keep the natives like you from meddling with it, you have no hope of using it.</span>")
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "OrbitalMap")
		ui.open()
	ui.set_autoupdate(TRUE)

/obj/machinery/computer/shuttle_flight/ui_data(mob/user)
	var/list/data = list()
	//Add orbital bodies
	data["map_objects"] = list()
	for(var/datum/orbital_object/object in SSorbits.orbital_map.bodies)
		//we can't see it
		if(object != shuttleObject && object.stealth)
			continue
		//Send to be rendered on the UI
		data["map_objects"] += list(list(
			"name" = object.name,
			"position_x" = object.position.x,
			"position_y" = object.position.y,
			"velocity_x" = object.velocity.x,
			"velocity_y" = object.velocity.y,
			"radius" = object.radius
		))
	if(!SSshuttle.getShuttle(shuttleId))
		data["linkedToShuttle"] = FALSE
		return
	data["canLaunch"] = TRUE
	data["autopilot"] = autopilot
	data["autopilot_forced"] = autopilot_forced
	if(!shuttleObject)
		data["linkedToShuttle"] = FALSE
		return data
	data["linkedToShuttle"] = TRUE
	data["shuttleTarget"] = shuttleTarget?.name
	data["shuttleName"] = shuttleObject?.name
	data["shuttleAngle"] = angle
	data["shuttleThrust"] = thrust_percentage
	if(shuttleTarget)
		data["shuttleVelX"] = shuttleObject.velocity.x - shuttleTarget.velocity.x
		data["shuttleVelY"] = shuttleObject.velocity.y - shuttleTarget.velocity.y
	else
		data["shuttleVelX"] = shuttleObject.velocity.x
		data["shuttleVelY"] = shuttleObject.velocity.y
	//Docking data
	data["canDock"] = shuttleObject.can_dock_with != null
	data["isDocking"] = shuttleObject.docking_target != null
	data["validDockingPorts"] = list()
	if(shuttleObject.docking_target)
		if(shuttleObject.docking_target.can_dock_anywhere)
			data["validDockingPorts"] += list(list(
				"name" = "Custom Location",
				"id" = "custom_location"
			))
		else if(shuttleObject.docking_target.random_docking)
			data["validDockingPorts"] += list(list(
				"name" = "Random Drop",
				"id" = "custom_location"
			))
		for(var/obj/docking_port/stationary/stationary_port as() in SSshuttle.stationary)
			if(stationary_port.z == shuttleObject.docking_target.linked_z_level.z_value && (stationary_port.id in valid_docks))
				data["validDockingPorts"] += list(list(
					"name" = stationary_port.name,
					"id" = stationary_port.id,
				))
	return data

/obj/machinery/computer/shuttle_flight/ui_act(action, params)
	. = ..()
	if(.)
		return
	if(admin_controlled)
		say("This shuttle is restricted to authorised personnel only.")
		return
	switch(action)
		if("setTarget")
			var/desiredTarget = params["target"]
			for(var/datum/orbital_object/object in SSorbits.orbital_map.bodies)
				if(object.name == desiredTarget)
					shuttleTarget = object
					return
		if("setThrust")
			if(autopilot)
				to_chat(usr, "<span class='warning'>Shuttle is controlled by autopilot.</span>")
				return
			if(!shuttleObject)
				return
			thrust_percentage = CLAMP(params["thrust"], 0, 100)
			shuttleObject.thrust = thrust_percentage
		if("setAngle")
			if(autopilot)
				to_chat(usr, "<span class='warning'>Shuttle is controlled by autopilot.</span>")
				return
			if(!shuttleObject)
				return
			angle = params["angle"]
			shuttleObject.angle = angle
		if("nautopilot")
			if(autopilot_forced)
				return
			if(!shuttleObject || !shuttleTarget)
				return
			autopilot = !autopilot
		//Launch the shuttle. Lets do this.
		if("launch")
			var/obj/docking_port/mobile/mobile_port = SSshuttle.getShuttle(shuttleId)
			if(!mobile_port)
				return
			if(mobile_port.mode == SHUTTLE_RECHARGING)
				say("Supercruise Warning: Shuttle engines not ready for use.")
				return
			if(mobile_port.mode != SHUTTLE_IDLE)
				say("Supercruise Warning: Shuttle already in transit.")
				return
			shuttleObject = mobile_port.enter_supercruise()
			shuttleObject.valid_docks = valid_docks
		//Dock at location.
		if("dock")
			if(!shuttleObject)
				return
			if(!shuttleObject.can_dock_with)
				return
			//Force dock with the thing we are colliding with.
			shuttleObject.commence_docking(shuttleObject.can_dock_with, TRUE)
		//Go to valid port
		if("gotoPort")
			if(!shuttleObject)
				return
			//Get our port
			var/obj/docking_port/mobile/mobile_port = SSshuttle.getShuttle(shuttleId)
			if(!mobile_port || mobile_port.destination != null)
				return
			//Check ready
			if(mobile_port.mode == SHUTTLE_RECHARGING)
				say("Supercruise Warning: Shuttle engines not ready for use.")
				return
			if(mobile_port.mode != SHUTTLE_CALL || mobile_port.destination)
				say("Supercruise Warning: Already dethrottling shuttle.")
				return
			//Disable autopilot
			if(!autopilot_forced)
				autopilot = FALSE
			//Special check
			if(params["port"] == "custom_location")
				//Open up internal docking computer if any location is allowed.
				//If random dropping is allowed, random drop.
				if(shuttleObject.docking_target.random_docking)
					random_drop()
					return
				//Report exploit
				log_admin("[usr] attempted to forge a target location through a tgui exploit on [src]")
				message_admins("[ADMIN_FULLMONTY(usr)] attempted to forge a target location through a tgui exploit on [src]")
				return
			//Find the target port
			var/obj/docking_port/stationary/target_port = SSshuttle.getDock(params["port"])
			if(!target_port)
				return
			if(!(target_port.id in valid_docks))
				log_admin("[usr] attempted to forge a target location through a tgui exploit on [src]")
				message_admins("[ADMIN_FULLMONTY(usr)] attempted to forge a target location through a tgui exploit on [src]")
				return
			switch(SSshuttle.moveShuttle(shuttleId, params["port"], 1))
				if(0)
					say("Initiating supercruise throttle-down, prepare for landing.")
					QDEL_NULL(shuttleObject)
				if(1)
					to_chat(usr, "<span class='warning'>Invalid shuttle requested.</span>")
				else
					to_chat(usr, "<span class='notice'>Unable to comply.</span>")

/obj/machinery/computer/shuttle_flight/proc/random_drop()
	//Find a random place to drop in at.
	if(!shuttleObject.docking_target?.linked_z_level)
		return
	//Get shuttle dock
	var/obj/docking_port/mobile/shuttle_dock = SSshuttle.getShuttle(shuttleId)
	if(!shuttle_dock)
		return
	//Create temporary port
	var/obj/docking_port/stationary/random_port = new
	random_port.delete_after = TRUE
	random_port.width = shuttle_dock.width
	random_port.height = shuttle_dock.height
	random_port.dwidth = shuttle_dock.dwidth
	random_port.dheight = shuttle_dock.dheight
	var/sanity = 20
	var/square_length = max(shuttle_dock.width, shuttle_dock.height)
	var/border_distance = 10 + square_length
	//20 attempts to find a random port
	while(sanity > 0)
		sanity --
		//Place the port in a random valid area.
		var/x = rand(border_distance, world.maxx - border_distance)
		var/y = rand(border_distance, world.maxy - border_distance)
		//Check to make sure there are no indestructible turfs in the way
		random_port.setDir(pick(NORTH, SOUTH, EAST, WEST))
		random_port.forceMove(locate(x, y, shuttleObject.docking_target.linked_z_level.z_value))
		var/list/turfs = random_port.return_turfs()
		var/valid = TRUE
		for(var/turf/T as() in turfs)
			if(istype(T, /turf/open/indestructible) || istype(T, /turf/closed/indestructible))
				valid = FALSE
				break
		if(!valid)
			continue
		//Ok lets go there
		switch(SSshuttle.moveShuttle(shuttleId, random_port.id, 1))
			if(0)
				say("Initiating supercruise throttle-down, prepare for landing.")
				QDEL_NULL(shuttleObject)
			if(1)
				to_chat(usr, "<span class='warning'>Invalid shuttle requested.</span>")
				qdel(random_port)
			else
				to_chat(usr, "<span class='notice'>Unable to comply.</span>")
				qdel(random_port)
	qdel(random_port)

/obj/machinery/computer/shuttle_flight/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	req_access = list()
	obj_flags |= EMAGGED
	to_chat(user, "<span class='notice'>You fried the consoles ID checking system.</span>")

/obj/machinery/computer/shuttle_flight/connect_to_shuttle(obj/docking_port/mobile/port, obj/docking_port/stationary/dock, idnum, override=FALSE)
	if(port && (shuttleId == initial(shuttleId) || override))
		shuttleId = port.id

