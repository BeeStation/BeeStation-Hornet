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

	var/list/datum/ruin_event/ruin_events = list()

	var/list/runnable_events

	var/event_probability = 60

	//key = port_id
	//value = orbital shuttle object
	var/list/assoc_shuttles = list()

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

	//DMM files of shuttle ruins
	var/shuttle_ruin_list

/datum/controller/subsystem/processing/orbits/Initialize(start_timeofday)
	. = ..()
	setup_event_list()
	//Create the main orbital map.
	orbital_maps[PRIMARY_ORBITAL_MAP] = new /datum/orbital_map()
	//Fetch shuttle ruins
	shuttle_ruin_list = flist(CONFIG_GET(string/shuttle_ruin_filepath))
	//Create abandoned signal ruins
	if(length(shuttle_ruin_list))
		for(var/i in 1 to rand(1, min(length(shuttle_ruin_list), 4)))
			new /datum/orbital_object/z_linked/beacon/ruin/abandoned_shuttle()

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
			priority_announce("Central Command priority objective failed.", "Central Command Report", SSstation.announcer.get_rand_report_sound())
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
		/datum/orbital_objective/artifact = 1,
		/datum/orbital_objective/vip_recovery = 1
	)
	if(!length(possible_objectives))
		priority_announce("Priority station objective recieved - Details transmitted to all available objective consoles. \
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
	objective.generate_attached_beacon()
	objective.announce()
	current_objective = objective
	possible_objectives.Remove(objective)
	update_objective_computers()
	return "Objective selected, good luck."

/datum/controller/subsystem/processing/orbits/proc/update_objective_computers()
	for(var/obj/machinery/computer/objective/computer as() in GLOB.objective_computers)
		for(var/M in computer.viewing_mobs)
			computer.update_static_data(M)

//Saves custom shuttles
/datum/controller/subsystem/processing/orbits/proc/save_custom_shuttles()

	if(!CONFIG_GET(flag/save_shuttle_ruins))
		message_admins("Saving shuttles skipped, it is disabled in the config!")
		return

	//Calculate saved shuttle filesize
	var/shuttle_filepath = CONFIG_GET(string/shuttle_ruin_filepath)

	//Save shuttle
	message_admins("SSORBITS: Saving custom shuttle ruins...")

	var/list/old_files = list()
	var/current_size = 0

	//Find the current filesize saved
	if(fexists(shuttle_filepath))
		var/list/files = flist(shuttle_filepath)
		//Calculate length of files
		for(var/f in files)
			var/fullF = "[shuttle_filepath][f]"
			var/filelength = length(file(fullF))
			old_files += fullF
			current_size += filelength
		message_admins("SSORBITS: Located [length(files)] saved shuttles, with total filesize of [current_size] bytes!")
	else
		message_admins("SSORBITS: No custom shuttle files currently exist on the server!")

	var/custom_shuttle_count = 0
	var/shuttles_saved = 0

	var/space_required = 0

	var/space_saved = 0
	var/shuttles_deleted = 0

	//Find shuttles which we want to save
	for(var/obj/docking_port/mobile/M in SSshuttle.mobile)
		//Detect real custom shuttles
		var/turf/T = get_turf(M)
		if(!istype(T.loc, /area/shuttle/custom))
			continue
		//Count custom shuttles
		custom_shuttle_count ++
		//Calculate size
		if(M.width > 35 || M.height > 35)
			message_admins("Custom shuttle [M] skipped due to being over the size limit of (35x35).")
			continue
		//Alright lets get the save data
		var/save_data = M.get_shuttle_tgm_data()
		//Calculate filesize (1 byte = 1 char)
		var/file_size = length(save_data)
		if(file_size > CONFIG_GET(number/shuttle_filesize_max))
			message_admins("Custom shuttle [M] skipped due to being over the file size limit of [CONFIG_GET(number/shuttle_filesize_max)] bytes.")
			continue
		space_required += file_size
		//Save the shuttle file
		var/file_name = "[shuttle_filepath]customshuttle_[GLOB.round_id]_[shuttles_saved].dmm"
		if(fexists(file_name))
			fdel(file_name)
		text2file(save_data, file_name)
		//Log it
		shuttles_saved ++
		message_admins("Custom shuttle [M] successfully saved!")
		CHECK_TICK

	//Clear old shuttles to free up space
	var/left_to_clear = max(current_size + space_required - CONFIG_GET(number/shuttle_total_filesize_max), 0)
	//Luck of the draw
	shuffle_inplace(old_files)
	while(left_to_clear > 0 && length(old_files))
		var/first_thing = old_files[1]
		old_files -= first_thing
		var/file_size = length(file(first_thing))
		fdel(first_thing)
		left_to_clear -= file_size
		space_saved += file_size
		shuttles_deleted ++
		CHECK_TICK

	//Log just in case
	message_admins("Shuttle saving completed! [shuttles_saved] (out of [custom_shuttle_count]) custom shuttles have been saved!")
	log_mapping("Successfully saved [shuttles_saved] custom shuttles to the server totalling [space_required] bytes!")
	log_mapping("To prevent the space limit from being reached, [shuttles_deleted] shuttle files were deleted totalling [space_saved] bytes.")
