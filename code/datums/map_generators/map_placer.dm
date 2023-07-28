///////////////////////////////////////////////////////////////
//SS13 (un)Optimized Map loader
//////////////////////////////////////////////////////////////

#define GENERATE_STAGE_BUILD_CACHE_START 0
#define GENERATE_STAGE_BUILD_CACHE 1
#define GENERATE_STAGE_BUILD_COORDINATES_START 2
#define GENERATE_STAGE_BUILD_COORDINATES 3
#define GENERATE_STAGE_COMPLETED 4

/datum/map_generator/map_place
	/// The map template we are placing
	var/datum/parsed_map/placing_template

	//=========================
	// Generation Parameters
	//=========================

	var/x_offset
	var/y_offset
	var/z_offset
	var/crop_map = FALSE
	var/no_changeturf = FALSE
	var/x_lower = -INFINITY
	var/x_upper = INFINITY
	var/y_lower = -INFINITY
	var/y_upper = INFINITY
	var/place_on_top = FALSE

	//=========================
	// Generation Run Variables
	//=========================

	var/current_run = GENERATE_STAGE_BUILD_CACHE_START
	var/run_stage = 0

	var/list/area_cache = list()
	var/list/model_cache
	var/space_key = null
	var/list/bounds

	//=========================
	// Build Cache Locals
	//=========================

	var/list/grid_models

	var/grid_model_index

	var/model_key
	var/model
	var/list/members
	var/list/members_attributes
	var/index
	var/old_position
	var/dpos

	//=========================
	// Build Coordinate Locals
	//=========================

	var/datum/grid_set/gset

	/// The index of the grid line we are currently working on.
	/// Start at infinity as we need to access the outer loop first.
	var/current_grid_line = INFINITY

	var/ycrd
	var/zcrd
	var/zexpansion

/datum/map_generator/map_place/New(datum/parsed_map/placing_template, x_offset = 1, y_offset = 1, z_offset = world.maxz + 1, cropMap = FALSE, no_changeturf = FALSE, x_lower = -INFINITY, x_upper = INFINITY, y_lower = -INFINITY, y_upper = INFINITY, placeOnTop = FALSE)
	. = ..()
	src.placing_template = placing_template
	src.x_offset = x_offset
	src.y_offset = y_offset
	src.z_offset = z_offset
	crop_map = cropMap
	src.no_changeturf = no_changeturf
	src.x_lower = x_lower
	src.x_upper = x_upper
	src.y_lower = y_lower
	src.y_upper = y_upper
	place_on_top = placeOnTop

/datum/map_generator/map_place/execute_run()
	..()
	if (current_run == GENERATE_STAGE_BUILD_CACHE_START)
		build_cache_start()
	if (current_run == GENERATE_STAGE_BUILD_CACHE)
		build_cache()
	if (current_run == GENERATE_STAGE_BUILD_COORDINATES_START)
		build_coordinates_start()
	if (current_run == GENERATE_STAGE_BUILD_COORDINATES)
		SSatoms.map_loader_begin(REF(src))
		build_coordinates()
		SSatoms.map_loader_stop(REF(src))
	. = current_run == GENERATE_STAGE_COMPLETED

/datum/map_generator/map_place/proc/set_stage(stage)
	run_stage = 1
	current_run = stage

/datum/map_generator/map_place/get_name()
	return placing_template?.original_path || "Unkown map"

//======================================
// COORDINATE BUILDING
//======================================

