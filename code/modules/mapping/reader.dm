///////////////////////////////////////////////////////////////
//SS13 Optimized Map loader
//////////////////////////////////////////////////////////////

// We support two different map formats
// It is kinda possible to process them together, but if we split them up
// I can make optimization decisions more easily
/**
 * DMM SPEC:
 * DMM is split into two parts. First we have strings of text linked to lists of paths and their modifications (I will call this the cache)
 * We call these strings "keys" and the things they point to members. Keys have a static length
 *
 * The second part is a list of locations matched to a string of keys. (I'll be calling this the grid)
 * These are used to lookup the cache we built earlier.
 * We store location lists as grid_sets. the lines represent different things depending on the spec
 *
 * In standard DMM (which you can treat as the base case, since it also covers weird modifications) each line
 * represents an x file, and there's typically only one grid set per z level.
 * The meme is you can look at a DMM formatted map and literally see what it should roughly look like
 * This differs in TGM, and we can pull some performance from this
 *
 * Any restrictions here also apply to TGM
 *
 * /tg/ Restrictions:
 * Paths have a specified order. First atoms in the order in which they should be loaded, then a single turf, then the area of the cell
 * DMM technically supports turf stacking, but this is deprecated for all formats

 */
#define MAP_DMM "dmm"
/**
 * TGM SPEC:
 * TGM is a derevation of DMM, with restrictions placed on it
 * to make it easier to parse and to reduce merge conflicts/ease their resolution
 *
 * Requirements:
 * Each "statement" in a key's details ends with a new line, and wrapped in (...)
 * All paths end with either a comma or occasionally a {, then a new line
 * Excepting the area, who is listed last and ends with a ) to mark the end of the key
 *
 * {} denotes a list of variable edits applied to the path that came before the first {
 * the final } is followed by a comma, and then a new line
 * Variable edits have the form \tname = value;\n
 * Except the last edit, which has no final ;, and just ends in a newline
 * No extra padding is permitted
 * Many values are supported. See parse_constant()
 * Strings must be wrapped in "...", files in '...', and lists in list(...)
 * Files are kinda susy, and may not actually work. buyer beware
 * Lists support assoc values as expected
 * These constants can be further embedded into lists
 * One var edited list will be shared among all the things it is applied to
 *
 * There can be no padding in front of, or behind a path
 *
 * Therefore:
 * "key" = (
 * /path,
 * /other/path{
 *     var = list("name" = 'filepath');
 *     other_var = /path
 *     },
 * /turf,
 * /area)
 *
 */
#define MAP_TGM "tgm"
#define MAP_UNKNOWN "unknown"

/datum/grid_set
	var/xcrd
	var/ycrd
	var/zcrd
	var/gridLines

/datum/parsed_map
	var/original_path
	var/map_format
	/// The length of a key in this file. This is promised by the standard to be static
	var/key_len = 0
	/// The length of a line in this file. Not promised by dmm but standard dmm uses it, so we can trust it
	var/line_len = 0
	/// If we've expanded world.maxx
	var/expanded_x = FALSE
	/// If we've expanded world.maxy
	var/expanded_y = FALSE
	/// If we've expanded world.maxz
	var/expanded_z = FALSE
	var/list/grid_models = list()
	var/list/gridSets = list()
	/// List of area types we've loaded AS A PART OF THIS MAP
	/// We do this to allow non unique areas, so we'll only load one per map
	var/list/loaded_areas = list()

	var/list/modelCache

	/// Unoffset bounds. Null on parse failure.
	var/list/parsed_bounds
	/// Offset bounds. Same as parsed_bounds until load().
	var/list/bounds
	var/did_expand = FALSE

	///any turf in this list is skipped inside of build_coordinate. Lazy assoc list
	var/list/turf_blacklist

	// raw strings used to represent regexes more accurately
	// '' used to avoid confusing syntax highlighting
	var/static/regex/dmm_regex = new(@'"([a-zA-Z]+)" = (?:\(\n|\()((?:.|\n)*?)\)\n(?!\t)|\((\d+),(\d+),(\d+)\) = \{"([a-zA-Z\n]*)"\}', "g")
	/// Matches key formats in TMG (IE: newline after the \()
	var/static/regex/matches_tgm = new(@'^"[A-z]*"[\s]*=[\s]*\([\s]*\n', "m")
	/// Pulls out key value pairs for TGM
	var/static/regex/var_edits_tgm = new(@'^\t([A-z]*) = (.*?);?$')
	/// Pulls out model paths for DMM
	var/static/regex/model_path = new(@'(\/[^\{]*?(?:\{.*?\})?)(?:,|$)', "g")

	/// If we are currently loading this map
	var/loading = FALSE

#ifdef TESTING
	var/turfsSkipped = 0
#endif

//text trimming (both directions) helper macro
#define TRIM_TEXT(text) (trim_reduced(text))

