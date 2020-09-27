#define CLEAR_TURF_PROCESSING_TIME 600

SUBSYSTEM_DEF(bluespace_exploration)
	name = "Bluespace Exploration"
	wait = 1
	priority = FIRE_PRIORITY_EXPLORATION
	init_order = INIT_ORDER_BS_EXPLORATION

	var/generating = FALSE

	//Starmap generation
	var/datum/star_system/current_system = null
	var/list/star_systems = list()
	var/list/star_links = list()

	//Ruin generation
	var/datum/space_level/reserved_bs_level
	var/list/ruin_templates = list()
	var/obj/docking_port/stationary/away_mission_port

	//=====Factions=====
	// factions[datum] = new datum
	var/list/factions = list()

	//=====Ship Tracking=====
	var/list/spawnable_ships = list()
	//All ships that are able to use the random generation must be tracked
	var/list/tracked_ships = list()

	//=====Ship Processing Queue=====
	// ! Tracks a list of all the ships requesting transit
	// ! Key (string) - shuttle_id
	// ! Value (/datum/data_holder/bluespace_exploration) - generation settings
	var/list/ship_traffic_queue = list()	//The queue for generation is disguised as 'bluespace traffic control'

	//=====Z-Level Wiping=====
	//Are we currently processing a z-level wipe
	var/wiping_z_level = FALSE
	//The target z-level of the wipe
	var/target_z_level = 0
	//A list of all turfs on the z-leves divided into equal parts depending on how many ticks we have to wipe
	var/list/wiping_divided_turfs
	//The turf group we are currently wiping
	var/wipe_process_num  = 0
	//Data holder for turf wiping
	var/datum/data_holder/bluespace_exploration/wipe_data_holder
	//The queue for z-levels to wipe
	var/list/z_level_queue

/datum/controller/subsystem/bluespace_exploration/Initialize(start_timeofday)
	z_level_queue = list()
	. = ..()
	//Create factions
	for(var/faction_datum in subtypesof(/datum/faction))
		factions[faction_datum] = new faction_datum

/datum/controller/subsystem/bluespace_exploration/fire(resumed = 0)
	if(times_fired % 50 == 0)
		for(var/ship_key in tracked_ships)
			var/datum/ship_datum/SD = tracked_ships[ship_key]
			SD.update_ship()
			if(QDELETED(SD))
				tracked_ships -= ship_key
			CHECK_TICK
		//Keep doing this just in case
		initiate_queued_warp()
		CHECK_TICK
	if(!wiping_z_level && LAZYLEN(z_level_queue))
		wipe_z_level(z_level, text2num(z_level_queue[1]))
		CHECK_TICK
	if(wiping_z_level)
		continue_wipe(wipe_data_holder, wiping_divided_turfs, wipe_process_num)
		wipe_process_num += 1
		CHECK_TICK

//====================================
// Queue handling
//====================================

/datum/controller/subsystem/bluespace_exploration/proc/request_ship_transit_to(shuttle_id, datum/star_system/SS, datum/data_holder/bluespace_exploration/extra_data)
	if(!extra_data)
		extra_data = new /datum/data_holder/bluespace_exploration
	extra_data.target_star_system = SS
	request_ship_transit(shuttle_id, extra_data)

//Adds a shuttle to the transit queue, returns the ticks until we will launch.
/datum/controller/subsystem/bluespace_exploration/proc/request_ship_transit(shuttle_id, datum/data_holder/bluespace_exploration/extra_data)
	if(!shuttle_id)
		message_admins("Bluespace exploration error: ship transit requested with no shuttle_id, check runtimes")
		CRASH("Bluespace exploration error: ship transit requested with no shuttle_id, check runtimes")
	if(!extra_data)
		extra_data = new /datum/data_holder/bluespace_exploration
	extra_data.shuttle_id = shuttle_id
	ship_traffic_queue[shuttle_id] = extra_data

//Starts the next ship in the queue for warping
/datum/controller/subsystem/bluespace_exploration/proc/initiate_queued_warp()
	if(generating)
		return
	if(!LAZYLEN(ship_traffic_queue))
		return
	var/first_shuttle_id = ship_traffic_queue[1]
	shuttle_translation(first_shuttle_id, ship_traffic_queue[first_shuttle_id])
	ship_traffic_queue.Remove(first_shuttle_id)

