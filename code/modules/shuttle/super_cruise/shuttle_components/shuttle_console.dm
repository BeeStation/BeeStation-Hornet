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
	RegisterSignal(SSorbits, COMSIG_ORBITAL_BODY_CREATED, .proc/register_shuttle_object)
	register_shuttle_object(null, SSorbits.assoc_shuttles[shuttleId])

/obj/machinery/computer/shuttle_flight/Destroy()
	. = ..()
	SSorbits.open_orbital_maps -= SStgui.get_all_open_uis(src)
	unregister_shuttle_object(shuttleObject, FALSE)
	UnregisterSignal(SSorbits, COMSIG_ORBITAL_BODY_CREATED)
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

/obj/machinery/computer/shuttle_flight/proc/register_shuttle_object(datum/source, datum/orbital_object/body, datum/orbital_map/map)
	var/datum/orbital_object/shuttle/shuttle = body
	if(!istype(shuttle))
		return
	if(shuttle.shuttle_port_id != shuttleId)
		return
	shuttleObject = body
	RegisterSignal(shuttleObject, COMSIG_PARENT_QDELETING, .proc/unregister_shuttle_object)
	RegisterSignal(shuttleObject, COMSIG_ORBITAL_BODY_MESSAGE, .proc/on_shuttle_messaged)

/obj/machinery/computer/shuttle_flight/proc/unregister_shuttle_object(datum/source, force)
	UnregisterSignal(shuttleObject, COMSIG_PARENT_QDELETING)
	UnregisterSignal(shuttleObject, COMSIG_ORBITAL_BODY_MESSAGE)
	shuttleObject = null
	if(current_user)
		remove_eye_control(current_user)

/obj/machinery/computer/shuttle_flight/proc/on_shuttle_messaged(datum/source, message)
	say(message)

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
	data["linkedToShuttle"] = TRUE
	data["shuttleTarget"] = shuttleObject.ai_pilot?.get_target_name()
	data["shuttleName"] = shuttleObject.name
	data["shuttleAngle"] = shuttleObject.angle
	data["shuttleThrust"] = shuttleObject.thrust
	data["autopilot_enabled"] = shuttleObject.ai_pilot?.is_active()
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
							shuttleObject.set_pilot(new /datum/shuttle_ai_pilot/autopilot/request(
								z_linked, recall_docking_port_id
							))
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
						var/is_autopilot_active = shuttleObject.ai_pilot?.is_active()
						shuttleObject.set_pilot(new /datum/shuttle_ai_pilot/autopilot(object))
						if(is_autopilot_active)
							shuttleObject.ai_pilot?.try_toggle()
						return
		if("nautopilot")
			if(QDELETED(shuttleObject))
				return
			if(!shuttleObject.ai_pilot?.try_toggle())
				shuttleObject.try_override_pilot()
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
			if(shuttleObject.ai_pilot?.is_active())
				if(!shuttleObject.ai_pilot?.try_toggle() && !shuttleObject.try_override_pilot())
					say("Shuttle is controlled from an external location.")
					return
			var/x = text2num(params["x"])
			var/y = text2num(params["y"])
			if(!shuttleObject.shuttleTargetPos)
				shuttleObject.shuttleTargetPos = new(x, y)
			else
				shuttleObject.shuttleTargetPos.x = x
				shuttleObject.shuttleTargetPos.y = y
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
				other_shuttle.random_drop(z_linked.linked_z_level[1].z_value)
				SSorbits.interdicted_shuttles[other_shuttle.shuttle_port_id] = world.time + interdiction_time
			shuttleObject.commence_docking(z_linked, TRUE)
			shuttleObject.random_drop(z_linked.linked_z_level[1].z_value)
			SSorbits.interdicted_shuttles[shuttleId] = world.time + interdiction_time
		//Go to valid port
		if("gotoPort")
			if(!shuttleObject)
				say("Shuttle has already landed, cannot dock at this time.")
				return
			//Special check
			if(params["port"] == "custom_location")
				//Open up internal docking computer if any location is allowed.
				if(shuttleObject.docking_target.can_dock_anywhere)
					var/obj/docking_port/mobile/mobile_port = SSshuttle.getShuttle(shuttleId)
					if(!mobile_port)
						say("Cannot locate shuttle.")
						return
					if(GLOB.shuttle_docking_jammed && !shuttleObject.stealth && istype(shuttleObject.docking_target, /datum/orbital_object/z_linked/station))
						say("Shuttle docking computer jammed.")
						return
					if(current_user)
						to_chat(usr, "<span class='warning'>Somebody is already docking the shuttle.</span>")
						return
					view_range = max(mobile_port.width, mobile_port.height) + 4
					give_eye_control(usr)
					eyeobj.forceMove(locate(world.maxx * 0.5, world.maxy * 0.5, shuttleObject.docking_target.linked_z_level[1].z_value))
					return
				//If random dropping is allowed, random drop.
				if(shuttleObject.docking_target.random_docking)
					shuttleObject.random_drop()
					return
				//Report exploit
				log_admin("[usr] attempted to forge a target location through a tgui exploit on [src]")
				message_admins("[ADMIN_FULLMONTY(usr)] attempted to forge a target location through a tgui exploit on [src]")
				return
			//Go to the specified docking port
			shuttleObject.goto_port(params["port"])

/obj/machinery/computer/shuttle_flight/proc/launch_shuttle()
	if(SSorbits.interdicted_shuttles.Find(shuttleId))
		if(world.time < SSorbits.interdicted_shuttles[shuttleId])
			var/time_left = (SSorbits.interdicted_shuttles[shuttleId] - world.time) * 0.1
			say("Supercruise Warning: Engines have been interdicted and will be recharged in [time_left] seconds.")
			return
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
	if(!shuttleObject)
		say("Failed to enter supercruise due to an unknown error.")
		return
	shuttleObject.valid_docks = valid_docks
	return shuttleObject

/obj/machinery/computer/shuttle_flight/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	req_access = list()
	obj_flags |= EMAGGED
	to_chat(user, "<span class='notice'>You fried the consoles ID checking system.</span>")

/obj/machinery/computer/shuttle_flight/allowed(mob/M)
	var/obj/item/circuitboard/computer/shuttle/circuit_board = circuit
	if(istype(circuit_board) && circuit_board.hacked)
		return TRUE
	return ..()
