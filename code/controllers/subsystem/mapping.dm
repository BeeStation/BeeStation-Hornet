SUBSYSTEM_DEF(mapping)
	name = "Mapping"
	dependencies = list(
		/datum/controller/subsystem/job,
		/datum/controller/subsystem/processing/station,
	)
	runlevels = ALL

	var/list/nuke_tiles = list()
	var/list/nuke_threats = list()

	/// The current map config the server loaded at round start.
	var/datum/map_config/current_map

	/// The map adjustment for this current map, if any.
	var/datum/map_adjustment/map_adjustment

	var/list/map_templates = list()

	var/list/ruins_templates = list()
	var/list/space_ruins_templates = list()
	var/list/lava_ruins_templates = list()
	var/datum/space_level/isolated_ruins_z //Created on demand during ruin loading.

	var/list/shuttle_templates = list()
	var/list/shelter_templates = list()

	///Random rooms template list, gets initialized and filled when server starts.
	var/list/random_room_templates = list()
	///Temporary list, where room spawners are kept roundstart. Not used later.
	var/list/random_room_spawners = list()
	var/list/holodeck_templates = list()

	var/list/areas_in_z = list()

	var/loading_ruins = FALSE
	var/list/turf/unused_turfs = list()				//Not actually unused turfs they're unused but reserved for use for whatever requests them. "[zlevel_of_turf]" = list(turfs)
	var/list/datum/turf_reservations		//list of turf reservations
	var/list/used_turfs = list()				//list of turf = datum/turf_reservation
	/// List of lists of turfs to reserve
	var/list/lists_to_reserve = list()

	///All possible biomes in assoc list as type || instance
	var/list/biomes = list()


	var/list/reservation_ready = list()
	var/clearing_reserved_turfs = FALSE

	// Z-manager stuff
	var/station_start  // should only be used for maploading-related tasks
	var/space_levels_so_far = 0
	var/list/z_list
	///list of all z level indices that form multiz connections and whether theyre linked up or down.
	///list of lists, inner lists are of the form: list("up or down link direction" = TRUE)
	var/list/multiz_levels = list()
	var/datum/space_level/transit
	var/datum/space_level/empty_space
	var/num_of_res_levels = 1

	///shows the default gravity value for each z level. recalculated when gravity generators change.
	///List in the form: list(z level num = max generator gravity in that z level OR the gravity level trait)
	var/list/gravity_by_z_level = list()

	//Echo surface level templates
	var/list/echo_surface_templates = list()

/datum/controller/subsystem/mapping/PreInit()
	..()
#ifdef FORCE_MAP
	current_map = load_map_config(FORCE_MAP, MAP_DIRECTORY)
#else
	current_map = load_map_config(error_if_missing = FALSE)
#endif
	// After assigning a current_map datum to var/current_map, we check which map ajudstment fits the current current_map
	for(var/datum/map_adjustment/each_adjust as anything in subtypesof(/datum/map_adjustment))
		if(initial(each_adjust.map_file_name) != current_map.map_file)
			continue
		map_adjustment = new each_adjust() // map_adjustment has multiple procs that'll be called from needed places (i.e. job_change)
		log_world("Loaded '[current_map.map_file]' map adjustment.")
		break

/datum/controller/subsystem/mapping/Initialize()
	if(initialized)
		return SS_INIT_SUCCESS
	if(current_map.defaulted)
		var/old_config = current_map
		current_map = global.config.defaultmap
		if(!current_map || current_map.defaulted)
			to_chat(world, span_boldannounce("Unable to load next or default map current_map, defaulting to Box Station"))
			current_map = old_config

	if(map_adjustment)
		map_adjustment.on_mapping_init()
		log_world("Applied '[map_adjustment.map_file_name]' map adjustment: on_mapping_init()")

	if(current_map.map_file == "EchoStation.dmm")
		echo_surface_templates() //Echo seasonal surface stuff

	initialize_biomes()
	loadWorld()
	require_area_resort()
	process_teleport_locs()			//Sets up the wizard teleport locations
	preloadTemplates()