/// Shortcut function to parse a map and apply it to the world.
///
/// - `dmm_file`: A .dmm file to load (Required).
/// - `x_offset`, `y_offset`, `z_offset`: Positions representign where to load the map (Optional).
/// - `cropMap`: When true, the map will be cropped to fit the existing world dimensions (Optional).
/// - `measureOnly`: When true, no changes will be made to the world (Optional).
/// - `no_changeturf`: When true, [turf/AfterChange] won't be called on loaded turfs
/// - `x_lower`, `x_upper`, `y_lower`, `y_upper`: Coordinates (relative to the map) to crop to (Optional).
/// - `placeOnTop`: Whether to use [turf/PlaceOnTop] rather than [turf/ChangeTurf] (Optional).
/proc/load_map(dmm_file as file, x_offset as num, y_offset as num, z_offset as num, cropMap as num, measureOnly as num, no_changeturf as num, x_lower = -INFINITY as num, x_upper = INFINITY as num, y_lower = -INFINITY as num, y_upper = INFINITY as num, placeOnTop = FALSE as num, new_z)
	var/datum/parsed_map/parsed = new(dmm_file, x_lower, x_upper, y_lower, y_upper, measureOnly)
	if(parsed.bounds && !measureOnly)
		parsed.load(x_offset, y_offset, z_offset, cropMap, no_changeturf, x_lower, x_upper, y_lower, y_upper, placeOnTop, new_z = new_z)
	return parsed

