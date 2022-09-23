PROCESSING_SUBSYSTEM_DEF(orbits)
	name = "Orbits"
	flags = SS_KEEP_TIMING
	init_order = INIT_ORDER_ORBITS
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

	var/list/datum/orbital_objective/completed_objectives = list()

	var/list/datum/ruin_event/ruin_events = list()

	var/list/runnable_events

	var/event_probability = 30

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

	//A list of all active map hazards
	var/list/datum/orbital_object/hazard/active_hazards = list()

	//Assoc shuttle data
	//Key: port_id
	//Value: The shuttle data
	var/list/assoc_shuttle_data = list()

	//List of distress beacons by Z-Level
	var/list/assoc_distress_beacons = list()

	//Ruin level count
	var/ruin_levels = 0

	//shuttle weapons
	var/list/shuttle_weapons = list()

	//=====Communications=====
	var/list/communication_managers = list()

	//=====Factions=====
	// factions[datum] = new datum
	var/list/factions

	//List of hostage spawn points
	var/list/obj/effect/hostage_spawns = list()

	//Binary list of rewards
	var/list/rewards = list()

/datum/controller/subsystem/processing/orbits/Initialize(start_timeofday)
	. = ..()
	setup_event_list()
	//Create the main orbital map.
	orbital_maps[PRIMARY_ORBITAL_MAP] = new /datum/orbital_map()
	//Create factions (These ones are static, although each ship has its own)
	factions = list()
	for(var/faction_datum in subtypesof(/datum/faction))
		factions[faction_datum] = new faction_datum

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
	if(next_objective_time < world.time)
		if(length(possible_objectives) >= 6)
			//Take and delete the first objective
			var/first = possible_objectives[1]
			possible_objectives.Remove(first)
			qdel(first)
		create_objective()
		next_objective_time = world.time + rand(30 SECONDS, 5 MINUTES)
	//Check space ruin count
	if(ruin_levels < 2 && prob(5))
		new /datum/orbital_object/z_linked/beacon/ruin/spaceruin()
	//Check objective
	if(current_objective)
		if(current_objective.check_failed())
			priority_announce("Central Command priority objective failed.", "Central Command Report", SSstation.announcer.get_rand_report_sound())
			QDEL_NULL(current_objective)
	//Process hazards
	process_hazards()
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
// Events
//====================================

/datum/controller/subsystem/processing/orbits/proc/setup_event_list()
	runnable_events = list()
	for(var/ruin_event in subtypesof(/datum/ruin_event))
		var/datum/ruin_event/instanced = new ruin_event()
		runnable_events[instanced] = instanced.probability

/datum/controller/subsystem/processing/orbits/proc/get_event()
	if(!event_probability)
		return null
	return pickweight(runnable_events)

//====================================
// Hazards
//====================================

/datum/controller/subsystem/processing/orbits/proc/process_hazards()
	var/hazard_removal_chance = length(active_hazards) * 0.2
	var/hazard_spawn_chance = 2 / (length(active_hazards) + 1)
	if(length(active_hazards) && prob(hazard_removal_chance))
		var/picked = pick(active_hazards)
		qdel(picked)
	if(prob(hazard_spawn_chance))
		create_hazard()

/datum/controller/subsystem/processing/orbits/proc/create_hazard()
	var/selected_type = pickweight(list(
		/datum/orbital_object/hazard/ion_storm = 3,
		/datum/orbital_object/hazard/gravity_storm = 3,
		/datum/orbital_object/hazard/vortex = 1
	))
	var/datum/orbital_object/created = new selected_type()
	var/datum/orbital_map/main = orbital_maps[PRIMARY_ORBITAL_MAP]
	var/hazard_distance = rand(2000, 7000)
	var/maximum_radius = hazard_distance / 3
	created.radius = maximum_radius
	created.set_orbitting_around_body(main.center, hazard_distance, TRUE)
	created.velocity.Set(0, 0)

//====================================
// Objectives
//====================================