//====================================
// Ship procs
//====================================

/datum/controller/subsystem/bluespace_exploration/proc/register_new_ship(shuttle_id, override_type = /datum/ship_datum, faction = /datum/faction/station)
	if(shuttle_id in tracked_ships)
		return tracked_ships[shuttle_id]
	var/datum/ship_datum/SD = override_type
	if(!istype(SD))
		SD = new override_type()
	SD.mobile_port_id = shuttle_id
	SD.ship_faction = new faction
	SD.update_ship()
	if(QDELETED(SD))
		return null
	tracked_ships[shuttle_id] = SD
	return SD

//====================================
//These procs are very expensive
//Bluespace Drives take a long time, so loading of the new z_levels
//can be slowly done in the back ground while in transit.
//However, it should be noted if the server is under high load,
//We still want new z_levels to be generated otherwise they will be
//locked in transit forever.
//====================================

//Checks the z-level to see if any mobs with minds will be left behind when jumping
//Returns TRUE if it is safe to warp away from (Mobs are on shuttle)
/datum/controller/subsystem/bluespace_exploration/proc/check_z_level()
	return TRUE

//===================CLEARING Z LEVEL PROCS===================
//These are done so that the spawning is spread evenly over 1 minute.
//This significantly reduces the potential lag.
//If the server is under heavy load, this will still get done in 1 minute, and shouldn't be too intensive.
//Under low load, this wont push the server to the tick limit, since it is spread out and done evenly.
//More time reliable at low and high tickrates than using CHECK_TICK

/datum/controller/subsystem/bluespace_exploration/proc/wipe_z_level(z_level, datum/data_holder/bluespace_exploration/data_holder)
	wiping_z_level = TRUE
	z_level_queue.Remove("[z_level]")
	var/list/turfs = get_area_turfs(/area, z_level, TRUE)
	var/list/divided_turfs = list()
	var/section_process_time = CLEAR_TURF_PROCESSING_TIME / 2	//There are 3 processes, cleaing atoms, cleaing turfs and then reseting atmos

	//Divide the turfs into groups
	var/group_size = FLOOR((turfs.len / section_process_time) + 0.9999, 1)
	var/list/current_group = list()
	for(var/i in 1 to turfs.len)
		var/turf/T = turfs[i]
		current_group += T
		if(i % group_size == 0)
			divided_turfs += list(current_group)
			current_group = list()
	divided_turfs += list(current_group)
	prep_wipe(data_holder, divided_turfs)

//Adds a z-level to the wipe queue for wiping
/datum/controller/subsystem/bluespace_exploration/proc/add_to_wipe_queue(z_level_num, datum/data_holder/bluespace_exploration/data_holder)
	if(z_level_queue["[z_level_num]"])
		return
	if(!data_holder)
		data_holder = new()
	z_level_queue["[z_level_num]"] = data_holder

/datum/controller/subsystem/bluespace_exploration/proc/prep_wipe(datum/data_holder/bluespace_exploration/data_holder, list/divided_turfs)
	wipe_data_holder = data_holder
	wiping_divided_turfs = divided_turfs
	wipe_process_num = 0

/datum/controller/subsystem/bluespace_exploration/proc/continue_wipe(datum/data_holder/bluespace_exploration/data_holder, list/divided_turfs, process_num)
	var/list_element = (process_num % (CLEAR_TURF_PROCESSING_TIME/2)) + 1
	switch(process_num)
		if(0 to (CLEAR_TURF_PROCESSING_TIME/2)-1)
			reset_turfs(divided_turfs[list_element])
		if((CLEAR_TURF_PROCESSING_TIME/2) to (CLEAR_TURF_PROCESSING_TIME-1))
			clear_turf_atoms(divided_turfs[list_element])
		else
			var/datum/data_holder/bluespace_exploration/data = data_holder
			if(data.spawn_ruins)
				addtimer(CALLBACK(src, .proc/place_ruins, data_holder), 0)
			wiping_z_level = FALSE	//Done :)
			return

