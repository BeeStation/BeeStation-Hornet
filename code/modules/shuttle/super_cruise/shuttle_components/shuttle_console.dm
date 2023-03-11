GLOBAL_VAR_INIT(shuttle_docking_jammed, FALSE)

/obj/machinery/computer/shuttle_flight
	name = "shuttle console"
	desc = "A shuttle control computer."
	icon_screen = "shuttle"
	icon_keyboard = "tech_key"
	light_color = LIGHT_COLOR_CYAN
	req_access = list()
	var/shuttleId

	//Interdiction range
	var/interdiction_range = 150
	//Time it takes to recharge after interdiction
	var/interdiction_time = 3 MINUTES

	//For recall consoles
	//If not set to an empty string, will display only the option to call the shuttle to that dock.
	//Once pressed the shuttle will engage autopilot and return to the dock.
	var/recall_docking_port_id = ""

	var/request_shuttle_message = "Request Shuttle"

	//Admin controlled shuttles
	var/admin_controlled = FALSE

	//Used for mapping mainly
	var/possible_destinations = ""
	var/list/valid_docks = list("")

	//The current orbital map we are observing
	var/orbital_map_index = PRIMARY_ORBITAL_MAP

	//Our orbital body.
	var/datum/orbital_object/shuttle/shuttleObject

/obj/machinery/computer/shuttle_flight/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()
	valid_docks = params2list(possible_destinations)
	if(shuttleId)
		shuttlePortId = "[shuttleId]_custom"
	else
		var/static/i = 0
		shuttlePortId = "unlinked_shuttle_console_[i++]"

/obj/machinery/computer/shuttle_flight/Destroy()
	. = ..()
	SSorbits.open_orbital_maps -= SStgui.get_all_open_uis(src)
	shuttleObject = null
	//De-link the port
	if(my_port)
		my_port.delete_after = TRUE
		my_port.id = null
		my_port.name = "Old [my_port.name]"
		my_port = null

/obj/machinery/computer/shuttle_flight/examine(mob/user)
	. = ..()
	var/obj/item/circuitboard/computer/shuttle/circuit_board = circuit
	if(istype(circuit_board))
		if(circuit_board.hacked)
			. += "It's access requirements have been disabled."
		else
			. += "It's access requirements could be disabled by disassembling the computer and using a multitool on the circuitboard."

/obj/machinery/computer/shuttle_flight/process()
	. = ..()

	//Check to see if the shuttleObject was launched by another console.
	if(QDELETED(shuttleObject) && SSorbits.assoc_shuttles.Find(shuttleId))
		shuttleObject = SSorbits.assoc_shuttles[shuttleId]

	if(recall_docking_port_id && shuttleObject?.docking_target && shuttleObject.shuttleTarget == shuttleObject.docking_target && shuttleObject.controlling_computer == src)
		//We are at destination, dock.
		shuttleObject.controlling_computer = null
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
	if(!allowed(user) && !isobserver(user))
		say("Insufficient access rights.")
		return
	//Ash walkers cannot use the console because they are unga bungas
	if(user.mind?.has_antag_datum(/datum/antagonist/ashwalker))
		to_chat(user, "<span class='warning'>This computer has been designed to keep the natives like you from meddling with it, you have no hope of using it.</span>")
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "OrbitalMap")
		ui.open()
	SSorbits.open_orbital_maps |= ui
	ui.set_autoupdate(FALSE)

/obj/machinery/computer/shuttle_flight/ui_close(mob/user, datum/tgui/tgui)
	SSorbits.open_orbital_maps -= tgui

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
	data["request_shuttle_message"] = request_shuttle_message
	data["interdiction_range"] = interdiction_range
	return data

