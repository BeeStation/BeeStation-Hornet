/obj/machinery/computer/system_map
	name = "system map console"
	desc = "system map here"
	icon_screen = "cameras"
	icon_keyboard = "security_key"
	circuit = /obj/item/circuitboard/computer/security
	light_color = LIGHT_COLOR_RED

	// Note: Not all shuttles have a bluespace drive
	var/datum/weakref/linked_bluespace_drive

	// Shuttle_ID as seen in SSshuttles
	var/shuttle_id

	//Overriding
	//Other jump locations
	//So you can bring your big ships back <3
	var/list/standard_port_locations = list("whiteship_home")

/obj/machinery/computer/system_map/exploration
	shuttle_id = "exploration"

/obj/machinery/computer/system_map/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()
	//Locate the shuttle ID we are attatched to (if we are attatched)
	if(!shuttle_id)
		addtimer(CALLBACK(src, .proc/get_attached_shuttle), 8)
	//Locate the bluespace drive
	addtimer(CALLBACK(src, .proc/locate_bluespace_drive), 12)

/obj/machinery/computer/system_map/ui_interact(mob/user, datum/tgui/ui)
	if(!shuttle_id)
		to_chat(usr, "<span class='warning'>Console not attatched to a bluespace capable shuttle.</span>")
		return
	// Update UI
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		// Open UI
		ui = new(user, src, "SystemMap")
		ui.open()


/obj/machinery/computer/system_map/ui_data(mob/user)
	var/list/data = list()
	var/obj/docking_port/mobile/linkedShuttle = SSshuttle.getShuttle(shuttle_id)
	data["ship_status"] = linkedShuttle ? linkedShuttle.name : "N/A"
	data["active_lanes"] = 1
	data["queue_length"] = LAZYLEN(SSbluespace_exploration.ship_traffic_queue) + SSbluespace_exploration.generating
	data["departure_time"] = (LAZYLEN(SSbluespace_exploration.ship_traffic_queue) + SSbluespace_exploration.generating) * 90
	var/datum/ship_datum/SD = SSbluespace_exploration.tracked_ships[shuttle_id]
	data["stars"] = list()
	if(SD)
		data["ship_name"] = SD.ship_name
		var/datum/faction/faction = SD.ship_faction
		data["ship_faction"] = faction.name
		if(CONFIG_GET(flag/bluespace_exploration_random_levels))
			//Initial setup
			if(!islist(SD.star_systems))
				SD.recalculate_star_systems()
			for(var/star_id in SD.star_systems)
				var/datum/star_system/system = SD.star_systems[star_id]
				var/datum/faction/system_faction = system.system_alignment
				var/list/formatted_star = list(
					"name" = system.name,
					"alignment" = system_faction ? system_faction.name : "Error",
					"threat" = system.calculated_threat,
					"research_value" = system.calculated_research_potential,
					"distance" = system.distance_from_center,
				)
				data["stars"] += list(formatted_star)
	else
		data["ship_name"] = "Unknown"
		data["ship_faction"] = "independant"
	//Put standard ports
	for(var/star_id in standard_port_locations)
		var/obj/docking_port/stationary/S = SSshuttle.getDock(star_id)
		if(!S || !linkedShuttle.check_dock(S, silent=TRUE))
			continue
		var/list/formatted_star = list(
			"name" = S.name,
			"id" = S.id,
			"alignment" = "Unknown",
			"threat" = "Unknown",
			"research_value" = "Unknown",
			"distance" = calculate_distance_to_stationary_port(S),
		)
		data["stars"] += list(formatted_star)
	return data