/datum/controller/subsystem/bluespace_exploration/proc/clear_turf_atoms(list/turfs)
	//Clear atoms
	for(var/turf/T in turfs)
		SSair.remove_from_active(T)
		// Remove all atoms except abstract mobs
		var/static/list/ignored_atoms = typecacheof(list(/mob/dead, /mob/camera, /mob/dview))
		var/list/allowed_contents = typecache_filter_list_reverse(T.GetAllContents(), ignored_atoms)
		allowed_contents -= T
		for(var/i in 1 to allowed_contents.len)
			var/thing = allowed_contents[i]
			qdel(thing, force=TRUE)

/datum/controller/subsystem/bluespace_exploration/proc/reset_turfs(list/turfs)
	var/list/new_turfs = list()
	for(var/turf/T in turfs)
		var/turf/newT
		if(istype(T, /turf/open/space))
			newT = T
		else
			newT = T.ChangeTurf(/turf/open/space)
		new_turfs += newT
	return new_turfs

//===================SPAWNING RUINS PROCS===================

//TODO: Make this slower and spread over a time limit
/datum/controller/subsystem/bluespace_exploration/proc/place_ruins(datum/data_holder/bluespace_exploration/data_holder)
	//(Temp) get randomly created level
	var/datum/exploration_location/location = new()
	location.sector_features = list(FEATURE_ASTEROIDS)
	//===Generate bluespace ruins===
	var/list/bluespace_valid_ruins = list()
	for(var/template_name in ruin_templates)
		var/datum/map_template/ruin/exploration/ruin/R = ruin_templates[template_name]
		var/valid = TRUE
		for(var/feature in R.feature_type)
			if(!(feature in location.sector_features))
				valid = FALSE
				break
		if(!valid)
			continue
		bluespace_valid_ruins += R
	//===Calculate standard ruins
	var/datum/star_system/target_level = data_holder.target_star_system
	var/list/standard_valid_ruins = list()
	for(var/template_name in SSmapping.space_ruins_templates)
		var/datum/map_template/ruin/space/R = SSmapping.space_ruins_templates[template_name]
		standard_valid_ruins += R
	//Generate Ruins
	var/cost_limit = 20
	while(cost_limit > 0)
		if(!LAZYLEN(bluespace_valid_ruins))
			break
		var/list/selectable_ruins = list()
		//TODO: Ruin weighting based on difficulty
		//TODO: Bluespace ruins
		if(target_level?.bluespace_ruins)
			for(var/datum/map_template/ruin/exploration/ruin/R in bluespace_valid_ruins)
				if(R.cost < cost_limit)
					selectable_ruins += R
		else
			for(var/datum/map_template/ruin/space/R in standard_valid_ruins)
				if(R.cost < cost_limit)
					selectable_ruins += R
		if(!LAZYLEN(selectable_ruins))
			log_game("Ran out of selectable ruins, with [cost_limit] spawn points left.")
			break
		//Pick a ruin
		var/datum/map_template/ruin/selected_ruin = pick(selectable_ruins)
		if(!selected_ruin)
			log_runtime("Warning, invalid ruin")
			continue
		if(target_level?.bluespace_ruins)
			var/datum/map_template/ruin/exploration/ruin/BS_Ruin = selected_ruin
			if(BS_Ruin.limited)
				bluespace_valid_ruins -= BS_Ruin
		else
			var/datum/map_template/ruin/space/Space_ruin = selected_ruin
			if(!Space_ruin.allow_duplicates)
				standard_valid_ruins -= Space_ruin
		//Subtract Cost
		selected_ruin.try_to_place(reserved_bs_level.z_value, /area/space)
		cost_limit -= selected_ruin.cost
		CHECK_TICK
	//=== Spawn Hostile Ships ===
	var/max_ships = 5
	var/threat_left = target_level.calculated_threat
	while(threat_left > 0 && max_ships > 0)
		//Pick a ship to spawn
		var/list/valid_ships = list()
		for(var/ship_name in spawnable_ships)
			var/datum/map_template/shuttle/ship/spawnable_ship = spawnable_ships[ship_name]
			var/datum/faction/system_faction = target_level.system_alignment
			if(!spawnable_ship.can_place())
				continue
			//Is the ship of the faction of the system?
			//10% chance for ships to spawn anyway
			if(!is_type_in_list(spawnable_ship.faction, typesof(system_faction.type)) && prob(90))
				continue
			if(spawnable_ship.difficulty < threat_left)
				valid_ships += ship_name
		if(!LAZYLEN(valid_ships))
			break
		spawn_and_register_shuttle(spawnable_ships[pick(valid_ships)])
		max_ships --
	addtimer(CALLBACK(src, .proc/on_generation_complete, data_holder), 0)