/datum/controller/subsystem/processing/orbits/proc/create_objective()
	var/static/list/valid_objectives
	if(!islist(valid_objectives))
		valid_objectives = list()
		for(var/datum/orbital_objective/objective as() in subtypesof(/datum/orbital_objective))
			if(!initial(objective.weight))
				continue
			valid_objectives[objective] = initial(objective.weight)
	if(!length(possible_objectives))
		priority_announce("Priority station objective received - Details transmitted to all available objective consoles. \
			[GLOB.station_name] will have funds distributed upon objective completion.", "Central Command Report", SSstation.announcer.get_rand_report_sound())
	var/chosen = pickweight(valid_objectives)
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
	objective.announce()
	current_objective = objective
	possible_objectives.Remove(objective)
	update_objective_computers()
	return "Objective selected, good luck."

//====================================
// User Interfaces
//====================================

/datum/controller/subsystem/processing/orbits/proc/update_objective_computers()
	for(var/obj/machinery/computer/objective/computer as() in GLOB.objective_computers)
		for(var/M in computer.viewing_mobs)
			computer.update_static_data(M)

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
		if(attached_orbital_object)
			if(object != attached_orbital_object && (object.stealth && !attached_orbital_object.stealth))
				continue
		else if(!see_stealthed && object.stealth)
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
			"name" = object.name,
			"position_x" = object.position.GetX(),
			"position_y" = object.position.GetY(),
			"velocity_x" = object.velocity.GetX(),
			"velocity_y" = object.velocity.GetY(),
			"radius" = object.radius,
			"render_mode" = object.render_mode,
			"priority" = object.priority,
			"distress" = distress,
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

/datum/controller/subsystem/processing/orbits/proc/register_shuttle(port_id, ship_faction)
	var/datum/shuttle_data/new_shuttle = new(port_id, ship_faction)
	assoc_shuttle_data[port_id] = new_shuttle

/datum/controller/subsystem/processing/orbits/proc/remove_shuttle(port_id)
	var/datum/shuttle_data/shuttle = get_shuttle_data(port_id)
	assoc_shuttle_data -= port_id
	qdel(shuttle)

//====================================
// Factions
//====================================

/datum/controller/subsystem/processing/orbits/proc/get_faction(faction_datum)
	return factions[faction_datum]

/datum/controller/subsystem/processing/orbits/proc/after_ship_attacked(datum/shuttle_data/attacker, datum/shuttle_data/victim)
	var/datum/faction/attacker_faction = attacker.faction
	var/datum/faction/victim_faction = victim.faction
	//If the victime doesn't consider the attacker to be hostile, then the attacker ship will be marked as hostile to the victim's faction
	if(check_faction_alignment(victim_faction, attacker_faction) != FACTION_STATUS_HOSTILE)
		attacker.rogue_factions |= victim_faction.type
		log_shuttle("[attacker.shuttle_name] ([attacker_faction.name]) fired upon neutral/friendly ship [victim.shuttle_name] ([victim_faction.name]), and was declared hostile to that faction")
	//If the victim is an NPC, trigger them to become hostile
	if (istype(victim.ai_pilot, /datum/shuttle_ai_pilot/npc))
		//Kill...
		var/datum/shuttle_ai_pilot/npc/npc_ship = victim.ai_pilot
		npc_ship.hostile = TRUE

//====================================
// Ship Spawning
//====================================

/datum/controller/subsystem/processing/orbits/proc/spawn_ship(datum/map_template/shuttle/supercruise/selected_ship, ship_faction, ship_ai)
	var/datum/turf_reservation/preview_reservation = SSmapping.RequestBlockReservation(selected_ship.width, selected_ship.height, SSmapping.transit.z_value, /datum/turf_reservation/transit)
	if(!preview_reservation)
		CRASH("failed to reserve an area for shuttle template loading")
	var/turf/BL = TURF_FROM_COORDS_LIST(preview_reservation.bottom_left_coords)

	//Setup the docking port
	var/obj/docking_port/mobile/M = selected_ship.place_port(BL, FALSE, TRUE, rand(-6000, 6000), rand(-6000, 6000))

	//Give the ship some AI
	var/datum/shuttle_data/located_shuttle = SSorbits.get_shuttle_data(M.id)
	located_shuttle.faction = ship_faction
	located_shuttle.set_pilot(ship_ai)

	return M

//====================================
// Reward Items
//====================================

