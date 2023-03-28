PROCESSING_SUBSYSTEM_DEF(orbits)
	name = "Orbits"
	flags = SS_KEEP_TIMING
	init_order = INIT_ORDER_ORBITS
	priority = FIRE_PRIORITY_ORBITS
	wait = ORBITAL_UPDATE_RATE

	//The primary orbital map.
	var/list/orbital_maps = list()

	var/datum/orbital_map_tgui/orbital_map_tgui = new()

	// Space ruins will be non-persistent
	var/initial_space_ruins = 8
	// Scarce resources
	var/initial_asteroids = 3

	var/orbits_setup = FALSE

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

	//Research disks
	var/list/research_disks = list()

	var/list/datum/tgui/open_orbital_maps = list()

	//The station
	var/datum/orbital_object/station_instance

	//Ruin level count
	var/ruin_levels = 0

	//Assoc shuttle data
	//Key: port_id
	//Value: The shuttle data
	var/list/assoc_shuttle_data = list()

	//List of distress beacons by Z-Level
	var/list/assoc_distress_beacons = list()

	//shuttle weapons
	var/list/shuttle_weapons = list()

	// Singleton Faction Instances
	var/list/lead_faction_instances = list()

	// Dock allocations
	var/list/dock_allocations = list()

/datum/controller/subsystem/processing/orbits/Initialize(start_timeofday)
	. = ..()
	setup_event_list()
	//Create the main orbital map.
	orbital_maps[PRIMARY_ORBITAL_MAP] = new /datum/orbital_map()
	// Create the lead faction instances
	for (var/subtype in subtypesof(/datum/faction))
		lead_faction_instances[subtype] = new subtype(TRUE)

/datum/controller/subsystem/processing/orbits/Recover()
	orbital_maps |= SSorbits.orbital_maps
	ruin_events |= SSorbits.ruin_events
	assoc_shuttles |= SSorbits.assoc_shuttles
	interdicted_shuttles |= SSorbits.interdicted_shuttles
	research_disks |= SSorbits.research_disks
	if(!islist(runnable_events)) runnable_events = list()
	runnable_events |= SSorbits.runnable_events

	station_instance = SSorbits.station_instance
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
	return pickweight(runnable_events)

/datum/controller/subsystem/processing/orbits/proc/post_load_init()
	for(var/map_key in orbital_maps)
		var/datum/orbital_map/orbital_map = orbital_maps[map_key]
		orbital_map.post_setup()
	orbits_setup = TRUE
	//Create initial ruins
	for(var/i in 1 to initial_space_ruins)
		new /datum/orbital_object/z_linked/beacon/spaceruin()
	//Create asteroid belt
	for(var/i in 1 to initial_asteroids)
		if (prob(15))
			new /datum/orbital_object/z_linked/beacon/asteroid/crilium()
		else
			new /datum/orbital_object/z_linked/beacon/asteroid()

/datum/controller/subsystem/processing/orbits/fire(resumed)
	if(resumed)
		. = ..()
		if(MC_TICK_CHECK)
			return
		//Update UIs
		for(var/datum/tgui/tgui as() in open_orbital_maps)
			tgui.send_update()
	//Check space ruin count
	if(ruin_levels < 2 && prob(5))
		new /datum/orbital_object/z_linked/beacon/spaceruin()
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

//====================================
// User Interfaces
//====================================

/mob/dead/observer/verb/open_orbit_ui()
	set name = "View Orbits"
	set category = "Ghost"
	SSorbits.orbital_map_tgui.ui_interact(src)

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
		//Our attached data
		datum/shuttle_data/attached_data = null
	)
	var/data = list()
	data["update_index"] = SSorbits.times_fired
	data["map_objects"] = list()
	//Locate shuttle data if we have one
	data["detection_range"] = attached_data?.detection_range
	//Fetch the active single instances
	//Get the objects
	for(var/datum/orbital_object/object as() in showing_map.get_all_bodies())
		if(!object)
			continue
		//we can't see it, unless we are stealth too
		if(!see_stealthed && object.is_stealth())
			continue
		//Check visibility
		var/distress = object.is_distress()
		if(attached_orbital_object && !distress)
			var/max_vis_distance = max(attached_data?.detection_range, object.signal_range)
			//Quick Distance Check
			if(attached_orbital_object.position.GetX() > object.position.GetX() + max_vis_distance\
				|| attached_orbital_object.position.GetX() < object.position.GetX() - max_vis_distance\
				|| attached_orbital_object.position.GetY() > object.position.GetY() + max_vis_distance\
				|| attached_orbital_object.position.GetY() < object.position.GetY() - max_vis_distance)
				continue
			//Refined Distance Check
			if(attached_orbital_object.position.DistanceTo(object.position) > max_vis_distance)
				continue
		//Transmit map data about non single-instanced objects.
		data["map_objects"] += list(list(
			"id" = object.unique_id,
			"name" = object.get_name(),
			"position_x" = object.position.GetX(),
			"position_y" = object.position.GetY(),
			"velocity_x" = object.velocity.GetX(),
			"velocity_y" = object.velocity.GetY(),
			"radius" = object.radius,
			"render_mode" = object.render_mode,
			"priority" = object.priority,
			"distress" = distress,
			"vel_mult" = object.velocity_multiplier,
		))
	return data

//====================================
// Shuttle Data
//====================================

/datum/controller/subsystem/processing/orbits/proc/update_shuttle_name(port_id, name)
	var/obj/docking_port/mobile/port = SSshuttle.getShuttle(port_id)
	port.name = name
	var/datum/shuttle_data/shuttle_data = get_shuttle_data(port_id)
	shuttle_data.shuttle_name = name

/datum/controller/subsystem/processing/orbits/proc/get_shuttle_data(port_id)
	RETURN_TYPE(/datum/shuttle_data)
	return assoc_shuttle_data[port_id]

/datum/controller/subsystem/processing/orbits/proc/register_shuttle(port_id)
	var/datum/shuttle_data/new_shuttle = new(port_id)
	assoc_shuttle_data[port_id] = new_shuttle

/datum/controller/subsystem/processing/orbits/proc/remove_shuttle(port_id)
	var/datum/shuttle_data/shuttle = get_shuttle_data(port_id)
	assoc_shuttle_data -= port_id
	qdel(shuttle)

//====================================
// Factions
//====================================

/datum/controller/subsystem/processing/orbits/proc/get_lead_faction(faction_type)
	return lead_faction_instances[faction_type]

//====================================
// Other
//====================================

/datum/controller/subsystem/processing/orbits/proc/get_associated_level(turf/place)
	if (SSorbits.assoc_z_levels["[place.get_virtual_z_level()]"])
		return SSorbits.assoc_z_levels["[place.get_virtual_z_level()]"]
	var/area/shuttle/location = place.loc
	if (istype(location) && location.mobile_port)
		return SSorbits.assoc_shuttles[location.mobile_port.id]
	return null

/datum/controller/subsystem/processing/orbits/proc/get_allocation(mobile_id)
	return dock_allocations[mobile_id]
