GLOBAL_VAR_INIT(shuttle_docking_jammed, FALSE)

/obj/machinery/computer/shuttle_flight
	name = "shuttle console"
	desc = "A shuttle control computer."
	icon_screen = "shuttle"
	icon_keyboard = "tech_key"
	light_color = LIGHT_COLOR_CYAN
	req_access = list( )
	var/shuttleId

	//For recall consoles
	//If not set to an empty string, will display only the option to call the shuttle to that dock.
	//Once pressed the shuttle will engage autopilot and return to the dock.
	var/recall_docking_port_id = ""

	//Admin controlled shuttles
	var/admin_controlled = FALSE

	//Used for mapping mainly
	var/possible_destinations = ""
	var/list/valid_docks = list("")

	//Our orbital body.
	var/datum/orbital_object/shuttle/shuttleObject

	//Internal shuttle docker computer
	var/obj/machinery/computer/camera_advanced/shuttle_docker/internal_shuttle_docker

/obj/machinery/computer/shuttle_flight/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()
	valid_docks = params2list(possible_destinations)
	internal_shuttle_docker = new()
	internal_shuttle_docker.shuttleId = shuttleId
	internal_shuttle_docker.shuttlePortId = "[shuttleId]_custom"
	for(var/dock in valid_docks)
		internal_shuttle_docker.jumpto_ports[dock] = TRUE

/obj/machinery/computer/shuttle_flight/Destroy()
	. = ..()
	shuttleObject = null
	QDEL_NULL(internal_shuttle_docker)

/obj/machinery/computer/shuttle_flight/process()
	. = ..()

	//Check to see if the shuttleobject was launched by another console.
	if(QDELETED(shuttleObject) && SSorbits.assoc_shuttles.Find(shuttleId))
		shuttleObject = SSorbits.assoc_shuttles[shuttleId]

	if(recall_docking_port_id && shuttleObject?.docking_target)
		//We are at destination, dock.
		switch(SSshuttle.moveShuttle(shuttleId, recall_docking_port_id, 1))
			if(0)
				say("Shuttle has arrived at destination.")
				QDEL_NULL(shuttleObject)
			if(1)
				to_chat(usr, "<span class='warning'>Invalid shuttle requested.</span>")
			else
				to_chat(usr, "<span class='notice'>Unable to comply.</span>")

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

/obj/machinery/computer/shuttle_flight/ui_static_data(mob/user)
	var/list/data = list()
	//The docks we can dock with never really changes
	//This is used for the forced autopilot mode where it goes to a set port.
	data["destination_docks"] = list()
	for(var/dock in valid_docks)
		data["valid_dock"] += list(list(
			"id" = dock,
		))
	//If we are a recall console.
	data["recall_docking_port_id"] = recall_docking_port_id
	return data