/datum/controller/subsystem/bluespace_exploration/proc/on_generation_complete(datum/data_holder/bluespace_exploration/data_holder)
	var/datum/data_holder/bluespace_exploration/data = data_holder
	var/obj/docking_port/mobile/shuttle = SSshuttle.getShuttle(data.shuttle_id)
	//Place a dock somewhere in the new place
	var/sanity = PLACEMENT_TRIES
	var/docking_failed = TRUE
	while(sanity > 0)
		sanity --
		//Try to find a place for the docking port
		if(!away_mission_port)
			away_mission_port = new()
			away_mission_port.name = "Bluespace Drive Port"
			away_mission_port.id = "exploration_away"
			away_mission_port.height = shuttle.height
			away_mission_port.width = shuttle.width
			away_mission_port.dheight = shuttle.dheight
			away_mission_port.dwidth = shuttle.dwidth
		var/max_size = max(away_mission_port.width, away_mission_port.height)
		away_mission_port.forceMove(locate(rand(max_size, world.maxx - max_size), rand(max_size, world.maxx - max_size), reserved_bs_level.z_value))
		//Check if blocked
		var/blocked = FALSE
		for(var/turf/T in away_mission_port.return_turfs())
			if(T.density)
				blocked = TRUE
				break
		if(blocked)
			CHECK_TICK
			continue
		docking_failed = FALSE
	if(!docking_failed)
		shuttle.destination = away_mission_port
	else
		shuttle.destination = shuttle.previous
		message_admins("Bluespace exploration docking failed, returning shuttle to home (Sanity check failed to place shuttle)")
		log_runtime("Bluespace exploration docking failed, returning shuttle to home (Sanity check failed to place shuttle)")
	shuttle.setTimer(shuttle.ignitionTime)
	current_system = data_holder.target_star_system
	generating = FALSE

/datum/controller/subsystem/bluespace_exploration/proc/generate_z_level(datum/data_holder/bluespace_exploration/data_holder)
	add_to_wipe_queue(reserved_bs_level.z_value, data_holder)

/datum/controller/subsystem/bluespace_exploration/proc/shuttle_translation(shuttle_id, datum/data_holder/bluespace_exploration/data_holder)
	if(!check_z_level())
		return FALSE
	var/obj/docking_port/mobile/shuttle = SSshuttle.getShuttle(shuttle_id)
	if(!shuttle)
		return FALSE
	if(generating)
		return FALSE
	generating = TRUE
	if(away_mission_port && away_mission_port.get_docked())
		away_mission_port.delete_after = TRUE
		away_mission_port.id = null
		away_mission_port.name = "Old [away_mission_port.name]"
		away_mission_port = null
	//Send the shuttle to the transit level
	shuttle.destination = null
	shuttle.mode = SHUTTLE_IGNITING
	shuttle.setTimer(shuttle.ignitionTime)
	//Clear the z-level after the shuttle leaves
	addtimer(CALLBACK(src, .proc/generate_z_level, data_holder), shuttle.ignitionTime + 50, TIMER_UNIQUE)

//====================================
// Factions
//====================================

/datum/controller/subsystem/bluespace_exploration/proc/get_faction(faction_datum)
	return factions[faction_datum]

//====================================
// Starsystem Grabbing
//====================================

//====================================
// Utility
//====================================

/datum/controller/subsystem/bluespace_exploration/proc/get_bse_level_data()
	return current_system.system_data


//====================================
// Data holder - Simplifys what gets sent as paramaters so we don't have tons of variables some of which won't be used in that proc
//====================================

/datum/data_holder/bluespace_exploration
	var/shuttle_id
	var/spawn_ruins = TRUE
	var/ruin_spawn_type = BLUESPACE_DRIVE_BSLEVEL
	var/target_star_system
