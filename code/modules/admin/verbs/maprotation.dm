/client/proc/admin_change_map()
	set category = "Server"
	set name = "Change Map"

	var/list/maprotatechoices = list()
	for (var/map in config.maplist)
		var/datum/map_config/virtual_map = config.maplist[map]
		var/mapname = virtual_map.map_name
		if (virtual_map == config.defaultmap)
			mapname += " (Default)"

		if (virtual_map.config_min_users > 0 || virtual_map.config_max_users > 0)
			mapname += " \["
			if (virtual_map.config_min_users > 0)
				mapname += "[virtual_map.config_min_users]"
			else
				mapname += "0"
			mapname += "-"
			if (virtual_map.config_max_users > 0)
				mapname += "[virtual_map.config_max_users]"
			else
				mapname += "inf"
			mapname += "\]"

		maprotatechoices[mapname] = virtual_map
	var/chosenmap = tgui_input_list(usr, "Choose a map to change to", "Change Map", sort_list(maprotatechoices)|"Custom")
	if (isnull(chosenmap))
		return

	var/datum/map_config/virtual_map = maprotatechoices[chosenmap]
	message_admins("[key_name_admin(usr)] is changing the map to [virtual_map.map_name]")
	log_admin("[key_name(usr)] is changing the map to [virtual_map.map_name]")
	if (SSmap_vote.set_next_map(virtual_map))
		message_admins("[key_name_admin(usr)] has changed the map to [virtual_map.map_name]")
		SSmap_vote.admin_override = TRUE

/client/proc/admin_revert_map()
	set category = "Server"
	set name = "Revert Map Vote"

	SSmap_vote.revert_next_map(usr)