/obj/machinery/computer/shuttle_flight/ui_data(mob/user)
	//Fetch data
	var/user_ref = "[REF(user)]"

	//Get the base map data
	var/list/data = SSorbits.get_orbital_map_base_data(
		SSorbits.orbital_maps[orbital_map_index],
		user_ref,
		FALSE,
		shuttleObject
	)

	//Send shuttle data
	if(!SSshuttle.getShuttle(shuttleId))
		data["linkedToShuttle"] = FALSE
		return data
	//Interdicted shuttles
	data["interdictedShuttles"] = list()
	if(SSorbits.interdicted_shuttles[shuttleId] > world.time)
		var/obj/docking_port/our_port = SSshuttle.getShuttle(shuttleId)
		data["interdictionTime"] = SSorbits.interdicted_shuttles[shuttleId] - world.time
		for(var/interdicted_id in SSorbits.interdicted_shuttles)
			var/timer = SSorbits.interdicted_shuttles[interdicted_id]
			if(timer < world.time)
				continue
			var/obj/docking_port/port = SSshuttle.getShuttle(interdicted_id)
			if(port && port.get_virtual_z_level() == our_port.get_virtual_z_level())
				data["interdictedShuttles"] += list(list(
					"shuttleName" = port.name,
					"x" = port.x - our_port.x,
					"y" = port.y - our_port.y,
				))
	else
		data["interdictionTime"] = 0

	data["canLaunch"] = TRUE
	if(QDELETED(shuttleObject))
		data["linkedToShuttle"] = FALSE
		return data
	data["autopilot"] = shuttleObject.autopilot
	data["linkedToShuttle"] = TRUE
	data["shuttleTarget"] = shuttleObject.shuttleTarget?.name
	data["shuttleName"] = shuttleObject.name
	data["shuttleAngle"] = shuttleObject.angle
	data["shuttleThrust"] = shuttleObject.thrust
	data["autopilot_enabled"] = shuttleObject.autopilot
	if(shuttleObject?.shuttleTarget)
		data["shuttleVelX"] = shuttleObject.velocity.x - shuttleObject.shuttleTarget.velocity.x
		data["shuttleVelY"] = shuttleObject.velocity.y - shuttleObject.shuttleTarget.velocity.y
	else
		data["shuttleVelX"] = shuttleObject.velocity.x
		data["shuttleVelY"] = shuttleObject.velocity.y
	//Docking data
	data["canDock"] = shuttleObject.can_dock_with != null && !shuttleObject.docking_frozen
	data["isDocking"] = shuttleObject.docking_target != null && !shuttleObject.docking_frozen && !shuttleObject.docking_target.is_generating
	data["shuttleTargetX"] = shuttleObject.shuttleTargetPos?.x
	data["shuttleTargetY"] = shuttleObject.shuttleTargetPos?.y
	data["validDockingPorts"] = list()
	if(shuttleObject.docking_target && !shuttleObject.docking_frozen)
		//Stealth shuttles bypass shuttle jamming.
		if(shuttleObject.docking_target.can_dock_anywhere && (!GLOB.shuttle_docking_jammed || shuttleObject.stealth || !istype(shuttleObject.docking_target, /datum/orbital_object/z_linked/station)))
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
			if(LAZYLEN(shuttleObject.docking_target.linked_z_level))
				for(var/datum/space_level/level in shuttleObject.docking_target.linked_z_level)
					if(stationary_port.z == level.z_value && (stationary_port.id in valid_docks))
						data["validDockingPorts"] += list(list(
							"name" = stationary_port.name,
							"id" = stationary_port.id,
						))
	return data