/datum/map_generator/map_place/proc/build_coordinates_start()
	//Locate the space key
	space_key = model_cache[SPACE_KEY]
	//Set them all to the same reference, so changing one affects the other
	bounds = placing_template.bounds = list(1.#INF, 1.#INF, 1.#INF, -1.#INF, -1.#INF, -1.#INF)
	//Move to the next stage
	set_stage(GENERATE_STAGE_BUILD_COORDINATES)

/datum/map_generator/map_place/proc/build_coordinates()
	while (TRUE)
		// Perform inner loop first
		while (gset && current_grid_line <= length(gset.gridLines))
			// Build a single grid line
			build_coordinate_grid_line()
			//Building the grid line overran tick
			if (TICK_CHECK)
				return
		// Enumerate to the next grid set
		run_stage ++
		// Check if we are still within bounds
		if (run_stage - 1 > length(placing_template.gridSets))
			if(!no_changeturf)
				for(var/t in block(locate(bounds[MAP_MINX], bounds[MAP_MINY], bounds[MAP_MINZ]), locate(bounds[MAP_MAXX], bounds[MAP_MAXY], bounds[MAP_MAXZ])))
					var/turf/T = t
					//we do this after we load everything in. if we don't; we'll have weird atmos bugs regarding atmos adjacent turfs
					T.AfterChange(CHANGETURF_IGNORE_AIR)

			// Testing message
#ifdef TESTING
			if(placing_template.turfsSkipped)
				testing("Skipped loading [placing_template.turfsSkipped] default turfs")
#endif

			// Refresh atmospherics grid
			if(placing_template.did_expand)
				world.refresh_atmos_grid()

			// Generation completed
			set_stage(GENERATE_STAGE_COMPLETED)
			return
		// Perform grid set action
		gset = placing_template.gridSets[run_stage - 1]
		ycrd = gset.ycrd + y_offset - 1
		zcrd = gset.zcrd + z_offset - 1
		//Set the current grid line back to 1, for the next iteration
		current_grid_line = 1
		if(!crop_map && ycrd > world.maxy)
			// Expand Y here.  X is expanded in the loop below
			world.maxy = ycrd
			placing_template.did_expand = TRUE
		zexpansion = zcrd > world.maxz
		if(zexpansion)
			if(crop_map)
				continue
			else
				//create a new z_level if needed
				while (zcrd > world.maxz)
					world.incrementMaxZ()
					placing_template.did_expand = FALSE
			if(!no_changeturf)
				WARNING("Z-level expansion occurred without no_changeturf set, this may cause problems when /turf/AfterChange is called")
		// Check for tick overrun
		if (TICK_CHECK)
			return

/datum/map_generator/map_place/proc/build_coordinate_grid_line()
	// Get the current grid line
	var/line = gset.gridLines[current_grid_line ++]
	if((ycrd - y_offset + 1) < y_lower || (ycrd - y_offset + 1) > y_upper)				//Reverse operation and check if it is out of bounds of cropping.
		--ycrd
		return
	if(ycrd <= world.maxy && ycrd >= 1)
		var/xcrd = gset.xcrd + x_offset - 1
		for(var/tpos = 1 to length(line) - placing_template.key_len + 1 step placing_template.key_len)
			if((xcrd - x_offset + 1) < x_lower || (xcrd - x_offset + 1) > x_upper)			//Same as above.
				++xcrd
				continue								//X cropping.
			if(xcrd > world.maxx)
				if(crop_map)
					break
				else
					world.maxx = xcrd
					placing_template.did_expand = TRUE

			if(xcrd >= 1)
				var/model_key = copytext(line, tpos, tpos + placing_template.key_len)
				var/no_afterchange = no_changeturf || zexpansion
				if(!no_afterchange || (model_key != space_key))
					var/list/cache = model_cache[model_key]
					if(!cache)
						CRASH("Undefined model key in DMM: [model_key]")
					placing_template.build_coordinate(area_cache, cache, locate(xcrd, ycrd, zcrd), no_afterchange, place_on_top)

					// only bother with bounds that actually exist
					bounds[MAP_MINX] = min(bounds[MAP_MINX], xcrd)
					bounds[MAP_MINY] = min(bounds[MAP_MINY], ycrd)
					bounds[MAP_MINZ] = min(bounds[MAP_MINZ], zcrd)
					bounds[MAP_MAXX] = max(bounds[MAP_MAXX], xcrd)
					bounds[MAP_MAXY] = max(bounds[MAP_MAXY], ycrd)
					bounds[MAP_MAXZ] = max(bounds[MAP_MAXZ], zcrd)
#ifdef TESTING
				else
					++placing_template.turfsSkipped
#endif
			++xcrd
	--ycrd

//======================================
// CACHE BUILDING
//======================================

/// Initialize cache building
/datum/map_generator/map_place/proc/build_cache_start()
	// Model cache is already setup
	if (placing_template.modelCache)
		model_cache = placing_template.modelCache
		set_stage(GENERATE_STAGE_BUILD_COORDINATES_START)
		return
	//Set these all to be the same reference
	model_cache = placing_template.modelCache = list()
	set_stage(GENERATE_STAGE_BUILD_CACHE)
	//Set the grid models
	grid_models = placing_template.grid_models
	//Set the first stage of the grid model loop
	model_key = grid_models[run_stage]
	build_cache_set_model_loop()

/// Build the cache
/datum/map_generator/map_place/proc/build_cache()
	do
		// dpos loop
		while (dpos != 0)
			// Build this section of the cache
			build_cache_construct_members()
			// Tick overrun, return to MC (We will pick up where we left from)
			if (TICK_CHECK)
				return
		//check and see if we can just skip this turf
		//So you don't have to understand this horrid statement, we can do this if
		// 1. no_changeturf is set
		// 2. the space_key isn't set yet
		// 3. there are exactly 2 members
		// 4. with no attributes
		// 5. and the members are world.turf and world.area
		// Basically, if we find an entry like this: "XXX" = (/turf/default, /area/default)
		// We can skip calling this proc every time we see XXX
		if(no_changeturf \
			&& !(model_cache[SPACE_KEY]) \
			&& members.len == 2 \
			&& members_attributes.len == 2 \
			&& length(members_attributes[1]) == 0 \
			&& length(members_attributes[2]) == 0 \
			&& (world.area in members) \
			&& (world.turf in members))

			model_cache[SPACE_KEY] = model_key
			continue

		model_cache[model_key] = list(members, members_attributes)

		// Continue until we overrun
		if (TICK_CHECK)
			return
	while(build_cache_move_next())

/// Move to the next element in the build cache
/datum/map_generator/map_place/proc/build_cache_move_next()
	run_stage ++
	//Check if we are still in range
	if (run_stage > length(grid_models))
		// Out of range, cache building is completed
		set_stage(GENERATE_STAGE_BUILD_COORDINATES_START)
		//Store the cache in the template
		placing_template.modelCache = model_cache
		return FALSE
	model_key = grid_models[run_stage]
	build_cache_set_model_loop()
	return TRUE

/// Start of the grid_model loop
/datum/map_generator/map_place/proc/build_cache_set_model_loop()
	model = grid_models[model_key]
	members = list()
	members_attributes = list()
	//Reset dpos for next loop
	dpos = null
	index = 1
	old_position = 1

/// Constructing members and corresponding variables lists
/datum/map_generator/map_place/proc/build_cache_construct_members()
	//finding next member (e.g /turf/unsimulated/wall{icon_state = "rock"} or /area/mine/explored)
	//find next delimiter (comma here) that's not within {...}
	dpos = placing_template.find_next_delimiter_position(model, old_position, ",", "{", "}")
	//full definition, e.g : /obj/foo/bar{variables=derp}
	var/full_def = trim_reduced(copytext(model, old_position, dpos))
	var/variables_start = findtext(full_def, "{")
	var/path_text = trim_reduced(copytext(full_def, 1, variables_start))
	//path definition, e.g /obj/foo/bar
	var/atom_def = text2path(path_text)
	if(dpos)
		old_position = dpos + length(model[dpos])

	// Skip the item if the path does not exist.  Fix your crap, mappers!
	if(!ispath(atom_def, /atom))
		return
	members.Add(atom_def)

	//transform the variables in text format into a list (e.g {var1="derp"; var2; var3=7} => list(var1="derp", var2, var3=7))
	var/list/fields = list()

	//if there's any variable
	if(variables_start)
		//removing the last '}'
		full_def = copytext(full_def, variables_start + length(full_def[variables_start]), -length(copytext_char(full_def, -1)))
		fields = placing_template.readlist(full_def, ";")
		if(fields.len)
			if(!trim(fields[fields.len]))
				--fields.len
			for(var/I in fields)
				var/value = fields[I]
				if(istext(value))
					fields[I] = apply_text_macros(value)

	//then fill the members_attributes list with the corresponding variables
	members_attributes.len++
	members_attributes[index++] = fields

#undef GENERATE_STAGE_BUILD_CACHE_START
#undef GENERATE_STAGE_BUILD_CACHE
#undef GENERATE_STAGE_BUILD_COORDINATES_START
#undef GENERATE_STAGE_BUILD_COORDINATES
#undef GENERATE_STAGE_COMPLETED
