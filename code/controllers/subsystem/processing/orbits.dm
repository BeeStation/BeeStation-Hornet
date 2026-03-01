PROCESSING_SUBSYSTEM_DEF(orbits)
	name = "Orbits"
	flags = SS_KEEP_TIMING
	init_stage = INITSTAGE_EARLY
	priority = FIRE_PRIORITY_ORBITS
	wait = ORBITAL_UPDATE_RATE

	//The primary orbital map.
	var/list/orbital_maps = list()

	var/datum/orbital_map_tgui/orbital_map_tgui = new()

	var/initial_space_ruins = 2
	var/initial_objective_beacons = 3
	var/initial_asteroids = 6

	var/orbits_setup = FALSE

	var/list/datum/orbital_objective/possible_objectives = list()

	var/datum/orbital_objective/current_objective

	var/list/datum/ruin_event/ruin_events = list()

	var/list/runnable_events

	var/event_probability = 60

	//key = port_id
	//value = orbital shuttle object
	var/list/assoc_shuttles = list()

	//key = z-level as a string
	//value = orbital object for that z-level
	var/list/assoc_z_levels = list()

	//Key = port_id
	//value = world time of next launch
	var/list/interdicted_shuttles = list()

	var/next_objective_time = 0

	//Research disks
	var/list/research_disks = list()

	var/list/datum/tgui/open_orbital_maps = list()

	//The station
	var/datum/orbital_object/station_instance

	//Ruin level count
	var/ruin_levels = 0

/datum/controller/subsystem/processing/orbits/Initialize()
	setup_event_list()
	//Create the main orbital map.
	orbital_maps[PRIMARY_ORBITAL_MAP] = new /datum/orbital_map()

	return SS_INIT_SUCCESS

/datum/controller/subsystem/processing/orbits/Recover()
	orbital_maps |= SSorbits.orbital_maps
	possible_objectives |= SSorbits.possible_objectives
	ruin_events |= SSorbits.ruin_events
	assoc_shuttles |= SSorbits.assoc_shuttles
	interdicted_shuttles |= SSorbits.interdicted_shuttles
	research_disks |= SSorbits.research_disks
	if(!islist(runnable_events)) runnable_events = list()
	runnable_events |= SSorbits.runnable_events

	station_instance = SSorbits.station_instance
	current_objective = SSorbits.current_objective
	next_objective_time = SSorbits.next_objective_time
	ruin_levels = SSorbits.ruin_levels
	orbital_map_tgui = SSorbits.orbital_map_tgui
	orbits_setup = SSorbits.orbits_setup

	for(var/datum/tgui/map as() in SSorbits.open_orbital_maps)
		map?.close()

	SSorbits.open_orbital_maps.Cut()

	for(var/datum/thing in SSorbits.processing)
		STOP_PROCESSING(SSorbits, thing)
		START_PROCESSING(src, thing)


/datum/controller/subsystem/processing/orbits/proc/setup_event_list()
	runnable_events = list()
	for(var/ruin_event in subtypesof(/datum/ruin_event))
		var/datum/ruin_event/instanced = new ruin_event()
		runnable_events[instanced] = instanced.probability

/datum/controller/subsystem/processing/orbits/proc/get_event()
	if(!event_probability)
		return null
	return pick_weight(runnable_events)

/datum/controller/subsystem/processing/orbits/proc/post_load_init()
	for(var/map_key in orbital_maps)
		var/datum/orbital_map/orbital_map = orbital_maps[map_key]
		orbital_map.post_setup()
	orbits_setup = TRUE
	//Create initial ruins
	for(var/i in 1 to initial_space_ruins)
		new /datum/orbital_object/z_linked/beacon/ruin/spaceruin()
	for(var/i in 1 to initial_objective_beacons)
		new /datum/orbital_object/z_linked/beacon/ruin()
	//Create asteroid belt
	for(var/i in 1 to initial_asteroids)
		new /datum/orbital_object/z_linked/beacon/ruin/asteroid()