/obj/machinery/computer/shuttle_flight/ui_act(action, params)
	. = ..()

	if(.)
		return

	if(!allowed(usr))
		say("Insufficient access rights.")
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
				var/datum/orbital_map/viewing_map = SSorbits.orbital_maps[orbital_map_index]
				for(var/map_key in viewing_map.collision_zone_bodies)
					for(var/datum/orbital_object/z_linked/z_linked as() in viewing_map.collision_zone_bodies[map_key])
						if(!istype(z_linked))
							continue
						if(z_linked.z_in_contents(target_port.z))
							if(!SSorbits.assoc_shuttles.Find(shuttleId))
								//Launch the shuttle
								if(!launch_shuttle())
									return
							if(shuttleObject.shuttleTarget == z_linked && shuttleObject.controlling_computer == src)
								return
							shuttleObject = SSorbits.assoc_shuttles[shuttleId]
							shuttleObject.shuttleTarget = z_linked
							shuttleObject.autopilot = TRUE
							shuttleObject.controlling_computer = src
							say("Shuttle requested.")
							return
				say("Docking port in invalid location. Please contact a Nanotrasen technician.")
		return

	switch(action)
		if("setTarget")
			if(QDELETED(shuttleObject))
				say("Shuttle not in flight.")
				return
			var/desiredTarget = params["target"]
			if(shuttleObject.name == desiredTarget)
				return
			var/datum/orbital_map/showing_map = SSorbits.orbital_maps[orbital_map_index]
			for(var/map_key in showing_map.collision_zone_bodies)
				for(var/datum/orbital_object/object as() in showing_map.collision_zone_bodies[map_key])
					if(object.name == desiredTarget)
						shuttleObject.shuttleTarget = object
						return
		if("setThrust")
			if(QDELETED(shuttleObject))
				say("Shuttle not in flight.")
				return
			if(shuttleObject.autopilot)
				to_chat(usr, "<span class='warning'>Shuttle is controlled by autopilot.</span>")
				return
			shuttleObject.thrust = CLAMP(params["thrust"], 0, 100)
		if("setAngle")
			if(QDELETED(shuttleObject))
				say("Shuttle not in flight.")
				return
			if(shuttleObject.autopilot)
				to_chat(usr, "<span class='warning'>Shuttle is controlled by autopilot.</span>")
				return
			shuttleObject.angle = params["angle"]
		if("nautopilot")
			if(QDELETED(shuttleObject) || !shuttleObject.shuttleTarget)
				return
			shuttleObject.autopilot = !shuttleObject.autopilot
			shuttleObject.shuttleTargetPos = null
		//Launch the shuttle. Lets do this.
		if("launch")
			launch_shuttle()
		//Dock at location.
		if("dock")
			if(QDELETED(shuttleObject))
				say("Docking computer offline.")
				return
			if(!shuttleObject.can_dock_with)
				say("Docking computer failed to find docking target.")
				return
			//Force dock with the thing we are colliding with.
			shuttleObject.commence_docking(shuttleObject.can_dock_with, TRUE)
		if("setTargetCoords")
			if(QDELETED(shuttleObject))
				return
			var/x = text2num(params["x"])
			var/y = text2num(params["y"])
			if(!shuttleObject.shuttleTargetPos)
				shuttleObject.shuttleTargetPos = new(x, y)
			else
				shuttleObject.shuttleTargetPos.x = x
				shuttleObject.shuttleTargetPos.y = y
			shuttleObject.autopilot = FALSE
			. = TRUE
		if("interdict")
			if(QDELETED(shuttleObject))
				say("Interdictor not ready.")
				return
			if(shuttleObject.docking_target || shuttleObject.can_dock_with)
				say("Cannot use interdictor while docking.")
				return
			if(shuttleObject.stealth)
				say("Cannot use interdictor on stealthed shuttles.")
				return
			var/list/interdicted_shuttles = list()
			for(var/shuttleportid in SSorbits.assoc_shuttles)
				var/datum/orbital_object/shuttle/other_shuttle = SSorbits.assoc_shuttles[shuttleportid]
				//Do this last
				if(other_shuttle == shuttleObject)
					continue
				if(other_shuttle?.position?.DistanceTo(shuttleObject.position) <= interdiction_range && !other_shuttle.stealth)
					interdicted_shuttles += other_shuttle
			if(!length(interdicted_shuttles))
				say("No targets to interdict in range.")
				return
			say("Interdictor activated, shuttle throttling down...")
			//Create the site of interdiction
			var/datum/orbital_object/z_linked/beacon/z_linked = new /datum/orbital_object/z_linked/beacon/ruin/interdiction(
				new /datum/orbital_vector(shuttleObject.position.x, shuttleObject.position.y)
			)
			z_linked.name = "Interdiction Site"
			//Lets tell everyone about it
			priority_announce("Supercruise interdiction detected, interdicted shuttles have been registered onto local GPS units. Source: [shuttleObject.name]")
			//Get all shuttle objects in range
			for(var/datum/orbital_object/shuttle/other_shuttle in interdicted_shuttles)
				other_shuttle.commence_docking(z_linked, TRUE)
				random_drop(other_shuttle, other_shuttle.shuttle_port_id)
				SSorbits.interdicted_shuttles[other_shuttle.shuttle_port_id] = world.time + interdiction_time
			shuttleObject.commence_docking(z_linked, TRUE)
			random_drop()
			SSorbits.interdicted_shuttles[shuttleId] = world.time + interdiction_time
		//Go to valid port
		if("gotoPort")
			if(QDELETED(shuttleObject))
				say("Shuttle has already landed, cannot dock at this time.")
				return
			if(QDELETED(shuttleObject.docking_target))
				say("Docking target lost, please re-establish orbital trajectory.")
				return
			if(shuttleObject.docking_frozen)
				say("Cannot dock at this time.")
				return
			if(shuttleObject.docking_target.is_generating)
				say("Please wait for docking computer to align...")
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
				if(shuttleObject.docking_target.can_dock_anywhere)
					if(GLOB.shuttle_docking_jammed && !shuttleObject.stealth && istype(shuttleObject.docking_target, /datum/orbital_object/z_linked/station))
						say("Shuttle docking computer jammed.")
						return
					if(current_user)
						to_chat(usr, "<span class='warning'>Somebody is already docking the shuttle.</span>")
						return
					view_range = max(mobile_port.width, mobile_port.height, mobile_port.dwidth, mobile_port.dheight) * 0.5 - 4
					give_eye_control(usr)
					eyeobj.forceMove(locate(world.maxx * 0.5, world.maxy * 0.5, shuttleObject.docking_target.linked_z_level[1].z_value))
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
			//Dont wipe z level while we are going
			//Dont wipe z of where we are leaving for a bit, in case we come back.
			SSzclear.temp_keep_z(z)
			SSzclear.temp_keep_z(target_port.z)
			switch(SSshuttle.moveShuttle(shuttleId, target_port.id, 1))
				if(0)
					say("Initiating supercruise throttle-down, prepare for landing.")
					if(current_user)
						remove_eye_control(current_user)
					QDEL_NULL(shuttleObject)
					//Hold the shuttle in the docking position until ready.
					mobile_port.setTimer(INFINITY)
					say("Waiting for hyperspace lane...")
					INVOKE_ASYNC(src, PROC_REF(unfreeze_shuttle), mobile_port, SSmapping.get_level(target_port.z))
				if(1)
					to_chat(usr, "<span class='warning'>Invalid shuttle requested.</span>")
				else
					to_chat(usr, "<span class='notice'>Unable to comply.</span>")

