//used for holding information about unique properties of maps
//feed it json files that match the datum layout
//defaults to box
//  -Cyberboss

/datum/map_config
	// Metadata
	var/config_filename = "_maps/boxstation.json"
	var/defaulted = TRUE  // set to FALSE by LoadConfig() succeeding
	// Config from maps.txt
	var/config_max_users = 0
	var/config_min_users = 0
	var/voteweight = 1
	var/votable = FALSE

	// Config actually from the JSON - should default to Box
	var/map_name = "Box Station"
	var/map_link = null //This is intentionally wrong, this will make it not link to webmap.
	var/map_path = "map_files/BoxStation"
	var/map_file = "BoxStation.dmm"

	//This should probably be refactored into a system like the regular configuration

	var/traits = null
	var/space_ruin_levels = 4	//Keep this low, as new ones are created dynamically when needed.
	var/space_empty_levels = 1

	///Type of the mining level to use
	var/minetype = "lavaland"

	///Does the map allow custom shuttles to be purchased
	var/allow_custom_shuttles = TRUE
	///Default list of json shuttles. Not all shuttles use this system; most use the template variable.
	var/shuttles = list(
		"cargo" = "cargo_box",
		"ferry" = "ferry_fancy",
		"whiteship" = "whiteship_box",
		"emergency" = "emergency_box")

	/// Is night lighting allowed to occur on this station?
	var/allow_night_lighting = TRUE

	//======
	// planetary Settings
	//======

	/// Is this station considered a planet for the supercruise map
	var/planetary_station = FALSE
	/// The name of the planet on the supercruise map
	var/planet_name = ""
	/// Radius of the planet
	var/planet_radius = 300
	/// Supercruise planet gravity
	var/planet_mass = 15000

	//======
	// Performance Settings
	//======

	/// Disable station level parallax. For levels which have no parallax background
	var/no_station_parallax = FALSE

/proc/load_map_config(filename = "next_map", foldername = DATA_DIRECTORY, default_to_box, delete_after, error_if_missing = TRUE)
	if(IsAdminAdvancedProcCall())
		return

	filename = "[foldername]/[filename].json"
	var/datum/map_config/config = new
	if (default_to_box)
		return config
	if (!config.LoadConfig(filename, error_if_missing))
		qdel(config)
		config = new /datum/map_config  // Fall back to Box
	else if (delete_after)
		fdel(filename)
	return config

#define CHECK_EXISTS(X) if(!istext(json[X])) { log_world("[##X] missing from json!"); return; }
/datum/map_config/proc/LoadConfig(filename, error_if_missing)
	if(!fexists(filename))
		if(error_if_missing)
			log_world("map_config not found: [filename]")
		return

	var/json = file(filename)
	if(!json)
		log_world("Could not open map_config: [filename]")
		return

	json = rustg_file_read(json)
	if(!json)
		log_world("map_config is not text: [filename]")
		return

	json = json_decode(json)
	if(!json)
		log_world("map_config is not json: [filename]")
		return

	config_filename = filename

	CHECK_EXISTS("map_name")
	map_name = json["map_name"]
	CHECK_EXISTS("map_path")
	map_path = json["map_path"]

	map_file = json["map_file"]
	// "map_file": "BoxStation.dmm"
	if (istext(map_file))
		if (!fexists("_maps/[map_path]/[map_file]"))
			log_world("Map file ([map_path]/[map_file]) does not exist!")
			return
	// "map_file": ["Lower.dmm", "Upper.dmm"]
	else if (islist(map_file))
		for (var/file in map_file)
			if (!fexists("_maps/[map_path]/[file]"))
				log_world("Map file ([map_path]/[file]) does not exist!")
				return
	else
		log_world("map_file missing from json!")
		return

	if (islist(json["shuttles"]))
		var/list/L = json["shuttles"]
		for(var/key in L)
			var/value = L[key]
			shuttles[key] = value
	else if ("shuttles" in json)
		log_world("map_config shuttles is not a list!")
		return

	traits = json["traits"]
	// "traits": [{"Linkage": "Cross"}, {"Space Ruins": true}]
	if (islist(traits))
		// "Station" is set by default, but it's assumed if you're setting
		// traits you want to customize which level is cross-linked
		for (var/level in traits)
			if (!(ZTRAIT_STATION in level))
				level[ZTRAIT_STATION] = TRUE
	// "traits": null or absent -> default
	else if (!isnull(traits))
		log_world("map_config traits is not a list!")
		return

	var/temp = json["space_ruin_levels"]
	if (isnum_safe(temp))
		space_ruin_levels = temp
	else if (!isnull(temp))
		log_world("map_config space_ruin_levels is not a number!")
		return

	temp = json["space_empty_levels"]
	if (isnum_safe(temp))
		space_empty_levels = temp
	else if (!isnull(temp))
		log_world("map_config space_empty_levels is not a number!")
		return

	if ("minetype" in json)
		minetype = json["minetype"]

	if("map_link" in json)
		map_link = json["map_link"]
	else
		log_world("map_link missing from json!")

	allow_custom_shuttles = json["allow_custom_shuttles"] != FALSE
	allow_night_lighting = json["allow_night_lighting"] != FALSE
	planetary_station = !isnull(json["planetary_station"]) && json["planetary_station"] != FALSE
	planet_name = json["planet_name"]
	planet_mass = text2num(json["planet_mass"]) || planet_mass
	planet_radius = text2num(json["planet_radius"]) || planet_radius

	defaulted = FALSE
	return TRUE
#undef CHECK_EXISTS

/datum/map_config/proc/GetFullMapPaths()
	if (istext(map_file))
		return list("_maps/[map_path]/[map_file]")
	. = list()
	for (var/file in map_file)
		. += "_maps/[map_path]/[file]"

/datum/map_config/proc/is_votable()
	var/below_max = !(config_max_users) || GLOB.clients.len <= config_max_users
	var/above_min = !(config_min_users) || GLOB.clients.len >= config_min_users
	return votable && below_max && above_min

/datum/map_config/proc/MakeNextMap()
	return config_filename == "data/next_map.json" || fcopy(config_filename, "data/next_map.json")