/// Parse a map, possibly cropping it.
/datum/parsed_map/New(tfile, x_lower = -INFINITY, x_upper = INFINITY, y_lower = -INFINITY, y_upper=INFINITY, measureOnly=FALSE)
	// This proc sleeps for like 6 seconds. why?
	// Is it file accesses? if so, can those be done ahead of time, async to save on time here? I wonder.
	// Love ya :)
	if(isfile(tfile))
		original_path = "[tfile]"
		var/temp_hack_garbage = tfile
		tfile = rustg_file_read(tfile)
		//This is hacky garbage
		if(tfile == "") //Might be an upload, try raw loading it.
			tfile = file2text(temp_hack_garbage)
	else if(isnull(tfile))
		// create a new datum without loading a map
		return

	src.bounds = parsed_bounds = list(1.#INF, 1.#INF, 1.#INF, -1.#INF, -1.#INF, -1.#INF)

	if(findtext(tfile, matches_tgm))
		map_format = MAP_TGM
	else
		map_format = MAP_DMM // Fallback

	// lists are structs don't you know :)
	var/list/bounds = src.bounds
	var/list/grid_models = src.grid_models
	var/key_len = src.key_len
	var/line_len = src.line_len

	var/stored_index = 1
	var/list/regexOutput
	//multiz lool
	while(dmm_regex.Find(tfile, stored_index))
		stored_index = dmm_regex.next
		// Datum var lookup is expensive, this isn't
		regexOutput = dmm_regex.group

		// "aa" = (/type{vars=blah})
		if(regexOutput[1]) // Model
			var/key = regexOutput[1]
			if(grid_models[key]) // Duplicate model keys are ignored in DMMs
				continue
			if(key_len != length(key))
				if(!key_len)
					key_len = length(key)
				else
					CRASH("Inconsistent key length in DMM")
			if(!measureOnly)
				grid_models[key] = regexOutput[2]

		// (1,1,1) = {"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"}
		else if(regexOutput[3]) // Coords
			if(!key_len)
				CRASH("Coords before model definition in DMM")

			var/curr_x = text2num(regexOutput[3])

			if(curr_x < x_lower || curr_x > x_upper)
				continue

			var/datum/grid_set/gridSet = new

			gridSet.xcrd = curr_x
			//position of the currently processed square
			gridSet.ycrd = text2num(regexOutput[4])
			gridSet.zcrd = text2num(regexOutput[5])

			bounds[MAP_MINX] = min(bounds[MAP_MINX], curr_x)
			bounds[MAP_MINZ] = min(bounds[MAP_MINZ], gridSet.zcrd)
			bounds[MAP_MAXZ] = max(bounds[MAP_MAXZ], gridSet.zcrd)

			var/list/gridLines = splittext(regexOutput[6], "\n")
			gridSet.gridLines = gridLines

			var/leadingBlanks = 0
			while(leadingBlanks < length(gridLines) && gridLines[++leadingBlanks] == "")
			if(leadingBlanks > 1)
				gridLines.Cut(1, leadingBlanks) // Remove all leading blank lines.

			if(!length(gridLines)) // Skip it if only blank lines exist.
				continue

			gridSets += gridSet

			if(gridLines[length(gridLines)] == "")
				gridLines.Cut(length(gridLines)) // Remove only one blank line at the end.

			bounds[MAP_MINY] = min(bounds[MAP_MINY], gridSet.ycrd)
			gridSet.ycrd += length(gridLines) - 1 // Start at the top and work down
			bounds[MAP_MAXY] = max(bounds[MAP_MAXY], gridSet.ycrd)

			if(!line_len)
				line_len = length(gridLines[1])

			var/maxx = curr_x
			if(length(gridLines)) //Not an empty map
				maxx = max(maxx, curr_x + line_len / key_len - 1)

			bounds[MAP_MAXX] = max(bounds[MAP_MAXX], maxx)
		CHECK_TICK

	// Indicate failure to parse any coordinates by nulling bounds
	if(bounds[1] == 1.#INF)
		src.bounds = null
	else
		// Clamp all our mins and maxes down to the proscribed limits
		bounds[MAP_MINX] = clamp(bounds[MAP_MINX], x_lower, x_upper)
		bounds[MAP_MAXX] = clamp(bounds[MAP_MAXX], x_lower, x_upper)
		bounds[MAP_MINY] = clamp(bounds[MAP_MINY], y_lower, y_upper)
		bounds[MAP_MAXY] = clamp(bounds[MAP_MAXY], y_lower, y_upper)

	parsed_bounds = src.bounds
	src.key_len = key_len
	src.line_len = line_len

/datum/parsed_map/proc/copy()
	var/datum/parsed_map/copy = new()
	copy.original_path = original_path
	copy.key_len = key_len
	copy.grid_models = grid_models
	copy.gridSets = gridSets
	copy.modelCache = modelCache
	copy.parsed_bounds = parsed_bounds
	copy.turf_blacklist = list()
	return copy

/// Load the parsed map into the world. See [/proc/load_map] for arguments.
/datum/parsed_map/proc/load(x_offset, y_offset, z_offset, cropMap, no_changeturf, x_lower, x_upper, y_lower, y_upper, placeOnTop, whitelist = FALSE, new_z)
	//How I wish for RAII
	Master.StartLoadingMap()
	. = _load_impl(x_offset, y_offset, z_offset, cropMap, no_changeturf, x_lower, x_upper, y_lower, y_upper, placeOnTop, new_z)
	Master.StopLoadingMap()

#define MAPLOADING_CHECK_TICK \
	if(TICK_CHECK) { \
		if(loading) { \
			SSatoms.map_loader_stop(REF(src)); \
			stoplag(); \
			SSatoms.map_loader_begin(REF(src)); \
		} else { \
			stoplag(); \
		} \
	}

// Do not call except via load() above.
/datum/parsed_map/proc/_load_impl(x_offset = 1, y_offset = 1, z_offset = world.maxz + 1, cropMap = FALSE, no_changeturf = FALSE, x_lower = -INFINITY, x_upper = INFINITY, y_lower = -INFINITY, y_upper = INFINITY, placeOnTop = FALSE, new_z = FALSE)
	PRIVATE_PROC(TRUE)
	// Tell ss atoms that we're doing maploading
	// We'll have to account for this in the following tick_checks so it doesn't overflow
	loading = TRUE
	SSatoms.map_loader_begin(REF(src))

	// Loading used to be done in this proc
	// We make the assumption that if the inner procs runtime, we WANT to do cleanup on them, but we should stil tell our parents we failed
	// Since well, we did
	var/sucessful = FALSE
	switch(map_format)
		if(MAP_TGM)
			sucessful = _tgm_load(x_offset, y_offset, z_offset, cropMap, no_changeturf, x_lower, x_upper, y_lower, y_upper, placeOnTop, new_z)
		else
			sucessful = _dmm_load(x_offset, y_offset, z_offset, cropMap, no_changeturf, x_lower, x_upper, y_lower, y_upper, placeOnTop, new_z)

	// And we are done lads, call it off
	SSatoms.map_loader_stop(REF(src))
	loading = FALSE

	if(new_z)
		for(var/z_index in bounds[MAP_MINZ] to bounds[MAP_MAXZ])
			SSmapping.build_area_turfs(z_index)

	if(!no_changeturf)
		for(var/turf/T as anything in block(locate(bounds[MAP_MINX], bounds[MAP_MINY], bounds[MAP_MINZ]), locate(bounds[MAP_MAXX], bounds[MAP_MAXY], bounds[MAP_MAXZ])))
			//we do this after we load everything in. if we don't, we'll have weird atmos bugs regarding atmos adjacent turfs
			T.AfterChange(CHANGETURF_IGNORE_AIR)

	if(expanded_x || expanded_y || expanded_z)
		world.refresh_atmos_grid()

	#ifdef TESTING
	if(turfsSkipped)
		testing("Skipped loading [turfsSkipped] default turfs")
	#endif

	return sucessful

// Wanna clear something up about maps, talking in 255x255 here
// In the tgm format, each gridset contains 255 lines, each line representing one tile, with 255 total gridsets
// In the dmm format, each gridset contains 255 lines, each line representing one row of tiles, containing 255 * line length characters, with one gridset per z
// You can think of dmm as storing maps in rows, whereas tgm stores them in columns
/datum/parsed_map/proc/_tgm_load(x_offset, y_offset, z_offset, cropMap, no_changeturf, x_lower, x_upper, y_lower, y_upper, placeOnTop, new_z)
	// setup
	var/list/modelCache = build_cache(no_changeturf)
	var/space_key = modelCache[SPACE_KEY]
	var/list/bounds
	src.bounds = bounds = list(1.#INF, 1.#INF, 1.#INF, -1.#INF, -1.#INF, -1.#INF)

	// Building y coordinate ranges
	var/y_relative_to_absolute = y_offset - 1
	var/x_relative_to_absolute = x_offset - 1

	// Ok so like. something important
	// We talk in "relative" coords here, so the coordinate system of the map datum
	// This is so we can do offsets, but it is NOT the same as positions in game
	// That's why there's some uses of - y_relative_to_absolute here, to turn absolute positions into relative ones
	// TGM maps process in columns, so the starting y will always be the max size
	// We know y starts at 1
	var/datum/grid_set/first_column = gridSets[1]
	var/relative_y = first_column.ycrd
	var/highest_y = relative_y + y_relative_to_absolute

	if(!cropMap && highest_y > world.maxy)
		world.maxy = highest_y // Expand Y here. X is expanded later on
		expanded_y = TRUE

	// Skip Y coords that are above the smallest of the three params
	// So maxy and y_upper get to act as thresholds, and relative_y can play
	var/y_skip_above = min(world.maxy - y_relative_to_absolute, y_upper, relative_y)
	// How many lines to skip because they'd be above the y cuttoff line
	var/y_starting_skip = relative_y - y_skip_above
	highest_y += y_starting_skip


	// Y is the LOWEST it will ever be here, so we can easily set a threshold for how low to go
	var/line_count = length(first_column.gridLines)
	var/lowest_y = relative_y - (line_count - 1) // -1 because we decrement at the end of the loop, not the start
	var/y_ending_skip = max(max(y_lower, 1 - y_relative_to_absolute) - lowest_y, 0)

	// X setup
	var/x_delta_with = x_upper
	if(cropMap)
		// Take our smaller crop threshold yes?
		x_delta_with = min(x_delta_with, world.maxx)

	// We're gonna skip all the entries above the upper x, or maxx if cropMap is set
	// The last column is guarenteed to have the highest x value we;ll encounter
	// Even if z scales, this still works
	var/datum/grid_set/last_column = gridSets[length(gridSets)]
	var/final_x = last_column.xcrd + x_relative_to_absolute

	if(final_x > x_delta_with)
		// If our relative x is greater then X upper, well then we've gotta limit our expansion
		var/delta = max(final_x - x_delta_with, 0)
		final_x -= delta
	if(final_x > world.maxx && !cropMap)
		world.maxx = final_x
		expanded_x = TRUE

	var/lowest_x = max(x_lower, 1 - x_relative_to_absolute)

	// We make the assumption that the last block of turfs will have the highest embedded z in it
	var/highest_z = last_column.zcrd + z_offset - 1 // Lets not just make a new z level each time we increment maxz
	var/z_threshold = world.maxz
	if(highest_z > z_threshold && cropMap)
		for(var/i in z_threshold + 1 to highest_z) //create a new z_level if needed
			world.incrementMaxZ()
			expanded_z = TRUE
		if(!no_changeturf)
			WARNING("Z-level expansion occurred without no_changeturf set, this may cause problems when /turf/AfterChange is called")

	for(var/datum/grid_set/gset as anything in gridSets)
		var/true_xcrd = gset.xcrd + x_relative_to_absolute

		// any cutoff of x means we just shouldn't iterate this gridset
		if(final_x < true_xcrd || lowest_x > gset.xcrd)
			continue

		var/zcrd = gset.zcrd + z_offset - 1
		// If we're using changeturf, we disable it if we load into a z level we JUST created
		var/no_afterchange = no_changeturf || zcrd > z_threshold

		// We're gonna track the first and last pairs of coords we find
		// Since x is always incremented in steps of 1, we only need to deal in y
		// The first x is guarenteed to be the lowest, the first y the highest, and vis versa
		// This is faster then doing mins and maxes inside the hot loop below
		var/first_found = FALSE
		var/first_y = 0
		var/last_y = 0

		var/ycrd = highest_y
		// Everything following this line is VERY hot.
		for(var/i in 1 + y_starting_skip to line_count - y_ending_skip)
			if(gset.gridLines[i] == space_key && no_afterchange)
				#ifdef TESTING
				++turfsSkipped
				#endif
				ycrd--
				MAPLOADING_CHECK_TICK
				continue

			var/list/cache = modelCache[gset.gridLines[i]]
			if(!cache)
				SSatoms.map_loader_stop(REF(src))
				CRASH("Undefined model key in DMM: [gset.gridLines[i]]")
			build_coordinate(loaded_areas, cache, locate(true_xcrd, ycrd, zcrd), no_afterchange, placeOnTop, new_z)

			// only bother with bounds that actually exist
			if(!first_found)
				first_found = TRUE
				first_y = ycrd
			last_y = ycrd
			ycrd--
			MAPLOADING_CHECK_TICK

		// The x coord never changes, so not tracking first x is safe
		// If no ycrd is found, we assume this row is totally empty and just continue on
		if(first_found)
			bounds[MAP_MINX] = min(bounds[MAP_MINX], true_xcrd)
			bounds[MAP_MINY] = min(bounds[MAP_MINY], last_y)
			bounds[MAP_MINZ] = min(bounds[MAP_MINZ], zcrd)
			bounds[MAP_MAXX] = max(bounds[MAP_MAXX], true_xcrd)
			bounds[MAP_MAXY] = max(bounds[MAP_MAXY], first_y)
			bounds[MAP_MAXZ] = max(bounds[MAP_MAXZ], zcrd)
	return TRUE

/// Stanrdard loading, not used in production
/// Doesn't take advantage of any tgm optimizations, which makes it slower but also more general
/// Use this if for some reason your map format is messy
/datum/parsed_map/proc/_dmm_load(x_offset, y_offset, z_offset, cropMap, no_changeturf, x_lower, x_upper, y_lower, y_upper, placeOnTop, new_z)
	// setup
	var/list/modelCache = build_cache(no_changeturf)
	var/space_key = modelCache[SPACE_KEY]
	var/list/bounds
	var/key_len = src.key_len
	src.bounds = bounds = list(1.#INF, 1.#INF, 1.#INF, -1.#INF, -1.#INF, -1.#INF)

	var/y_relative_to_absolute = y_offset - 1
	var/x_relative_to_absolute = x_offset - 1
	var/line_len = src.line_len
	for(var/datum/grid_set/gset as anything in gridSets)
		var/relative_x = gset.xcrd
		var/relative_y = gset.ycrd
		var/true_xcrd = relative_x + x_relative_to_absolute
		var/ycrd = relative_y + y_relative_to_absolute
		var/zcrd = gset.zcrd + z_offset - 1
		if(!cropMap && ycrd > world.maxy)
			world.maxy = ycrd // Expand Y here.  X is expanded in the loop below
			expanded_y = TRUE
		var/zexpansion = zcrd > world.maxz
		var/no_afterchange = no_changeturf
		if(zexpansion)
			if(cropMap)
				continue
			else
				while (zcrd > world.maxz) //create a new z_level if needed
					world.incrementMaxZ()
					expanded_z = FALSE
			if(!no_changeturf)
				WARNING("Z-level expansion occurred without no_changeturf set, this may cause problems when /turf/AfterChange is called")
				no_afterchange = TRUE
		// Ok so like. something important
		// We talk in "relative" coords here, so the coordinate system of the map datum
		// This is so we can do offsets, but it is NOT the same as positions in game
		// That's why there's some uses of - y_relative_to_absolute here, to turn absolute positions into relative ones

		// Skip Y coords that are above the smallest of the three params
		// So maxy and y_upper get to act as thresholds, and relative_y can play
		var/y_skip_above = min(world.maxy - y_relative_to_absolute, y_upper, relative_y)
		// How many lines to skip because they'd be above the y cuttoff line
		var/y_starting_skip = relative_y - y_skip_above
		ycrd += y_starting_skip

		// Y is the LOWEST it will ever be here, so we can easily set a threshold for how low to go
		var/line_count = length(gset.gridLines)
		var/lowest_y = relative_y - (line_count - 1) // -1 because we decrement at the end of the loop, not the start
		var/y_ending_skip = max(max(y_lower, 1 - y_relative_to_absolute) - lowest_y, 0)

		// Now we're gonna precompute the x thresholds
		// We skip all the entries below the lower x, or 1
		var/starting_x_delta = max(max(x_lower, 1 - x_relative_to_absolute) - relative_x, 0)
		// The x loop counts by key length, so we gotta multiply here
		var/x_starting_skip = starting_x_delta * key_len
		true_xcrd += starting_x_delta

		// We're gonna skip all the entries above the upper x, or maxx if cropMap is set
		var/x_target = line_len - key_len + 1
		var/x_step_count = ROUND_UP(x_target / key_len)
		var/final_x = relative_x + (x_step_count - 1)
		var/x_delta_with = x_upper
		if(cropMap)
			// Take our smaller crop threshold yes?
			x_delta_with = min(x_delta_with, world.maxx)
		if(final_x > x_delta_with)
			// If our relative x is greater then X upper, well then we've gotta limit our expansion
			var/delta = max(final_x - x_delta_with, 0)
			x_step_count -= delta
			final_x -= delta
			x_target = x_step_count * key_len
		if(final_x > world.maxx && !cropMap)
			world.maxx = final_x
			expanded_x = TRUE

		// We're gonna track the first and last pairs of coords we find
		// The first x is guarenteed to be the lowest, the first y the highest, and vis versa
		// This is faster then doing mins and maxes inside the hot loop below
		var/first_found = FALSE
		var/first_x = 0
		var/first_y = 0
		var/last_x = 0
		var/last_y = 0

		// Everything following this line is VERY hot. How hot depends on the map format
		// (Yes this does mean dmm is technically faster to parse. shut up)
		for(var/i in 1 + y_starting_skip to line_count - y_ending_skip)
			var/line = gset.gridLines[i]

			var/xcrd = true_xcrd
			for(var/tpos in 1 + x_starting_skip to x_target step key_len)
				var/model_key = copytext(line, tpos, tpos + key_len)
				if(model_key == space_key && no_afterchange)
					#ifdef TESTING
					++turfsSkipped
					#endif
					MAPLOADING_CHECK_TICK
					++xcrd
					continue
				var/list/cache = modelCache[model_key]
				if(!cache)
					SSatoms.map_loader_stop(REF(src))
					CRASH("Undefined model key in DMM: [model_key]")
				build_coordinate(loaded_areas, cache, locate(xcrd, ycrd, zcrd), no_afterchange, placeOnTop, new_z)

				// only bother with bounds that actually exist
				if(!first_found)
					first_found = TRUE
					first_x = xcrd
					first_y = ycrd
				last_x = xcrd
				last_y = ycrd
				MAPLOADING_CHECK_TICK
				++xcrd
			ycrd--
			MAPLOADING_CHECK_TICK
		bounds[MAP_MINX] = min(bounds[MAP_MINX], first_x)
		bounds[MAP_MINY] = min(bounds[MAP_MINY], last_y)
		bounds[MAP_MINZ] = min(bounds[MAP_MINZ], zcrd)
		bounds[MAP_MAXX] = max(bounds[MAP_MAXX], last_x)
		bounds[MAP_MAXY] = max(bounds[MAP_MAXY], first_y)
		bounds[MAP_MAXZ] = max(bounds[MAP_MAXZ], zcrd)

	return TRUE

GLOBAL_LIST_EMPTY(map_model_default)

/datum/parsed_map/proc/build_cache(no_changeturf, bad_paths)
	if(map_format == MAP_TGM)
		return tgm_build_cache(no_changeturf, bad_paths)
	return dmm_build_cache(no_changeturf, bad_paths)

/datum/parsed_map/proc/tgm_build_cache(no_changeturf, bad_paths=null)
	if(modelCache && !bad_paths)
		return modelCache
	. = modelCache = list()
	var/list/grid_models = src.grid_models
	var/set_space = FALSE
	// Use where a list is needed, but where it will not be modified
	// Used here to remove the cost of needing to make a new list for each fields entry when it's set manually later
	var/static/list/default_list = GLOB.map_model_default // It's stupid, but it saves += list(list)
	var/static/list/wrapped_default_list = list(default_list) // It's stupid, but it saves += list(list)
	var/static/regex/var_edits = var_edits_tgm

	var/path_to_init = ""
	// Reference to the attributes list we're currently filling, if any
	var/list/current_attributes
	// If we are currently editing a path or not
	var/editing = FALSE
	for(var/model_key in grid_models)
		// We're going to split models by newline
		// This guarentees that each entry will be of interest to us
		// Then we'll process them step by step
		// Hopefully this reduces the cost from read_list that we'd otherwise have
		var/list/lines = splittext(grid_models[model_key], "\n")
		// Builds list of path/edits for later
		// Of note: we cannot preallocate them to save time in list expansion later
		// But fortunately lists allocate at least 8 entries normally anyway, and
		// We are unlikely to have more then that many members
		//will contain all members (paths) in model (in our example : /turf/unsimulated/wall)
		var/list/members = list()
		//will contain lists filled with corresponding variables, if any (in our example : list(icon_state = "rock") and list())
		var/list/members_attributes = list()

		/////////////////////////////////////////////////////////
		//Constructing members and corresponding variables lists
		////////////////////////////////////////////////////////
		// string representation of the path to init
		for(var/line in lines)
			// We do this here to avoid needing to check at each return statement
			// No harm in it anyway
			CHECK_TICK

			switch(line[length(line)])
				if(";") // Var edit, we'll apply it
					// Var edits look like \tname = value;
					// I'm gonna try capturing them with regex, since it ought to be the fastest here
					// Should hand back key = value
					var_edits.Find(line)
					var/value = parse_constant(var_edits.group[2])
					if(istext(value))
						value = apply_text_macros(value)
					current_attributes[var_edits.group[1]] = value
					continue // Keep on keeping on brother
				if("{") // Start of an edit, and so also the start of a path
					editing = TRUE
					current_attributes = list() // Init the list we'll be filling
					members_attributes += list(current_attributes)
					path_to_init = copytext(line, 1, -1)
				if(",") // Either the end of a path, or the end of an edit
					if(editing) // it was the end of a path
						editing = FALSE
						continue
					members_attributes += wrapped_default_list // We know this is a path, and we also know it has no vv's. so we'll just set this to the default list
					// Drop the last char mind
					path_to_init = copytext(line, 1, -1)
				if("}") // Gotta be the end of an area edit, let's check to be sure
					if(editing) // it was the end of an area edit (shouldn't do those anyhow)
						editing = FALSE
						continue
					stack_trace("ended a line on JUST a }, with no ongoing edit. What? Area shit?")
				else // If we're editing, this is a var edit entry. the last one in a stack, cause god hates me. Otherwise, it's an area
					if(editing) // I want inline I want inline I want inline
						// Var edits look like \tname = value;
						// I'm gonna try capturing them with regex, since it ought to be the fastest here
						// Should hand back key = value
						var_edits.Find(line)
						var/value = parse_constant(var_edits.group[2])
						if(istext(value))
							value = apply_text_macros(value)
						current_attributes[var_edits.group[1]] = value
						continue // Keep on keeping on brother

					members_attributes += wrapped_default_list // We know this is a path, and we also know it has no vv's. so we'll just set this to the default list
					path_to_init = line


			// Alright, if we've gotten to this point, our string is a path
			// Oh and we don't trim it, because we require no padding for these
			// Saves like 1.5 deciseconds
			var/atom_def = text2path(path_to_init) //path definition, e.g /obj/foo/bar

			if(!ispath(atom_def, /atom)) // Skip the item if the path does not exist.  Fix your crap, mappers!
				if(bad_paths)
					// Rare case, avoid the var to save time most of the time
					LAZYOR(bad_paths[copytext(line, 1, -1)], model_key)
				continue
			// Index is already incremented either way, just gotta set the path and all
			members += atom_def

		//check and see if we can just skip this turf
		//So you don't have to understand this horrid statement, we can do this if
		// 1. the space_key isn't set yet
		// 2. no_changeturf is set
		// 3. there are exactly 2 members
		// 4. with no attributes
		// 5. and the members are world.turf and world.area
		// Basically, if we find an entry like this: "XXX" = (/turf/default, /area/default)
		// We can skip calling this proc every time we see XXX
		if(!set_space \
			&& no_changeturf \
			&& members_attributes.len == 2 \
			&& members.len == 2 \
			&& members_attributes[1] == default_list \
			&& members_attributes[2] == default_list \
			&& members[2] == world.area \
			&& members[1] == world.turf
		)
			set_space = TRUE
			.[SPACE_KEY] = model_key
			continue

		.[model_key] = list(members, members_attributes)
	return .

/// Builds key caches for general formats
/// Slower then the proc above, tho it could still be optimized slightly. it's just not a priority
/// Since we don't run DMM maps, ever.
/datum/parsed_map/proc/dmm_build_cache(no_changeturf, bad_paths=null)
	if(modelCache && !bad_paths)
		return modelCache
	. = modelCache = list()
	var/list/grid_models = src.grid_models
	var/set_space = FALSE
	// Use where a list is needed, but where it will not be modified
	// Used here to remove the cost of needing to make a new list for each fields entry when it's set manually later
	var/static/list/default_list = list(GLOB.map_model_default)
	for(var/model_key in grid_models)
		//will contain all members (paths) in model (in our example : /turf/unsimulated/wall)
		var/list/members = list()
		//will contain lists filled with corresponding variables, if any (in our example : list(icon_state = "rock") and list())
		var/list/members_attributes = list()

		var/model = grid_models[model_key]
		/////////////////////////////////////////////////////////
		//Constructing members and corresponding variables lists
		////////////////////////////////////////////////////////

		var/model_index = 1
		while(model_path.Find(model, model_index))
			var/variables_start = 0
			var/member_string = model_path.group[1]
			model_index = model_path.next
			//findtext is a bit expensive, lets only do this if the last char of our string is a } (IE: we know we have vars)
			//this saves about 25 miliseconds on my machine. Not a major optimization
			if(member_string[length(member_string)] == "}")
				variables_start = findtext(member_string, "{")

			var/path_text = TRIM_TEXT(copytext(member_string, 1, variables_start))
			var/atom_def = text2path(path_text) //path definition, e.g /obj/foo/bar

			if(!ispath(atom_def, /atom)) // Skip the item if the path does not exist.  Fix your crap, mappers!
				if(bad_paths)
					LAZYOR(bad_paths[path_text], model_key)
				continue
			members += atom_def

			//transform the variables in text format into a list (e.g {var1="derp"; var2; var3=7} => list(var1="derp", var2, var3=7))
			// OF NOTE: this could be made faster by replacing readlist with a progressive regex
			// I'm just too much of a bum to do it rn, especially since we mandate tgm format for any maps in repo
			var/list/fields = default_list
			if(variables_start)//if there's any variable
				member_string = copytext(member_string, variables_start + length(member_string[variables_start]), -length(copytext_char(member_string, -1))) //removing the last '}'
				fields = list(readlist(member_string, ";"))
				for(var/I in fields)
					var/value = fields[I]
					if(istext(value))
						fields[I] = apply_text_macros(value)

			//then fill the members_attributes list with the corresponding variables
			members_attributes += fields
			CHECK_TICK

		//check and see if we can just skip this turf
		//So you don't have to understand this horrid statement, we can do this if
		// 1. the space_key isn't set yet
		// 2. no_changeturf is set
		// 3. there are exactly 2 members
		// 4. with no attributes
		// 5. and the members are world.turf and world.area
		// Basically, if we find an entry like this: "XXX" = (/turf/default, /area/default)
		// We can skip calling this proc every time we see XXX
		if(!set_space \
			&& no_changeturf \
			&& members.len == 2 \
			&& members_attributes.len == 2 \
			&& length(members_attributes[1]) == 0 \
			&& length(members_attributes[2]) == 0 \
			&& (world.area in members) \
			&& (world.turf in members))
			set_space = TRUE
			.[SPACE_KEY] = model_key
			continue

		.[model_key] = list(members, members_attributes)
	return .

/datum/parsed_map/proc/build_coordinate(list/area_cache, list/model, turf/crds, no_changeturf as num, placeOnTop as num, new_z)
	SHOULD_NOT_SLEEP(TRUE)
	// If we don't have a turf, nothing we will do next will actually acomplish anything, so just go back
	// Note, this would actually drop area vvs in the tile, but like, why tho
	if(!crds)
		return
	var/index
	var/list/members = model[1]
	var/list/members_attributes = model[2]

	// We use static lists here because it's cheaper then passing them around
	var/static/list/default_list = GLOB.map_model_default
	////////////////
	//Instanciation
	////////////////

	if(turf_blacklist?[crds])
		return

	//Keep a reference to the original area in case we need to tell it to generate this turf later
	var/area/orig_area = crds.loc

	//The next part of the code assumes there's ALWAYS an /area AND a /turf on a given tile
	//first instance the /area and remove it from the members list
	index = members.len
	if(members[index] != /area/template_noop)
		var/area/area_instance
		if(members_attributes[index] != default_list)
			world.preloader_setup(members_attributes[index], members[index])//preloader for assigning  set variables on atom creation
		area_instance = area_cache[members[index]]
		if(!area_instance)
			var/area_type = members[index]
			// If this parsed map doesn't have that area already, we check the global cache
			area_instance = GLOB.areas_by_type[area_type]
			// If the global list DOESN'T have this area it's either not a unique area, or it just hasn't been created yet
			if (!area_instance)
				area_instance = new area_type(null)
				if(!area_instance)
					CRASH("[area_type] failed to be new'd, what'd you do?")
			area_cache[area_type] = area_instance

		if(!new_z)
			var/area/old_area = crds.loc
			old_area.turfs_to_uncontain += crds
			area_instance.contained_turfs.Add(crds)
		area_instance.contents.Add(crds)

		if(GLOB.use_preloader)
			world.preloader_load(area_instance)
	else
		orig_area = null // We won't be messing with the old area, null it



	// Index right before /area is /turf
	index--
	var/atom/instance
	//then instance the /turf
	//NOTE: this used to place any turfs before the last "underneath" it using .appearance and underlays
	//We don't actually use this, and all it did was cost cpu, so we don't do this anymore
	if(ispath(members[index], /turf/template_noop))
		if(istype(crds, /turf/open/genturf))
			var/turf/open/genturf/genturf = crds
			//If the new area is different from the original area, ensure the new turfs are generated as part of the original area
			if(orig_area && orig_area.type != members[index])
				LAZYADD(orig_area.additional_genturfs, crds)
			//Cave generation checks current area flags for generation; ignore them
			genturf.force_generation = TRUE
			//Pass on any hints for whether the turf should be open or closed
			if(ispath(members[index], /turf/template_noop/closed))
				genturf.genturf_hint = GENTURF_HINT_CLOSED
			else if(ispath(members[index], /turf/template_noop/open))
				genturf.genturf_hint = GENTURF_HINT_OPEN
	else
		if(members_attributes[index] != default_list)
			world.preloader_setup(members_attributes[index], members[index])

		// Note: we make the assertion that the last path WILL be a turf. if it isn't, this will fail.
		if(placeOnTop && !istype(crds, /turf/open/genturf))
			instance = crds.PlaceOnTop(null, members[index], CHANGETURF_DEFER_CHANGE | (no_changeturf ? CHANGETURF_SKIP : NONE))
		else if(no_changeturf)
			instance = create_atom(members[index], crds)//first preloader pass
		else
			instance = crds.ChangeTurf(members[index], null, CHANGETURF_DEFER_CHANGE)

		if(GLOB.use_preloader && instance)//second preloader pass, for those atoms that don't ..() in New()
			world.preloader_load(instance)

	//finally instance all remainings objects/mobs
	for(var/atom_index in 1 to index-1)
		if(members_attributes[atom_index] != default_list)
			world.preloader_setup(members_attributes[atom_index], members[atom_index])

		// We make the assertion that only /atom s will be in this portion of the code. if that isn't true, this will fail
		instance = create_atom(members[atom_index], crds)//first preloader pass

		if(GLOB.use_preloader && instance)//second preloader pass, for those atoms that don't ..() in New()
			world.preloader_load(instance)

////////////////
//Helpers procs
////////////////

/datum/parsed_map/proc/create_atom(path, crds)
	set waitfor = FALSE
	. = new path (crds)

//find the position of the next delimiter,skipping whatever is comprised between opening_escape and closing_escape
//returns 0 if reached the last delimiter
/datum/parsed_map/proc/find_next_delimiter_position(text as text,initial_position as num, delimiter=",",opening_escape="\"",closing_escape="\"")
	var/position = initial_position
	var/next_delimiter = findtext(text,delimiter,position,0)
	var/next_opening = findtext(text,opening_escape,position,0)

	while((next_opening != 0) && (next_opening < next_delimiter))
		position = findtext(text,closing_escape,next_opening + 1,0)+1
		next_delimiter = findtext(text,delimiter,position,0)
		next_opening = findtext(text,opening_escape,position,0)

	return next_delimiter

//build a list from variables in text form (e.g {var1="derp"; var2; var3=7} => list(var1="derp", var2, var3=7))
//return the filled list
/datum/parsed_map/proc/readlist(text as text, delimiter=",")
	. = list()
	if (!text)
		return

	// If we're using a semi colon, we can do this as splittext rather then constant calls to find_next_delimiter_position
	// This does make the code a bit harder to read, but saves a good bit of time so suck it up
	var/position
	var/old_position = 1
	while(position != 0)
		// find next delimiter that is not within  "..."
		position = find_next_delimiter_position(text,old_position,delimiter)

		// check if this is a simple variable (as in list(var1, var2)) or an associative one (as in list(var1="foo",var2=7))
		var/equal_position = findtext(text,"=",old_position, position)
		var/trim_left = TRIM_TEXT(copytext(text,old_position,(equal_position ? equal_position : position)))
		var/left_constant = parse_constant(trim_left)
		if(position)
			old_position = position + length(text[position])
		if(!left_constant) // damn newlines man. Exists to provide behavior consistency with the above loop. not a major cost becuase this path is cold
			continue

		if(equal_position && !isnum_safe(left_constant))
			// Associative var, so do the association.
			// Note that numbers cannot be keys - the RHS is dropped if so.
			var/trim_right = TRIM_TEXT(copytext(text, equal_position + length(text[equal_position]), position))
			var/right_constant = parse_constant(trim_right)
			.[left_constant] = right_constant
		else  // simple var
			. += list(left_constant)

/datum/parsed_map/proc/parse_constant(text)
	// number
	var/num = text2num(text)
	if(isnum_safe(num))
		return num

	// string
	if(text[1] == "\"")
		// insert implied locate \" and length("\"") here
		// It's a minimal timesave but it is a timesave
		// Safe becuase we're guarenteed trimmed constants
		return copytext(text, 2, -1)

	// list
	if(copytext(text, 1, 6) == "list(")//6 == length("list(") + 1
		return readlist(copytext(text, 6, -1))

	// typepath
	var/path = text2path(text)
	if(ispath(path))
		return path

	// file
	if(text[1] == "'")
		return file(copytext_char(text, 2, -1))

	// null
	if(text == "null")
		return null

	// not parsed:
	// - pops: /obj{name="foo"}
	// - new(), newlist(), icon(), matrix(), sound()

	// fallback: string
	return text

/datum/parsed_map/Destroy()
	..()
	SSatoms.map_loader_stop(REF(src)) // Just in case, I don't want to double up here
	if(turf_blacklist)
		turf_blacklist.Cut()
	parsed_bounds.Cut()
	bounds.Cut()
	grid_models.Cut()
	gridSets.Cut()
	return QDEL_HINT_HARDDEL_NOW
