
#define SAFE_SAVEPATH "data/customShuttleSaves/"

/client/proc/download_shuttle_files()
	set name = "Saved Shuttles - Download"
	set category = "Admin"

	if(!check_rights(R_ADMIN))
		to_chat(src, "<span class='warning'>You do not have sufficient access to download saved shuttle files! (Requires R_ADMIN)</span>")
		return

	//Major security flaw if server ops set this up wrong.
	var/basepath = CONFIG_GET(string/shuttle_ruin_filepath)
	if(!basepath)
		return

	var/regex/safe_path_regex = new("^data/\\w*/$", "g")

	//Check for an unsafe filepath.
	//data/log or config/ instead of data/.../
	//shuttle_ruin_filepath is a protected config value so shouldn't be able to change but just in case
	//the host messes up the config, or a major exploit is found, make sure only the trusted people can access this.
	if(!findtext(basepath, safe_path_regex))
		message_admins("!!WARNING!! Server shuttle data is saved to [basepath] which has been determined to be an unsafe directory. Please contact your server host. (Shuttle save files should be located in a path of 'data/.../')")
		message_admins("As a result, accessing shuttle save data will require R_SERVER instead of R_ADMIN.")
		log_game("!!WARNING!! Server shuttle data is saved to [basepath] which has been determined to be an unsafe directory. Please contact your server host. (Shuttle save files should be located in a path of 'data/.../')")
		if(!check_rights(R_SERVER))
			to_chat(src, "<span class='boldwarning'>THIS SERVER HAS THE SHUTTLE RUIN SAVE DIRECTORY IN AN UNSAFE LOCATION. YOU REQUIRE R_SERVER TO VIEW THE CONTENTS OF THIS FILE.</span>")
			return

	//File spam check
	if(file_spam_check())
		return

	//Log
	log_game("[key_name_admin(src)] is accessing the contents of [basepath] (Shuttle save directory).")
	message_admins("[key_name_admin(src)] is accessing the contents of [basepath] (Shuttle save directory).")

	//List the contents of the file
	var/files = flist(basepath)
	var/file_to_download = input(src, "Select a shuttle file to download.", "Shuttle Map Download") as null|anything in files

	//Verify selected file
	if(!file_to_download)
		return

	var/path = "[basepath][file_to_download]"

	//Transmit the file
	message_admins("[key_name_admin(src)] accessed file: [path]")
	switch(alert("View (in game), Open (in your system's text editor), or Download?", path, "View", "Open", "Download"))
		if ("View")
			src << browse("<pre style='word-wrap: break-word;'>[html_encode(rustg_file_read(file(path)))]</pre>", list2params(list("window" = "viewfile.[path]")))
		if ("Open")
			src << run(file(path))
		if ("Download")
			src << ftp(file(path))
		else
			return
	to_chat(src, "Attempting to send [path], this may take a fair few minutes if the file is very large.")