/obj/machinery/computer/shuttle_flight/ui_data(mob/user)
	var/list/data = list()
	//Add orbital bodies
	data["map_objects"] = list()
	for(var/datum/orbital_object/object in SSorbits.orbital_map.bodies)
		//we can't see it, unless we are stealth too
		if(object != shuttleObject && (object.stealth && !shuttleObject.stealth))
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
	if(QDELETED(shuttleObject))
		data["linkedToShuttle"] = FALSE
		return data
	data["autopilot"] = shuttleObject.autopilot
	data["linkedToShuttle"] = TRUE
	data["shuttleTarget"] = shuttleObject?.shuttleTarget?.name
	data["shuttleName"] = shuttleObject?.name
	data["shuttleAngle"] = shuttleObject.angle
	data["shuttleThrust"] = shuttleObject.thrust
	if(shuttleObject?.shuttleTarget)
		data["shuttleVelX"] = shuttleObject.velocity.x - shuttleObject.shuttleTarget.velocity.x
		data["shuttleVelY"] = shuttleObject.velocity.y - shuttleObject.shuttleTarget.velocity.y
	else
		data["shuttleVelX"] = shuttleObject.velocity.x
		data["shuttleVelY"] = shuttleObject.velocity.y
	//Docking data
	data["canDock"] = shuttleObject.can_dock_with != null
	data["isDocking"] = shuttleObject.docking_target != null
	data["validDockingPorts"] = list()
	if(shuttleObject.docking_target)
		if(shuttleObject.docking_target.can_dock_anywhere && !GLOB.shuttle_docking_jammed)
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

	if(recall_docking_port_id)
		switch(action)
			if("callShuttle")
				//Find the z-level that the dock is on
				var/obj/docking_port/stationary/target_port = SSshuttle.getDock(recall_docking_port_id)
				if(!target_port)
					say("Unable to locate port location.")
					return
				//Locate linked shuttle
				var/obj/docking_port/mobile/shuttle = SSshuttle.getShuttle(shuttleId)
				if(!shuttle)
					say("Unable to locate linked shuttle.")
					return
				if(target_port in shuttle.loc)
					say("Shuttle is already at destination.")
					return
				//Locate the orbital object
				for(var/datum/orbital_object/z_linked/z_linked in SSorbits.orbital_map.bodies)
					if(z_linked.linked_z_level.z_value == target_port.z)
						if(!SSorbits.assoc_shuttles.Find(shuttleId))
							//Launch the shuttle
							if(!launch_shuttle())
								return
						shuttleObject = SSorbits.assoc_shuttles[shuttleId]
						shuttleObject.shuttleTarget = z_linked
						shuttleObject.autopilot = TRUE
						say("Shuttle requested.")
						return
				say("Docking port in invalid location. Please contact a Nanotrasen technician.")
		return

	switch(action)
		if("setTarget")
			var/desiredTarget = params["target"]
			for(var/datum/orbital_object/object in SSorbits.orbital_map.bodies)
				if(object.name == desiredTarget)
					shuttleObject.shuttleTarget = object
					return
		if("setThrust")
			if(shuttleObject.autopilot)
				to_chat(usr, "<span class='warning'>Shuttle is controlled by autopilot.</span>")
				return
			if(QDELETED(shuttleObject))
				return
			shuttleObject.thrust = CLAMP(params["thrust"], 0, 100)
		if("setAngle")
			if(shuttleObject.autopilot)
				to_chat(usr, "<span class='warning'>Shuttle is controlled by autopilot.</span>")
				return
			if(QDELETED(shuttleObject))
				return
			shuttleObject.angle = params["angle"]
		if("nautopilot")
			if(QDELETED(shuttleObject) || !shuttleObject.shuttleTarget)
				return
			shuttleObject.autopilot = !shuttleObject.autopilot
		//Launch the shuttle. Lets do this.
		if("launch")
			launch_shuttle()
		//Dock at location.
		if("dock")
			if(QDELETED(shuttleObject))
				return
			if(!shuttleObject.can_dock_with)
				return
			//Force dock with the thing we are colliding with.
			shuttleObject.commence_docking(shuttleObject.can_dock_with, TRUE)
		//Go to valid port
		if("gotoPort")
			if(QDELETED(shuttleObject))
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
			//Special check
			if(params["port"] == "custom_location")
				//Open up internal docking computer if any location is allowed.
				if(shuttleObject.docking_target.can_dock_anywhere && !GLOB.shuttle_docking_jammed)
					internal_shuttle_docker.z_lock = list(shuttleObject.docking_target.linked_z_level)
					internal_shuttle_docker.see_hidden = mobile_port.hidden
					internal_shuttle_docker.view_range = max(mobile_port.width, mobile_port.height) + 4
					internal_shuttle_docker.attack_hand(usr)
					return
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

/obj/machinery/computer/shuttle_flight/proc/launch_shuttle()
	var/obj/docking_port/mobile/mobile_port = SSshuttle.getShuttle(shuttleId)
	if(!mobile_port)
		return
	if(mobile_port.mode == SHUTTLE_RECHARGING)
		say("Supercruise Warning: Shuttle engines not ready for use.")
		return
	if(mobile_port.mode != SHUTTLE_IDLE)
		say("Supercruise Warning: Shuttle already in transit.")
		return
	if(SSorbits.assoc_shuttles.Find(shuttleId))
		say("Shuttle is controlled from another location, updating telemetry.")
		shuttleObject = SSorbits.assoc_shuttles[shuttleId]
		return shuttleObject
	shuttleObject = mobile_port.enter_supercruise()
	shuttleObject.valid_docks = valid_docks
	return shuttleObject

/obj/machinery/computer/shuttle_flight/proc/random_drop()
	//Find a random place to drop in at.
	if(!shuttleObject.docking_target?.linked_z_level)
		return
	//Get shuttle dock
	var/obj/docking_port/mobile/shuttle_dock = SSshuttle.getShuttle(shuttleId)
	if(!shuttle_dock)
		return
	//Create temporary port
	var/obj/docking_port/stationary/random_port = new shuttle_dock.shuttle_object_type()
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

