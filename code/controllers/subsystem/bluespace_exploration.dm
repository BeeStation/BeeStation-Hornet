#define CLEAR_TURF_PROCESSING_TIME 600

SUBSYSTEM_DEF(bluespace_exploration)
	name = "Bluespace Exploration"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_BS_EXPLORATION

	var/datum/space_level/reserved_bs_level
	var/list/ruin_templates = list()
	var/obj/docking_port/stationary/away_mission_port

//====================================
//These procs are very expensive
//Thus have a lot of check ticks.
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

/datum/controller/subsystem/bluespace_exploration/proc/wipe_z_level(data_holder)
	var/list/turfs = get_area_turfs(/area, reserved_bs_level.z_value, TRUE)
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

	var/i = 0
	continue_wipe(data_holder, divided_turfs, i)

/datum/controller/subsystem/bluespace_exploration/proc/continue_wipe(data_holder, list/divided_turfs, process_num, spawn_ruins = FALSE)
	var/list_element = (process_num % (CLEAR_TURF_PROCESSING_TIME/2)) + 1
	switch(process_num)
		if(0 to (CLEAR_TURF_PROCESSING_TIME/2)-1)
			clear_turf_atoms(divided_turfs[list_element])
		if((CLEAR_TURF_PROCESSING_TIME/2) to (CLEAR_TURF_PROCESSING_TIME-1))
			reset_turfs(divided_turfs[list_element])
		else
			var/datum/data_holder/bluespace_exploration/data = data_holder
			if(data.spawn_ruins)
				addtimer(CALLBACK(src, .proc/place_ruins, data_holder), 0)
			return
	addtimer(CALLBACK(src, .proc/continue_wipe, data_holder, divided_turfs, process_num + 1, spawn_ruins), 1, TIMER_UNIQUE)

/datum/controller/subsystem/bluespace_exploration/proc/clear_turf_atoms(list/turfs)
	//Clear atoms
	for(var/turf/T in turfs)
		// Remove all atoms except observers
		var/static/list/ignored_atoms = typecacheof(list(/mob/dead))
		var/list/allowed_contents = typecache_filter_list_reverse(T.GetAllContents(), ignored_atoms)
		allowed_contents -= T
		for(var/i in 1 to allowed_contents.len)
			var/thing = allowed_contents[i]
			qdel(thing, force=TRUE)
		//ehhh this should be done on it's own
		SSair.remove_from_active(T)

/datum/controller/subsystem/bluespace_exploration/proc/reset_turfs(list/turfs)
	var/list/new_turfs = list()
	for(var/turf/T in turfs)
		var/turf/newT
		if(istype(T, /turf/open/space))
			newT = T
		else
			newT = T.ChangeTurf(/turf/open/space)
		SSair.add_to_active(newT,1)
		new_turfs += newT
	return new_turfs

//===================SPAWNING RUINS PROCS===================

//TODO: Make this slower and spread over a time limit
/datum/controller/subsystem/bluespace_exploration/proc/place_ruins(data_holder)
	message_admins("ruin spawnings started")
	//(Temp) get randomly created level
	var/datum/exploration_location/location = new()
	location.sector_features = list(FEATURE_ASTEROIDS)
	//Get Valid Ruins
	var/list/valid_ruins = list()
	for(var/template_name in ruin_templates)
		var/datum/map_template/ruin/exploration/ruin/R = ruin_templates[template_name]
		var/valid = TRUE
		for(var/feature in R.feature_type)
			if(!(feature in location.sector_features))
				valid = FALSE
				break
		if(!valid)
			continue
		valid_ruins += R
	//Generate Ruins
	var/cost_limit = 20
	while(cost_limit > 0)
		if(!LAZYLEN(valid_ruins))
			break
		var/list/selectable_ruins = list()
		for(var/datum/map_template/ruin/exploration/ruin/R in valid_ruins)
			if(R.cost < cost_limit)
				selectable_ruins += R
		if(!LAZYLEN(selectable_ruins))
			log_game("Ran out of selectable ruins, with [cost_limit] spawn points left.")
			break
		//Pick a ruin
		var/datum/map_template/ruin/exploration/ruin/selected_ruin = pick(selectable_ruins)
		if(!selected_ruin)
			log_runtime("Warning, invalid ruin")
			continue
		if(selected_ruin.limited)
			valid_ruins -= selected_ruin
		//Subtract Cost
		cost_limit -= selected_ruin.cost
		selected_ruin.try_to_place(reserved_bs_level.z_value, /area/space)
		message_admins("Spawning ruin [selected_ruin.name]")
		CHECK_TICK
	message_admins("ruin spawnings done")
	addtimer(CALLBACK(src, .proc/on_generation_complete, data_holder), 0)

/datum/controller/subsystem/bluespace_exploration/proc/on_generation_complete(data_holder)
	message_admins("generating shuttle dock")
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
		away_mission_port.forceMove(locate(rand(10, world.maxx - 10), rand(10, world.maxx - 10), reserved_bs_level.z_value))
		//Check if blocked
		var/blocked = FALSE
		for(var/turf/closed/T in away_mission_port.return_turfs())
			blocked = TRUE
			break
		if(blocked)
			CHECK_TICK
			continue
		docking_failed = FALSE
	if(!docking_failed)
		shuttle.destination = away_mission_port
		message_admins("Docking successful, sending shuttle to location")
	else
		shuttle.destination = shuttle.previous
		message_admins("Docking failed, return shuttle to home")
	shuttle.setTimer(shuttle.ignitionTime)

/datum/controller/subsystem/bluespace_exploration/proc/generate_z_level(data_holder)
	wipe_z_level(data_holder, TRUE)

/datum/controller/subsystem/bluespace_exploration/proc/shuttle_translation(shuttle_id)
	if(!check_z_level())
		return FALSE
	var/obj/docking_port/mobile/shuttle = SSshuttle.getShuttle(shuttle_id)
	if(!shuttle)
		return FALSE
	if(away_mission_port && away_mission_port.get_docked())
		away_mission_port.delete_after = TRUE
		away_mission_port.id = null
		away_mission_port.name = "Old [away_mission_port.name]"
		away_mission_port = null
	//Send the shuttle to the transit level
	shuttle.destination = null
	shuttle.mode = SHUTTLE_IGNITING
	shuttle.setTimer(shuttle.ignitionTime)
	//Generate the z_level, sending the shuttle to it on completion
	var/datum/data_holder/bluespace_exploration/data_holder = new()
	data_holder.shuttle_id = shuttle_id
	data_holder.spawn_ruins = TRUE
	//Clear the z-level after the shuttle leaves
	addtimer(CALLBACK(src, .proc/generate_z_level, data_holder), shuttle.ignitionTime + 50, TIMER_UNIQUE)

//data holder for passing down the line
/datum/data_holder/bluespace_exploration
	var/shuttle_id
	var/spawn_ruins = FALSE
