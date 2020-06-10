#define CLEAR_TURF_PROCESSING_TIME 600

SUBSYSTEM_DEF(bluespace_exploration)
	name = "Bluespace Exploration"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_BS_EXPLORATION

	var/datum/space_level/reserved_bs_level
	var/list/ruin_templates = list()

//====================================
//These procs are ~~likely~~ (they just straight are) to be very expensive
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

/datum/controller/subsystem/bluespace_exploration/proc/wipe_z_level()
	var/list/turfs = get_area_turfs(/area, reserved_bs_level.z_value, TRUE)
	var/list/divided_turfs = list()
	var/section_process_time = CLEAR_TURF_PROCESSING_TIME / 2	//There are 3 processes, cleaing atoms, cleaing turfs and then reseting atmos

	//Divide the turfs into groups
	var/group_size = FLOOR((turfs.len / section_process_time) + 0.9999, 1)
	var/groups = FLOOR((turfs.len / group_size) + 0.9999, 1)
	var/list/current_group = list()
	for(var/i in 1 to turfs.len)
		var/turf/T = turfs[i]
		current_group += T
		if(i % group_size == 0)
			divided_turfs += list(current_group)
			current_group = list()
	divided_turfs += list(current_group)

	var/i = 0
	continue_wipe(divided_turfs, i)

	message_admins("[turfs.len] inside [groups] groups each with [group_size]")

/datum/controller/subsystem/bluespace_exploration/proc/continue_wipe(list/divided_turfs, process_num)
	var/list_element = (process_num % (CLEAR_TURF_PROCESSING_TIME/2)) + 1
	message_admins("group [process_num] processing")
	switch(process_num)
		if(0 to (CLEAR_TURF_PROCESSING_TIME/2)-1)
			clear_turf_atoms(divided_turfs[list_element])
		if((CLEAR_TURF_PROCESSING_TIME/2) to (CLEAR_TURF_PROCESSING_TIME-1))
			reset_turfs(divided_turfs[list_element])
		else
			message_admins("Wiping z-level completed")
			return
	addtimer(CALLBACK(src, .proc/continue_wipe, divided_turfs, process_num + 1), 1, TIMER_UNIQUE)

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

/datum/controller/subsystem/bluespace_exploration/proc/reset_turfs(list/turfs)
	var/list/new_turfs = list()
	for(var/turf/T in turfs)
		var/turf/newT
		SSair.remove_from_active(newT)
		if(istype(T, /turf/open/space))
			newT = T
		else
			newT = T.ChangeTurf(/turf/open/space)
		SSair.add_to_active(newT,1)
		new_turfs += newT
	return new_turfs

//===================SPAWNING RUINS PROCS===================

/datum/controller/subsystem/bluespace_exploration/proc/place_ruins()
	//(Temp) get randomly created level
	var/datum/exploration_location/location = new()
	location.sector_features = list(FEATURE_ASTEROIDS)
	//Get Valid Ruins
	var/list/valid_ruins = list()
	for(var/template_name in ruin_templates)
		var/datum/map_template/ruin/exploration/ruin/R = ruin_templates[template_name]
		if(R.feature_type in location.sector_features)
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
		//Pick a ruin
		var/datum/map_template/ruin/exploration/ruin/selected_ruin = pick(selectable_ruins)
		if(!selected_ruin)
			break
		if(selected_ruin.limited)
			valid_ruins -= selected_ruin
		//Subtract Cost
		cost_limit -= selected_ruin.cost
		selected_ruin.try_to_place(reserved_bs_level.z_value, /area/space)
		log_game("Spawning ruin [selected_ruin.name]")

/datum/controller/subsystem/bluespace_exploration/proc/generate_z_level(difficulty = 1)
	wipe_z_level()
	addtimer(CALLBACK(src, .proc/place_ruins), 0, TIMER_UNIQUE)

/datum/controller/subsystem/bluespace_exploration/proc/shuttle_translation(shuttle_id)
	if(!check_z_level())
		return FALSE
	var/obj/docking_port/mobile/shuttle = SSshuttle.getShuttle(shuttle_id)
	if(!shuttle)
		return FALSE
	//Send the shuttle to the transit level
	shuttle.destination = null
	shuttle.mode = SHUTTLE_IGNITING
	shuttle.setTimer(shuttle.ignitionTime)
	//Generate the z_level, sending the shuttle to it on completion
	generate_z_level()
