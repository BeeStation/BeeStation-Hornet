/client/proc/forcerandomrotate()
	set category = "Server"
	set name = "Trigger Random Map Rotation"
	var/rotate = alert("Force a random map rotation to trigger?", "Rotate map?", "Yes", "Cancel")
	if (rotate != "Yes")
		return
	message_admins("[key_name_admin(usr)] is forcing a random map rotation.")
	log_admin("[key_name(usr)] is forcing a random map rotation.")
	SSticker.maprotatechecked = 1
	SSmapping.maprotate()

/client/proc/adminchangemap()
	set category = "Server"
	set name = "Change Map"

	var/list/maprotatechoices = list()
	for (var/map in config.maplist)
		var/datum/map_config/VM = config.maplist[map]
		var/mapname = VM.map_name
		if (VM == config.defaultmap)
			mapname += " (Default)"

		if (VM.config_min_users > 0 || VM.config_max_users > 0)
			mapname += " \["
			if (VM.config_min_users > 0)
				mapname += "[VM.config_min_users]"
			else
				mapname += "0"
			mapname += "-"
			if (VM.config_max_users > 0)
				mapname += "[VM.config_max_users]"
			else
				mapname += "inf"
			mapname += "\]"

		maprotatechoices[mapname] = VM
	var/chosenmap = input("Choose a map to change to", "Change Map")  as null|anything in sort_list(maprotatechoices)
	if (!chosenmap)
		return
	SSticker.maprotatechecked = 1
	var/datum/map_config/VM = maprotatechoices[chosenmap]
	message_admins("[key_name_admin(usr)] is changing the map to [VM.map_name]")
	log_admin("[key_name(usr)] is changing the map to [VM.map_name]")
	if (SSmapping.changemap(VM) == 0)
		message_admins("[key_name_admin(usr)] has changed the map to [VM.map_name]")

/client/proc/forcemapconfig()
	set category = "Debug"
	set name = "Debug Force Map"

	//Locked behind permissions since it needs serious protection.
	if(!check_rights(R_DEBUG) || !check_rights(R_SERVER))
		to_chat(src, "<span class='warning'>Insufficient rights (Requires debug and server).</span>")
		return

	var/json_settings = input(usr, "Enter map json name:", "Map Json Name", "") as text|null

	if(!json_settings)
		return

	var/datum/map_config/config = new
	if(!config.LoadConfig("_maps/[json_settings].json", TRUE))
		qdel(config)
		to_chat(usr, "<span class='warning'>Map json failed to load!</span>")
		return
	SSticker.maprotatechecked = 1
	message_admins("[key_name_admin(usr)] is changing the map to [config.map_name]")
	log_admin("[key_name(usr)] is changing the map to [config.map_name]")
	if (SSmapping.changemap(config) == 0)
		message_admins("[key_name_admin(usr)] has changed the map to [config.map_name]")
