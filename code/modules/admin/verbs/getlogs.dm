//This proc allows download of past server logs saved within the data/logs/ folder.
/client/proc/getserverlogs()
	set name = "Get Server Logs"
	set desc = "View/retrieve logfiles."
	set category = "Admin"

	browseserverlogs()

/client/proc/getcurrentlogs()
	set name = "Get Current Logs"
	set desc = "View/retrieve logfiles for the current round."
	set category = "Admin"

	browseserverlogs("[GLOB.log_directory]/")

/client/proc/browseserverlogs(path = "data/logs/")
	if(IsAdminAdvancedProcCall())
		log_admin_private("BROWSEFILES: Admin proc call blocked")
		message_admins("BROWSEFILES: Admin proc call blocked")
		return null

	if(file_spam_check())
		return

	path = browse_files(path)
	if(!path)
		return

	var/datum/admin_ui_component/log_reader/log_reader = GLOB.admin_ui.active_uis["log_reader"]
	if(!log_reader)
		message_admins("Major error: Please contact coders (Log reader was not initialised (THIS SHOULD BE IMPOSSIBLE))")
		message_admins("Warning: Using backup log browser")

	var/options = alert("View (in game), Open (in your system's text editor), or Download?", path, "View", "Open", "Download")

	if(!options)
		return

	//Legacy Browser
	message_admins("[key_name_admin(src)] accessed file: [path]")
	if(!log_reader || (options in list("Open", "Download")))
		switch(options)
			if ("View")
				src << browse("<pre style='word-wrap: break-word;'>[html_encode(file2text(file(path)))]</pre>", list2params(list("window" = "viewfile.[path]")))
			if ("Open")
				src << run(file(path))
			if ("Download")
				src << ftp(file(path))
			else
				return
		to_chat(src, "Attempting to send [path], this may take a fair few minutes if the file is very large.")
		return
	//New and improved :glasses:
	log_reader.requested_file["[key_name_admin(src)]"] = path
	GLOB.admin_ui.display_ui("log_reader", mob)
	return

/datum/admin_ui_component/log_reader
	unique_id = "log_reader"
	default_ui_key = "log_reader"
	default_ui_name = "LogReader"
	window_name = "Log Viewer"
	width = 860
	height = 720
	var/list/requested_file

/datum/admin_ui_component/log_reader/New()
	. = ..()
	requested_file = list()

/datum/admin_ui_component/log_reader/ui_static_data(mob/user)
	var/list/data = list()
	//Get user
	if(!user.client)
		return
	var/path = requested_file["[key_name_admin(user.client)]"]
	if(!path)
		return
	//Get logs
	var/list/log_lines = splittext(html_encode(file2text(file(path))), "\n")
	data["logs"] = log_lines
	return data