#ifndef LOWMEMORYMODE
	// Create space ruin levels
	while (space_levels_so_far < current_map.space_ruin_levels)
		++space_levels_so_far
		LAZYADD(SSzclear.free_levels, add_new_zlevel("Empty Area [space_levels_so_far]", ZTRAITS_SPACE, orbital_body_type = null))
	// and one level with no ruins
	for (var/i in 1 to current_map.space_empty_levels)
		++space_levels_so_far
		empty_space = add_new_zlevel("Empty Area [space_levels_so_far]", list(ZTRAIT_LINKAGE = SELFLOOPING), orbital_body_type = /datum/orbital_object/z_linked/beacon/weak)
	// Pick a random away mission.
	if(CONFIG_GET(flag/roundstart_away))
		createRandomZlevel()

	// Load the virtual reality hub
	if(CONFIG_GET(flag/virtual_reality))
		to_chat(world, span_boldannounce("Loading virtual reality..."))
		load_new_z_level("_maps/RandomZLevels/VR/vrhub.dmm", "Virtual Reality Hub")
		to_chat(world, span_boldannounce("Virtual reality loaded."))

	// Generate mining ruins
	loading_ruins = TRUE
	var/list/lava_ruins = levels_by_trait(ZTRAIT_LAVA_RUINS)
	if (lava_ruins.len)
		seedRuins(lava_ruins, CONFIG_GET(number/lavaland_budget), /area/lavaland/surface/outdoors/unexplored, lava_ruins_templates, clear_below = TRUE)
		for (var/lava_z in lava_ruins)
			spawn_rivers(lava_z)
	loading_ruins = FALSE
#endif
	// Run map generation after ruin generation to prevent issues
	run_map_generation()
	require_area_resort()
	// Set up Z-level transitions.
	setup_map_transitions()
	generate_station_area_list()
	transit = add_new_zlevel("Transit/Reserved", list(ZTRAIT_RESERVED = TRUE))
	initialize_reserved_level(transit.z_value)
	calculate_default_z_level_gravities()
	return SS_INIT_SUCCESS

/datum/controller/subsystem/mapping/fire(resumed)
	// Cache for sonic speed
	var/list/unused_turfs = src.unused_turfs
	var/list/world_contents = GLOB.areas_by_type[world.area].contents
	var/list/world_turf_contents = GLOB.areas_by_type[world.area].contained_turfs
	var/list/lists_to_reserve = src.lists_to_reserve
	var/index = 0
	while(index < length(lists_to_reserve))
		var/list/packet = lists_to_reserve[index + 1]
		var/packetlen = length(packet)
		while(packetlen)
			if(MC_TICK_CHECK)
				lists_to_reserve.Cut(1, index)
				return
			var/turf/T = packet[packetlen]
			T.empty(RESERVED_TURF_TYPE, RESERVED_TURF_TYPE, null, TRUE)
			LAZYINITLIST(unused_turfs["[T.z]"])
			unused_turfs["[T.z]"] |= T
			var/area/old_area = T.loc
			old_area.turfs_to_uncontain += T
			T.flags_1 |= UNUSED_RESERVATION_TURF_1
			// reservation turfs are not allowed to interact with atmos at all
			T.blocks_air = TRUE
			world_contents += T
			world_turf_contents += T
			packet.len--
			packetlen = length(packet)

		index++
	lists_to_reserve.Cut(1, index)

/datum/controller/subsystem/mapping/get_metrics()
	. = ..()
	var/list/custom = list()
	custom["map"] = current_map.map_name
	.["custom"] = custom

/datum/controller/subsystem/mapping/proc/wipe_reservations(wipe_safety_delay = 100)
	if(clearing_reserved_turfs || !initialized)			//in either case this is just not needed.
		return
	clearing_reserved_turfs = TRUE
	SSshuttle.transit_requesters.Cut()
	message_admins("Clearing dynamic reservation space.")
	var/list/obj/docking_port/mobile/in_transit = list()
	for(var/i in SSshuttle.transit)
		var/obj/docking_port/stationary/transit/T = i
		if(!istype(T))
			continue
		in_transit[T] = T.docked
	var/go_ahead = world.time + wipe_safety_delay
	if(in_transit.len)
		message_admins("Shuttles in transit detected. Attempting to fast travel. Timeout is [wipe_safety_delay/10] seconds.")
	var/list/cleared = list()
	for(var/i in in_transit)
		INVOKE_ASYNC(src, PROC_REF(safety_clear_transit_dock), i, in_transit[i], cleared)
	UNTIL((go_ahead < world.time) || (cleared.len == in_transit.len))
	do_wipe_turf_reservations()
	clearing_reserved_turfs = FALSE