/obj/machinery/computer/shuttle_flight/proc/launch_shuttle()
	if(SSorbits.interdicted_shuttles.Find(shuttleId))
		if(world.time < SSorbits.interdicted_shuttles[shuttleId])
			var/time_left = (SSorbits.interdicted_shuttles[shuttleId] - world.time) * 0.1
			say("Supercruise Warning: Engines have been interdicted and will be recharged in [time_left] seconds.")
			return
	var/obj/docking_port/mobile/mobile_port = SSshuttle.getShuttle(shuttleId)
	if(!mobile_port)
		return
	if(!mobile_port.canMove())
		say("Supercruise Warning: The shuttle's movement is being inhibited.")
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
	if(!shuttleObject)
		say("Failed to enter supercruise due to an unknown error.")
		return
	shuttleObject.valid_docks = valid_docks
	return shuttleObject

/obj/machinery/computer/shuttle_flight/proc/random_drop(datum/orbital_object/shuttle/_shuttleObject = shuttleObject, _shuttleId = shuttleId)
	//Find a random place to drop in at.
	if(!(_shuttleObject?.docking_target?.linked_z_level))
		return FALSE
	//Get shuttle dock
	var/obj/docking_port/mobile/shuttle_dock = SSshuttle.getShuttle(_shuttleId)
	if(!shuttle_dock)
		return FALSE
	var/datum/space_level/target_spacelevel = _shuttleObject.docking_target.linked_z_level[1]
	var/target_zvalue = target_spacelevel.z_value
	if(is_reserved_level(target_zvalue))
		message_admins("Shuttle [_shuttleId] attempted to dock on a reserved z-level as a result of docking with [_shuttleObject.docking_target.name].")
		return FALSE
	//Create temporary port
	var/obj/docking_port/stationary/random_port = new
	var/static/random_drops = 0
	random_port.id = "randomdroplocation_[random_drops++]"
	random_port.name = "Random drop location"
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
		random_port.forceMove(locate(x, y, target_zvalue))
		var/list/turfs = random_port.return_turfs()
		var/valid = TRUE
		for(var/turf/T as() in turfs)
			if(istype(T, /turf/open/indestructible) || istype(T, /turf/closed/indestructible))
				valid = FALSE
				break
		if(!valid)
			continue
		//Dont wipe z level while we are going
		//Dont wipe z of where we are leaving for a bit, in case we come back.
		SSzclear.temp_keep_z(z)
		SSzclear.temp_keep_z(target_zvalue)
		//Ok lets go there
		switch(SSshuttle.moveShuttle(_shuttleId, random_port.id, 1))
			if(0)
				say("Initiating supercruise throttle-down, prepare for landing.")
				if(current_user)
					remove_eye_control(current_user)
				QDEL_NULL(_shuttleObject)
				//Hold the shuttle in the docking position until ready.
				shuttle_dock.setTimer(INFINITY)
				say("Waiting for hyperspace lane...")
				INVOKE_ASYNC(src, PROC_REF(unfreeze_shuttle), shuttle_dock, target_spacelevel)
				return TRUE
			if(1)
				say("Invalid shuttle requested")
			else
				say("Unable to comply.")
	qdel(random_port)
	say("FAILED TO DROP IN A RANDOM PLACE PLEASE TRY AGAIN!!!!!!!!!")
	return FALSE