/datum/controller/subsystem/processing/orbits/fire(resumed)
	if(resumed)
		. = ..()
		if(MC_TICK_CHECK)
			return
		//Update UIs
		for(var/datum/tgui/tgui as() in open_orbital_maps)
			tgui.send_update()
	//Check creating objectives / missions.
	if(next_objective_time < world.time && length(possible_objectives) < 6)
		create_objective()
		next_objective_time = world.time + rand(30 SECONDS, 5 MINUTES)
	//Check space ruin count
	if(ruin_levels < 2 && prob(5))
		new /datum/orbital_object/z_linked/beacon/ruin/spaceruin()
	//Check objective
	if(current_objective)
		if(current_objective.check_failed())
			QDEL_NULL(current_objective)
	//Process events
	for(var/datum/ruin_event/ruin_event as() in ruin_events)
		if(!ruin_event.update())
			ruin_events.Remove(ruin_event)
	//Do processing.
	if(!resumed)
		. = ..()
		if(MC_TICK_CHECK)
			return
		//Update UIs
		for(var/datum/tgui/tgui as() in open_orbital_maps)
			tgui.send_update()

/mob/dead/observer/verb/open_orbit_ui()
	set name = "View Orbits"
	set category = "Ghost"
	SSorbits.orbital_map_tgui.ui_interact(src)

/datum/controller/subsystem/processing/orbits/proc/create_objective()
	var/static/list/valid_objectives = list(
		/datum/orbital_objective/recover_blackbox = 3,
		/datum/orbital_objective/nuclear_bomb = 1,
		/datum/orbital_objective/assassination = 1,
		/datum/orbital_objective/artifact = 2,
		/datum/orbital_objective/vip_recovery = 1
	)
	var/chosen = pick_weight(valid_objectives)
	if(!chosen)
		return
	var/datum/orbital_objective/objective = new chosen()
	objective.generate_payout()
	possible_objectives += objective
	update_objective_computers()

/datum/controller/subsystem/processing/orbits/proc/assign_objective(objective_computer, datum/orbital_objective/objective)
	if(!possible_objectives.Find(objective))
		return "Selected objective is no longer available or has been claimed already."
	if(current_objective)
		return "An objective has already been selected and must be completed first."
	objective.on_assign(objective_computer)
	objective.generate_attached_beacon()
	current_objective = objective
	possible_objectives.Remove(objective)
	update_objective_computers()
	return "Objective selected, good luck."

/datum/controller/subsystem/processing/orbits/proc/update_objective_computers()
	for(var/obj/machinery/computer/objective/computer as() in GLOB.objective_computers)
		for(var/M in computer.viewing_mobs)
			computer.update_static_data(M)

/// parameter must accept 'get_virtual_z_level()' values
/datum/controller/subsystem/processing/orbits/proc/get_orbital_map_name_from_z(my_z)
	var/datum/orbital_object/O = assoc_z_levels["[my_z]"]
	return O?.name

/*
 * Returns the base data of what is required for
 * OrbitalMapSvg to function.
 *
 * This will display the base map, additional shuttle/weapons functionality
 * can be appended to the returned data list in ui_data.
 *
 * This exists to normalise the ui_data between different consoles that use the orbital
 * map interface and to prevent repeating code.
 */
/datum/controller/subsystem/processing/orbits/proc/get_orbital_map_base_data(
		//The map to generate the data from.
		datum/orbital_map/showing_map,
		//The reference of the user (REF(user))
		user_ref,
		//Can we see stealthed objects?
		see_stealthed = FALSE,
		//Our attached orbital object (Overrides stealth)
		datum/orbital_object/attached_orbital_object = null,
	)
	var/data = list()
	data["update_index"] = SSorbits.times_fired
	data["map_objects"] = list()
	//Fetch the active single instances
	//Get the objects
	for(var/zone in showing_map.collision_zone_bodies)
		for(var/datum/orbital_object/object as() in showing_map.collision_zone_bodies[zone])
			if(!object)
				continue
			//we can't see it, unless we are stealth too
			if(attached_orbital_object)
				if(object != attached_orbital_object && (object.stealth && !attached_orbital_object.stealth))
					continue
			else if(!see_stealthed && object.stealth)
				continue
			//Transmit map data about non single-instanced objects.
			data["map_objects"] += list(list(
				"id" = object.unique_id,
				"name" = object.name,
				"position_x" = object.position.x,
				"position_y" = object.position.y,
				"velocity_x" = object.velocity.x,
				"velocity_y" = object.velocity.y,
				"radius" = object.radius,
				"render_mode" = object.render_mode,
				"priority" = object.priority,
				"vel_mult" = object.velocity_multiplier,
			))
	return data