/datum/controller/subsystem/mapping/proc/safety_clear_transit_dock(obj/docking_port/stationary/transit/T, obj/docking_port/mobile/M, list/returning)
	M.setTimer(0)
	var/error = M.initiate_docking(M.destination, M.preferred_direction)
	if(!error)
		returning += M
		qdel(T, TRUE)

/// Returns true if the map we're playing on is on a planet
/datum/controller/subsystem/mapping/proc/is_planetary()
	return current_map.planetary_station

/* Nuke threats, for making the blue tiles on the station go RED
	Used by the AI doomsday and the self-destruct nuke.
*/

/datum/controller/subsystem/mapping/proc/add_nuke_threat(datum/nuke)
	nuke_threats[nuke] = TRUE
	check_nuke_threats()

/datum/controller/subsystem/mapping/proc/remove_nuke_threat(datum/nuke)
	nuke_threats -= nuke
	check_nuke_threats()

/datum/controller/subsystem/mapping/proc/check_nuke_threats()
	for(var/datum/d in nuke_threats)
		if(QDELETED(d))
			nuke_threats -= d

	for(var/turf/open/floor/circuit/C as() in nuke_tiles)
		C.update_icon()

/datum/controller/subsystem/mapping/Recover()
	flags |= SS_NO_INIT
	initialized = SSmapping.initialized
	map_templates = SSmapping.map_templates
	ruins_templates = SSmapping.ruins_templates
	space_ruins_templates = SSmapping.space_ruins_templates
	lava_ruins_templates = SSmapping.lava_ruins_templates
	shuttle_templates = SSmapping.shuttle_templates
	random_room_templates = SSmapping.random_room_templates
	shelter_templates = SSmapping.shelter_templates
	unused_turfs = SSmapping.unused_turfs
	turf_reservations = SSmapping.turf_reservations
	used_turfs = SSmapping.used_turfs
	holodeck_templates = SSmapping.holodeck_templates
	transit = SSmapping.transit
	areas_in_z = SSmapping.areas_in_z

	current_map = SSmapping.current_map

	clearing_reserved_turfs = SSmapping.clearing_reserved_turfs

	z_list = SSmapping.z_list

#define INIT_ANNOUNCE(X) to_chat(world, span_boldannounce("[X]")); log_world(X)
/datum/controller/subsystem/mapping/proc/LoadGroup(list/errorList, name, path, files, list/traits, list/default_traits, silent = FALSE, orbital_body_type)
	. = list()
	var/start_time = REALTIMEOFDAY

	if (!islist(files))  // handle single-level maps
		files = list(files)

	// check that the total z count of all maps matches the list of traits
	var/total_z = 0
	var/list/parsed_maps = list()
	for (var/file in files)
		var/full_path = "_maps/[path]/[file]"
		var/datum/parsed_map/pm = new(file(full_path))
		var/bounds = pm?.bounds
		if (!bounds)
			errorList |= full_path
			continue
		parsed_maps[pm] = total_z  // save the start Z of this file
		total_z += bounds[MAP_MAXZ] - bounds[MAP_MINZ] + 1

	if (!length(traits))  // null or empty - default
		for (var/i in 1 to total_z)
			traits += list(default_traits)
	else if (total_z != traits.len)  // mismatch
		INIT_ANNOUNCE("WARNING: [traits.len] trait sets specified for [total_z] z-levels in [path]!")
		if (total_z < traits.len)  // ignore extra traits
			traits.Cut(total_z + 1)
		while (total_z > traits.len)  // fall back to defaults on extra levels
			traits += list(default_traits)

	// preload the relevant space_level datums
	var/start_z = world.maxz + 1
	var/i = 0
	var/list/datum/space_level/space_levels = list()
	for (var/level in traits)
		space_levels += add_new_zlevel("[name][i ? " [i + 1]" : ""]", level, contain_turfs = FALSE)
		++i
	//Shared orbital body
	var/datum/orbital_object/z_linked/orbital_body = new orbital_body_type()
	for(var/datum/space_level/level as() in space_levels)
		SSorbits.assoc_z_levels["[level.z_value]"] = orbital_body
		orbital_body.link_to_z(level)

	// load the maps
	for(var/datum/parsed_map/pm as anything in parsed_maps)
		if(!pm.load(1, 1, start_z + parsed_maps[pm], no_changeturf = TRUE, new_z = TRUE))
			errorList |= pm.original_path

	if(!silent)
		INIT_ANNOUNCE("Loaded [name] in [round((REALTIMEOFDAY - start_time)/10, 0.01)]s!")
	return parsed_maps