///Picks an item that approximately matches the said value.
///Random variance will allow for some randomness, so it won't always return the same items.
/datum/controller/subsystem/processing/orbits/proc/get_reward_item(approximate_value, random_variance = 1000)
	//Collect the 5 closest
	var/list/located_items = list()
	for(var/item in rewards)
		var/amount = rewards[item] + rand(-random_variance, random_variance)
		//Directly insert
		if(length(located_items) < 5)
			located_items[item] = amount
			continue
		var/diff = abs(approximate_value - amount)
		//Check if its closer than any of the located items
		for(var/existing_item in located_items)
			var/existing_amount = located_items[existing_item] + rand(-random_variance, random_variance)
			var/existing_diff = abs(approximate_value - existing_amount)
			if(diff < existing_diff)
				located_items -= existing_item
				located_items[item] = amount
				break
	return pick(located_items)

//====================================
// Communications
//====================================

/// Register a communication manager
/datum/controller/subsystem/processing/orbits/proc/register_communication_manager(datum/orbital_comms_manager/comms)
	communication_managers[comms.messenger_id] = comms

//====================================
// Captured Crew
//====================================

///Creates a hostage ship with the killed mobs as hostages
///Will chase after crewed ships in the sector
/datum/controller/subsystem/processing/orbits/proc/create_hostage_ship(list/hostages, iteration = 0)

	var/to_respawn = hostages.Copy()
	//Locate any existing spawns
	if(!length(hostage_spawns))
		//Spawn a hostage shuttle
		var/datum/map_template/shuttle/supercruise/shuttle_template = SSmapping.shuttle_templates["encounter_syndicate_prisoner_transport"]
		var/obj/docking_port/mobile/created_ship = spawn_ship(shuttle_template, new /datum/faction/pirates(), new /datum/shuttle_ai_pilot/npc/hostile())
		//Tell admins
		message_admins("As a result of unrecovered bodies in space, [length(hostages)] mobs were taken hostage aboard a pirate ship at [ADMIN_COORDJMP(created_ship)].")
		log_shuttle("A hostage ship was created with [length(hostages)] mobs taken hostage.")
		//Grant sentience to the ship's crew
		for(var/area/A in created_ship.shuttle_areas)
			for(var/mob/living/simple_animal/ship_mob in A)
				ship_mob.set_playable()
	//Oof
	if(!length(hostage_spawns))
		return
	//Spawn the hostages
	while(length(to_respawn) && length(hostage_spawns))
		var/mob/living/L = pick_n_take(to_respawn)
		var/obj/effect/picked_spawn = pick(hostage_spawns)
		//Move the mob
		L.forceMove(picked_spawn.loc)
		L.log_message("was taken hostage on board a pirate ship.", LOG_ATTACK)
		if(L.mind)
			ADD_TRAIT(L.mind, MIND_TRAIT_OBJECTIVE_DEAD, HOSTAGE_REVIVED_TRAIT)
		log_game("[key_name(L)] was taken hostage on a pirate ship.")
		log_shuttle("[key_name(L)] was taken hostage on a pirate ship.")
		//Transfer all of their items to a nearby simple mob's location
		var/area/A = get_area(picked_spawn)
		var/obj/effect/hostage_loot_point/item_point = locate() in A
		if(item_point)
			for(var/obj/item/I in L)
				if(L.dropItemToGround(I, TRUE))
					I.forceMove(item_point.loc)
		//Equip prisoner outfit
		var/datum/outfit/hostage/hostage_outfit = new()
		hostage_outfit.equip(L)
		//Delete the spawn
		qdel(picked_spawn)
		//Cannot be revived in this state
		if (HAS_TRAIT(L, TRAIT_BADDNA) || L.ishellbound())
			continue
		//Revive the mob
		L.revive(TRUE)
		//Grab the ghost
		L.grab_ghost()
		//Message
		to_chat(L, "<span class='userdanger'>You have been captured and taken hostage!</span>")
		var/list/picked = splittext(pick(strings(EXPLORATION_FLAVOUR, "hostage")), "\n")
		for(var/message in picked)
			to_chat(L, "<span class='danger'>[message]</span>")
	//If we still have hostages left
	if(length(to_respawn) && iteration < 4)
		create_hostage_ship(to_respawn, iteration + 1)