/obj/machinery/computer/system_map/ui_act(action, params)
	var/obj/docking_port/mobile/linkedShuttle = SSshuttle.getShuttle(shuttle_id)
	if(!linkedShuttle || linkedShuttle.mode != SHUTTLE_IDLE)
		say("Jump already in progress.")
		return
	switch(action)
		if("jump")
			var/obj/machinery/bluespace_drive/bs_drive = null
			if(linked_bluespace_drive)
				bs_drive = linked_bluespace_drive.resolve()
			//Locate attached ship.
			var/datum/ship_datum/attached_ship = SSbluespace_exploration.tracked_ships[shuttle_id]
			if(!attached_ship)
				say("Console not linked to a ship, please rebuild this console on a bluespace capable shuttle.")
				return
			//Locate Star
			var/star_name = params["system_name"]
			if(!star_name)
				return
			//Check if the jump location is actually a standard one
			if(star_name in standard_port_locations)
				handle_jump_to_port(star_name)
				return
			var/star = attached_ship.star_systems[star_name]
			if(!star)
				return
			//Check for jumping actions
			if(attached_ship.bluespace)
				if(!bs_drive || QDELETED(bs_drive))
					say("Your drive is experiencing issues, or cannot be located. Please contact your ship's engineer.")
					return
				//Locate the BS drive and then trigger jump
				say("Sending engagement request to bluespace drive...")
				if(bs_drive.engage(star))
					attached_ship.recalculate_star_systems()
			else
				handle_space_jump(star)
				attached_ship.recalculate_star_systems()

//Do this a few frames after loading everything, since if it loads at the same time as the drive it can fail to be located
/obj/machinery/computer/system_map/proc/locate_bluespace_drive()
	var/obj/docking_port/mobile/M = SSshuttle.getShuttle(shuttle_id)
	if(M)
		for(var/obj/machinery/bluespace_drive/BSD as() in SSbluespace_exploration.bluespace_drives)
			if(get_turf(BSD) in M.return_turfs())
				linked_bluespace_drive = WEAKREF(BSD)
				return

/obj/machinery/computer/system_map/proc/get_attached_shuttle()
	var/turf/our_turf = get_turf(src)
	for(var/shuttle_dock_id in SSbluespace_exploration.tracked_ships)
		var/obj/docking_port/mobile/M = SSshuttle.getShuttle(shuttle_dock_id)
		if(!M)
			continue
		if(M.z != z)
			continue
		if(our_turf in M.return_turfs())
			shuttle_id = M.id
			break

/obj/machinery/computer/system_map/proc/handle_jump_to_port(static_port_id, dist = 0)
	if(!static_port_id)
		return
	var/obj/docking_port/stationary/targetPort = SSshuttle.getDock(static_port_id)
	if(!targetPort)
		return
	var/obj/docking_port/mobile/linkedShuttle = SSshuttle.getShuttle(shuttle_id)
	linkedShuttle.count_engines()
	linkedShuttle.hyperspace_sound(HYPERSPACE_WARMUP)
	if(!(static_port_id in standard_port_locations))
		log_admin("[usr] attempted to launch a shuttle that has been affected by href dock exploit on [src] with target location \"[static_port_id]\"")
		message_admins("[usr] attempted to launch a shuttle that has been affected by href dock exploit on [src] with target location \"[static_port_id]\"")
		return
	switch(SSshuttle.moveShuttle(shuttle_id, static_port_id, 1))
		if(0)
			consumeFuel(dist)
			say("Shuttle departing. Please stand away from the doors.")
		if(1)
			to_chat(usr, "<span class='warning'>Invalid shuttle requested.</span>")
		else
			to_chat(usr, "<span class='notice'>Unable to comply.</span>")
	return

/obj/machinery/computer/system_map/proc/consumeFuel(dist)
	return

/obj/machinery/computer/system_map/proc/handle_space_jump(star)
	say("Calculating hyperlane jump, please stand back from the doors...")
	SSbluespace_exploration.request_ship_transit_to(shuttle_id, star)

/obj/machinery/computer/system_map/proc/calculate_distance_to_stationary_port(obj/docking_port/stationary/S)
	var/deltaX = S.x - x
	var/deltaY = S.y - y
	var/deltaZ = (S.z - z) * 500
	return sqrt(deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ)