/datum/controller/subsystem/mapping/proc/LoadStationRooms()
#ifndef UNIT_TESTS
	var/start_time = REALTIMEOFDAY
	for(var/obj/effect/spawner/room/R as() in random_room_spawners)
		var/list/possibletemplates = list()
		var/datum/map_template/random_room/candidate
		shuffle_inplace(random_room_templates)
		for(var/ID in random_room_templates)
			candidate = random_room_templates[ID]
			if((!R.rooms.len && candidate.spawned) || (!R.rooms.len && (R.room_height != candidate.template_height || R.room_width != candidate.template_width)) || (R.rooms.len && !(candidate.room_id in R.rooms)))
				candidate = null
				continue
			possibletemplates[candidate] = candidate.weight
		if(!length(possibletemplates))
			stack_trace("Failed to find a valid random room / Room Info - height: [R.room_height], width: [R.room_width], name: [R.name]")
		else
			var/datum/map_template/random_room/template = pick_weight(possibletemplates)
			template.stock--
			template.weight = (template.weight / 2)
			if(template.stock <= 0)
				template.spawned = TRUE
			template.stationinitload(get_turf(R), centered = template.centerspawner)
		SSmapping.random_room_spawners -= R
		R.after_place(null, get_turf(R), null, null)
		qdel(R)
	random_room_spawners = null
	INIT_ANNOUNCE("Loaded Random Rooms in [(REALTIMEOFDAY - start_time)/10]s!")
#endif