/obj/machinery/computer/shuttle_flight/proc/unfreeze_shuttle(obj/docking_port/mobile/shuttle_dock, datum/space_level/target_spacelevel)
	var/start_time = world.time
	UNTIL((!target_spacelevel.generating) || world.time > start_time + 3 MINUTES)
	if(target_spacelevel.generating)
		target_spacelevel.generating = FALSE
		message_admins("CAUTION: SHUTTLE [shuttleId] REACHED THE GENERATION TIMEOUT OF 3 MINUTES. THE ASSIGNED Z-LEVEL IS STILL MARKED AS GENERATING, BUT WE ARE DOCKING ANYWAY.")
		log_mapping("CAUTION: SHUTTLE [shuttleId] REACHED THE GENERATION TIMEOUT OF 3 MINUTES. THE ASSIGNED Z-LEVEL IS STILL MARKED AS GENERATING, BUT WE ARE DOCKING ANYWAY.")
	shuttle_dock.setTimer(20)

/obj/machinery/computer/shuttle_flight/on_emag(mob/user)
	..()
	req_access = list()
	to_chat(user, "<span class='notice'>You fried the consoles ID checking system.</span>")

/obj/machinery/computer/shuttle_flight/allowed(mob/M)
	var/obj/item/circuitboard/computer/shuttle/circuit_board = circuit
	if(istype(circuit_board) && circuit_board.hacked)
		return TRUE
	return ..()
