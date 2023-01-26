SUBSYSTEM_DEF(shuttle_persistence)
	name = "Shuttle Persistence"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_ORBITS
	//DMM files of shuttle ruins. Does not end with .dmm
	var/list/shuttle_ruin_list
	var/list/spawned_shuttle_files

/datum/controller/subsystem/shuttle_persistence/Initialize(start_timeofday)
	. = ..()
	//Fetch shuttle ruins
	spawned_shuttle_files = list()
	//Verify safe file integrity
	verify_save_files()
	//Create abandoned signal ruins
	if(length(shuttle_ruin_list))
		for(var/i in 1 to rand(1, min(length(shuttle_ruin_list), CONFIG_GET(number/roundstart_abandoned_ruins))))
			new /datum/orbital_object/z_linked/beacon/ruin/abandoned_shuttle()

/datum/controller/subsystem/shuttle_persistence/proc/verify_save_files()
	to_chat(world, "<span class='boldannounce'>Verifying shuttle save files...</span>")
	var/shuttle_path = CONFIG_GET(string/shuttle_ruin_filepath)
	for (var/file_path in flist(CONFIG_GET(string/shuttle_ruin_filepath)))
		// Skip
		if (copytext(file_path, -4) != ".dmm")
			continue
		// Get the file name
		var/path = "[shuttle_path][copytext(file_path, 1, length(file_path) - 3)]"
		var/map_file = "[path].dmm"
		var/type_file = "[path].types"
		// Failed to identify types
		if (!fexists(type_file))
			message_admins("Failed to locate typepath cache for [path], deleting map file...")
			fdel(map_file)
			continue
		// Verify types
		var/bad = FALSE
		var/identified_types = splittext(file2text(type_file), "\n")
		for (var/typepath in identified_types)
			if (length(typepath) && !ispath(text2path(typepath)))
				message_admins("Persistent shuttle file [path] contains outdated typepaths, removing...")
				fdel(map_file)
				fdel(type_file)
				bad = TRUE
				break
		// The file is valid
		if (!bad)
			shuttle_ruin_list += path
	to_chat(world, "<span class='boldannounce'>Shuttle save files verified successfully!...</span>")

//Saves custom shuttles
/datum/controller/subsystem/shuttle_persistence/proc/save_custom_shuttles()

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
		var/datum/exported_map/save_data = M.get_shuttle_tgm_data()
		//Calculate filesize (1 byte = 1 char)
		var/file_size = length(save_data)
		if(file_size > CONFIG_GET(number/shuttle_filesize_max) * 1000)
			message_admins("Custom shuttle [M] skipped due to being over the file size limit of [CONFIG_GET(number/shuttle_filesize_max) * 1000] bytes.")
			continue
		space_required += file_size
		//Save the shuttle file
		var/file_name_raw = "[shuttle_filepath]customshuttle_[GLOB.round_id]_[shuttles_saved]"
		var/file_name = "[file_name_raw].dmm"
		var/file_types_name = "[file_name_raw].types"
		if(fexists(file_name))
			fdel(file_name)
		if(fexists(file_types_name))
			fdel(file_types_name)
		text2file(save_data.output_data, file_name)
		text2file(jointext(save_data.get_types(), "\n"), file_types_name)
		//Log it
		shuttles_saved ++
		message_admins("Custom shuttle [M] successfully saved!")
		CHECK_TICK

	//Delete any shuttles we spawned since they would have been saved.
	//Rather than having 2 of the same ship, just remove the old one
	for(var/filepath in spawned_shuttle_files)
		//Save just the name.dmm so admins can't add anything to this list to delete any server file.
		//Doesn't need too much protection since admins can delete any shuttle they want anyway.
		fdel("[shuttle_filepath][filepath].dmm")
		fdel("[shuttle_filepath][filepath].types")

	//Clear old shuttles to free up space
	var/left_to_clear = max(current_size + space_required - (CONFIG_GET(number/shuttle_total_filesize_max) * 1000), 0)
	//Luck of the draw
	while(left_to_clear > 0 && length(old_files))
		var/first_thing = pick(old_files)
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