/datum/controller/subsystem/mapping/proc/loadWorld()
	//if any of these fail, something has gone horribly, HORRIBLY, wrong
	var/list/FailedZs = list()

	// ensure we have space_level datums for compiled-in maps
	InitializeDefaultZLevels()

	// load the station
	station_start = world.maxz + 1
	INIT_ANNOUNCE("Loading [current_map.map_name]...")
	LoadGroup(FailedZs, "Station", current_map.map_path, current_map.map_file, current_map.traits, ZTRAITS_STATION, orbital_body_type = /datum/orbital_object/z_linked/station)

	LoadStationRoomTemplates()
	LoadStationRooms()

	if(SSdbcore.Connect())
		var/datum/db_query/query_round_map_name = SSdbcore.NewQuery({"
			UPDATE [format_table_name("round")] SET map_name = :map_name WHERE id = :round_id
		"}, list("map_name" = current_map.map_name, "round_id" = GLOB.round_id))
		query_round_map_name.Execute()
		qdel(query_round_map_name)

#ifndef LOWMEMORYMODE
	// TODO: remove this when the DB is prepared for the z-levels getting reordered
	while (world.maxz < (5 - 1) && space_levels_so_far < current_map.space_ruin_levels)
		++space_levels_so_far
		LAZYADD(SSzclear.free_levels, add_new_zlevel("Empty Area [space_levels_so_far]", ZTRAITS_SPACE, orbital_body_type = null))

	// load mining
	if(current_map.minetype == "lavaland")
		LoadGroup(FailedZs, "Lavaland", "map_files/Mining", "Lavaland.dmm", default_traits = ZTRAITS_LAVALAND, orbital_body_type = /datum/orbital_object/z_linked/lavaland)
	else if (!isnull(current_map.minetype))
		INIT_ANNOUNCE("WARNING: An unknown minetype '[current_map.minetype]' was set! This is being ignored! Update the maploader code!")
#endif

	if(LAZYLEN(FailedZs))	//but seriously, unless the server's filesystem is messed up this will never happen
		var/msg = "RED ALERT! The following map files failed to load: [FailedZs[1]]"
		if(FailedZs.len > 1)
			for(var/I in 2 to FailedZs.len)
				msg += ", [FailedZs[I]]"
		msg += ". Yell at your server host!"
		INIT_ANNOUNCE(msg)
#undef INIT_ANNOUNCE

GLOBAL_LIST_EMPTY(the_station_areas)

/datum/controller/subsystem/mapping/proc/generate_station_area_list()
	var/static/list/station_areas_blacklist = typecacheof(list(
		/area/space,
		/area/mine,
		/area/ruin,
		/area/asteroid/nearstation,
	))
	// if we ever add /area/station (and remove this typecache) scope this loop's type to /area/station please!!
	for(var/area/station_area in GLOB.areas)
		if (is_type_in_typecache(station_area, station_areas_blacklist))
			continue
		if (!(station_area.area_flags & UNIQUE_AREA))
			continue
		if (is_station_level(station_area.z))
			GLOB.the_station_areas += station_area.type

	if(!GLOB.the_station_areas.len)
		log_world("ERROR: Station areas list failed to generate!")

/datum/controller/subsystem/mapping/proc/run_map_generation()
	for(var/area/A as anything in GLOB.areas)
		A.RunGeneration()

/datum/controller/subsystem/mapping/proc/preloadTemplates() //see master controller setup
	if(IsAdminAdvancedProcCall())
		return

	var/list/filelist = flist("[MAP_DIRECTORY]/templates/")
	for(var/map in filelist)
		var/datum/map_template/T = new(path = "[MAP_DIRECTORY]/templates/[map]", rename = "[map]")
		map_templates[T.name] = T

	preloadRuinTemplates()
	preloadShuttleTemplates()
	preloadShelterTemplates()
	preloadHolodeckTemplates()

/datum/controller/subsystem/mapping/proc/LoadStationRoomTemplates()
	for(var/item in subtypesof(/datum/map_template/random_room))
		var/datum/map_template/random_room/R = new item()
		if(!R.mappath || R.mappath == null)
			world.log << "Skipping template type: [item] (no mappath)"
			qdel(R)
			continue
		random_room_templates[R.room_id] = R
		map_templates[R.room_id] = R

/datum/map_template/random_room
	var/room_id //The SSmapping random_room_template list is ordered by this var
	var/spawned //Whether this template (on the random_room template list) has been spawned
	var/centerspawner = TRUE
	var/template_height = 0
	var/template_width = 0
	var/weight = 10 //weight a room has to appear
	var/stock = 1 //how many times this room can appear in a round

/datum/controller/subsystem/mapping/proc/preloadRuinTemplates()
	// Still supporting bans by filename
	var/list/banned = generateMapList("lavaruinblacklist.txt")
	banned += generateMapList("spaceruinblacklist.txt")

	for(var/item in sort_list(subtypesof(/datum/map_template/ruin), GLOBAL_PROC_REF(cmp_ruincost_priority)))
		var/datum/map_template/ruin/ruin_type = item
		// screen out the abstract subtypes
		if(!initial(ruin_type.id))
			continue
		var/datum/map_template/ruin/R = new ruin_type()

		if(banned.Find(R.mappath))
			continue

		map_templates[R.name] = R
		ruins_templates[R.name] = R

		if(istype(R, /datum/map_template/ruin/lavaland))
			lava_ruins_templates[R.name] = R
		else if(istype(R, /datum/map_template/ruin/space))
			space_ruins_templates[R.name] = R

/datum/controller/subsystem/mapping/proc/preloadShuttleTemplates()
	var/list/unbuyable = generateMapList("shuttles_unbuyable.txt")
	var/list/illegal = generateMapList("shuttles_illegal.txt")

	for(var/item in subtypesof(/datum/map_template/shuttle))
		var/datum/map_template/shuttle/shuttle_type = item
		if(!(initial(shuttle_type.suffix)))
			continue

		var/datum/map_template/shuttle/S = new shuttle_type()
		if(unbuyable.Find(S.mappath))
			S.can_be_bought = FALSE
		if(illegal.Find(S.mappath))
			S.illegal_shuttle = TRUE

		shuttle_templates[S.shuttle_id] = S
		map_templates[S.shuttle_id] = S

/datum/controller/subsystem/mapping/proc/preloadShelterTemplates()
	for(var/item in subtypesof(/datum/map_template/shelter))
		var/datum/map_template/shelter/shelter_type = item
		if(!(initial(shelter_type.mappath)))
			continue
		var/datum/map_template/shelter/S = new shelter_type()

		shelter_templates[S.shelter_id] = S
		map_templates[S.shelter_id] = S

/datum/controller/subsystem/mapping/proc/preloadHolodeckTemplates()
	for(var/item in subtypesof(/datum/map_template/holodeck))
		var/datum/map_template/holodeck/holodeck_type = item
		if(!(initial(holodeck_type.mappath)))
			continue
		var/datum/map_template/holodeck/holo_template = new holodeck_type()

		holodeck_templates[holo_template.template_id] = holo_template

/datum/controller/subsystem/mapping/proc/RequestBlockReservation(width, height, z, type = /datum/turf_reservation, turf_type_override)
	UNTIL((!z || reservation_ready["[z]"]) && !clearing_reserved_turfs)
	var/datum/turf_reservation/reserve = new type
	if(turf_type_override)
		reserve.turf_type = turf_type_override
	if(!z)
		for(var/i in levels_by_trait(ZTRAIT_RESERVED))
			if(reserve.Reserve(width, height, i))
				return reserve
		//If we didn't return at this point, theres a good chance we ran out of room on the exisiting reserved z levels, so lets try a new one
		num_of_res_levels += 1
		var/datum/space_level/newReserved = add_new_zlevel("Transit/Reserved [num_of_res_levels]", list(ZTRAIT_RESERVED = TRUE))
		initialize_reserved_level(newReserved.z_value)
		if(reserve.Reserve(width, height, newReserved.z_value))
			return reserve
	else
		if(!level_trait(z, ZTRAIT_RESERVED))
			qdel(reserve)
			return
		else
			if(reserve.Reserve(width, height, z))
				return reserve
	QDEL_NULL(reserve)

//This is not for wiping reserved levels, use wipe_reservations() for that.
/datum/controller/subsystem/mapping/proc/initialize_reserved_level(z)
	UNTIL(!clearing_reserved_turfs)				//regardless, lets add a check just in case.
	clearing_reserved_turfs = TRUE			//This operation will likely clear any existing reservations, so lets make sure nothing tries to make one while we're doing it.
	if(!level_trait(z,ZTRAIT_RESERVED))
		clearing_reserved_turfs = FALSE
		CRASH("Invalid z level prepared for reservations.")
	var/turf/A = get_turf(locate(SHUTTLE_TRANSIT_BORDER,SHUTTLE_TRANSIT_BORDER,z))
	var/turf/B = get_turf(locate(world.maxx - SHUTTLE_TRANSIT_BORDER,world.maxy - SHUTTLE_TRANSIT_BORDER,z))
	var/block = block(A, B)
	for(var/t in block)
		// No need to empty() these, because it's world init and they're
		// already /turf/open/space/basic.
		var/turf/T = t
		T.flags_1 |= UNUSED_RESERVATION_TURF_1
		T.blocks_air = TRUE
	unused_turfs["[z]"] = block
	reservation_ready["[z]"] = TRUE
	clearing_reserved_turfs = FALSE

/// Schedules a group of turfs to be handed back to the reservation system's control
/// If await is true, will sleep until the turfs are finished work
/datum/controller/subsystem/mapping/proc/reserve_turfs(list/turfs, await = FALSE)
	lists_to_reserve += list(turfs)
	if(await)
		UNTIL(!length(turfs))

//DO NOT CALL THIS PROC DIRECTLY, CALL wipe_reservations().
/datum/controller/subsystem/mapping/proc/do_wipe_turf_reservations()
	UNTIL(initialized)							//This proc is for AFTER init, before init turf reservations won't even exist and using this will likely break things.
	for(var/i in turf_reservations)
		var/datum/turf_reservation/TR = i
		if(!QDELETED(TR))
			qdel(TR, TRUE)
	UNSETEMPTY(turf_reservations)
	var/list/clearing = list()
	for(var/l in unused_turfs)			//unused_turfs is a assoc list by z = list(turfs)
		if(islist(unused_turfs[l]))
			clearing |= unused_turfs[l]
	clearing |= used_turfs		//used turfs is an associative list, BUT, reserve_turfs() can still handle it. If the code above works properly, this won't even be needed as the turfs would be freed already.
	unused_turfs.Cut()
	used_turfs.Cut()
	reserve_turfs(clearing, await = TRUE)

/datum/controller/subsystem/mapping/proc/initialize_biomes()
	for(var/biome_path in subtypesof(/datum/biome))
		var/datum/biome/biome_instance = new biome_path()
		biomes[biome_path] += biome_instance

/datum/controller/subsystem/mapping/proc/reg_in_areas_in_z(list/areas)
	for(var/B in areas)
		var/area/A = B
		A.reg_in_areas_in_z()

/datum/controller/subsystem/mapping/proc/get_isolated_ruin_z()
	if(!isolated_ruins_z)
		isolated_ruins_z = add_new_zlevel("Isolated Ruins/Reserved", list(ZTRAIT_RESERVED = TRUE, ZTRAIT_ISOLATED_RUINS = TRUE))
		initialize_reserved_level(isolated_ruins_z.z_value)
	return isolated_ruins_z.z_value

/// Takes a z level datum, and tells the mapping subsystem to manage it
/// - Adds to z_list, and builds its area turfs
/datum/controller/subsystem/mapping/proc/manage_z_level(datum/space_level/new_z, filled_with_space, contain_turfs = TRUE)
	z_list += new_z

	gravity_by_z_level.len += 1

	if(contain_turfs)
		build_area_turfs(new_z.z_value, filled_with_space)

/datum/controller/subsystem/mapping/proc/build_area_turfs(z_level, space_guaranteed)
	// If we know this is filled with default tiles, we can use the default area
	// Faster
	if(space_guaranteed)
		var/area/global_area = GLOB.areas_by_type[world.area]
		global_area.contained_turfs += Z_TURFS(z_level)
		return

	for(var/turf/to_contain as anything in Z_TURFS(z_level))
		var/area/our_area = to_contain.loc
		our_area.contained_turfs += to_contain

/datum/controller/subsystem/mapping/proc/calculate_default_z_level_gravities()
	for(var/z_level in 1 to length(z_list))
		calculate_z_level_gravity(z_level)

/datum/controller/subsystem/mapping/proc/generate_z_level_linkages()
	for(var/z_level in 1 to length(z_list))
		generate_linkages_for_z_level(z_level)

/datum/controller/subsystem/mapping/proc/generate_linkages_for_z_level(z_level)
	if(!isnum(z_level) || z_level <= 0)
		return FALSE

	if(multiz_levels.len < z_level)
		multiz_levels.len = z_level

	var/z_above = level_trait(z_level, ZTRAIT_UP)
	var/z_below = level_trait(z_level, ZTRAIT_DOWN)
	if(!(z_above == TRUE || z_above == FALSE || z_above == null) || !(z_below == TRUE || z_below == FALSE || z_below == null))
		stack_trace("Warning, numeric mapping offsets are deprecated. Instead, mark z level connections by setting UP/DOWN to true if the connection is allowed")
	multiz_levels[z_level] = new /list(LARGEST_Z_LEVEL_INDEX)
	multiz_levels[z_level][Z_LEVEL_UP] = !!z_above
	multiz_levels[z_level][Z_LEVEL_DOWN] = !!z_below

/datum/controller/subsystem/mapping/proc/calculate_z_level_gravity(z_level_number)
	if(!isnum(z_level_number) || z_level_number < 1)
		return FALSE

	var/max_gravity = 0

	for(var/obj/machinery/gravity_generator/main/grav_gen as anything in GLOB.gravity_generators["[z_level_number]"])
		max_gravity = max(grav_gen.setting, max_gravity)

	max_gravity = max_gravity || level_trait(z_level_number, ZTRAIT_GRAVITY) || 0 //just to make sure no nulls
	gravity_by_z_level[z_level_number] = max_gravity
	return max_gravity

// echo surface templates found in random_rooms.dm
/datum/controller/subsystem/mapping/proc/echo_surface_templates()
	for (var/path in typesof(/datum/map_template/random_room/echo))
		if (ECHO_TEMPLATE_PATH(path))
			var/datum/map_template/random_room/echo/template = new path()
			echo_surface_templates += template