/client/proc/delete_shuttle_file()
	set name = "Saved Shuttles - Delete"
	set category = "Admin"

	if(!check_rights(R_ADMIN))
		to_chat(src, "<span class='warning'>You do not have sufficient access to download saved shuttle files! (Requires R_ADMIN)</span>")
		return

	//Major security flaw if server ops set this up wrong.
	var/basepath = CONFIG_GET(string/shuttle_ruin_filepath)
	if(!basepath)
		return

	var/regex/safe_path_regex = new("^data/\\w*/$", "g")

	//Check for an unsafe filepath.
	//data/log or config/ instead of data/.../
	//shuttle_ruin_filepath is a protected config value so shouldn't be able to change but just in case
	//the host messes up the config, or a major exploit is found, make sure only the trusted people can access this.
	if(!findtext(basepath, safe_path_regex))
		message_admins("!!WARNING!! Server shuttle data is saved to [basepath] which has been determined to be an unsafe directory. Please contact your server host. (Shuttle save files should be located in a path of 'data/.../')")
		message_admins("As a result, accessing shuttle save data will require R_SERVER instead of R_ADMIN.")
		log_game("!!WARNING!! Server shuttle data is saved to [basepath] which has been determined to be an unsafe directory. Please contact your server host. (Shuttle save files should be located in a path of 'data/.../')")
		if(!check_rights(R_SERVER))
			to_chat(src, "<span class='boldwarning'>THIS SERVER HAS THE SHUTTLE RUIN SAVE DIRECTORY IN AN UNSAFE LOCATION. YOU REQUIRE R_SERVER TO VIEW THE CONTENTS OF THIS FILE.</span>")
			return

	//File spam check
	if(file_spam_check())
		return

	//Log
	log_game("[key_name_admin(src)] is deleting something from the contents of [basepath] (Shuttle save directory).")
	message_admins("[key_name_admin(src)] is deleting something from the contents of [basepath] (Shuttle save directory).")

	//List the contents of the file
	var/files = flist(basepath)
	var/file_to_delete = input(src, "Select a shuttle file to delete.", "Shuttle Map Deletion") as null|anything in files

	//Verify selected file
	if(!file_to_delete)
		return

	//Get the path
	var/path = "[basepath][file_to_delete]"

	//Delete the file
	fdel(path)

/client/proc/spawn_saved_shuttle()
	set name = "Saved Shuttles - View"
	set category = "Admin"

	if(!check_rights(R_ADMIN))
		to_chat(src, "<span class='warning'>You do not have sufficient access to download saved shuttle files! (Requires R_ADMIN)</span>")
		return

	//Major security flaw if server ops set this up wrong.
	var/basepath = CONFIG_GET(string/shuttle_ruin_filepath)
	if(!basepath)
		return

	var/regex/safe_path_regex = new("^data/\\w*/$", "g")

	//Check for an unsafe filepath.
	//data/log or config/ instead of data/.../
	//shuttle_ruin_filepath is a protected config value so shouldn't be able to change but just in case
	//the host messes up the config, or a major exploit is found, make sure only the trusted people can access this.
	if(!findtext(basepath, safe_path_regex))
		message_admins("!!WARNING!! Server shuttle data is saved to [basepath] which has been determined to be an unsafe directory. Please contact your server host. (Shuttle save files should be located in a path of 'data/.../')")
		message_admins("As a result, accessing shuttle save data will require R_SERVER instead of R_ADMIN.")
		log_game("!!WARNING!! Server shuttle data is saved to [basepath] which has been determined to be an unsafe directory. Please contact your server host. (Shuttle save files should be located in a path of 'data/.../')")
		if(!check_rights(R_SERVER))
			to_chat(src, "<span class='boldwarning'>THIS SERVER HAS THE SHUTTLE RUIN SAVE DIRECTORY IN AN UNSAFE LOCATION. YOU REQUIRE R_SERVER TO VIEW THE CONTENTS OF THIS FILE.</span>")
			return

	//File spam check
	if(file_spam_check())
		return

	//Log
	log_game("[key_name_admin(src)] is spawning something from the contents of [basepath] (Shuttle save directory).")
	message_admins("[key_name_admin(src)] is spawning something from the contents of [basepath] (Shuttle save directory).")

	//List the contents of the file
	var/files = flist(basepath)
	var/file_to_delete = input(src, "Select a shuttle file to spawn.", "Shuttle Map Spawning") as null|anything in files

	//Verify selected file
	if(!file_to_delete)
		return

	//Get the path
	var/path = "[basepath][file_to_delete]"

	//Generate the tempalte
	var/datum/map_template/shuttle/abandoned_template = new(path, "abandoned shuttle [rand(1, 99999)]")

	//Load the preview
	SSshuttle.load_template(abandoned_template)

	//Teleport there
	var/turf/T = locate(SSshuttle.preview_reservation.bottom_left_coords[1], SSshuttle.preview_reservation.bottom_left_coords[2], SSshuttle.preview_reservation.bottom_left_coords[3])
	mob.forceMove(T)
