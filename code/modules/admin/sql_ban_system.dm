#define MAX_ADMINBANS_PER_ADMIN 1
#define MAX_ADMINBANS_PER_HEADMIN 3

/// Process global ban types
/proc/check_role_ban(ban_cache, role)
	if(role in GLOB.antagonist_bannable_roles)
		if((BAN_ROLE_ALL_ANTAGONISTS in ban_cache) || ("Syndicate" in ban_cache)) // Legacy "Syndicate" ban
			return TRUE
	if(role in GLOB.forced_bannable_roles)
		if(BAN_ROLE_FORCED_ANTAGONISTS in ban_cache)
			return TRUE
	if(role in GLOB.ghost_role_bannable_roles)
		if((BAN_ROLE_ALL_GHOST in ban_cache) || ("Lavaland" in ban_cache)) // Legacy "Lavaland" ban
			return TRUE
	return role in ban_cache

//checks client ban cache or DB ban table if ckey is banned from one or more roles
//doesn't return any details, use only for if statements
/proc/is_banned_from(player_ckey, list/roles)
	if(!player_ckey || isnull(roles) || (islist(roles) && !length(roles)))
		return
	player_ckey = ckey(player_ckey)
	var/client/player_client = GLOB.directory[player_ckey]
	if(player_client)
		var/list/ban_cache = retrieve_ban_cache(player_client)
		if(!islist(ban_cache))
			return // Disconnected while building the list.
		if(islist(roles))
			for(var/role in roles)
				if(!role)
					continue
				if(check_role_ban(ban_cache, role))
					return TRUE //they're banned from at least one role, no need to keep checking
		else if(check_role_ban(ban_cache, roles))
			return TRUE
	else
		var/values = list(
			"player_ckey" = player_ckey,
			"must_apply_to_admins" = !!(GLOB.admin_datums[player_ckey] || GLOB.deadmins[player_ckey]),
		)
		var/ssqlname = CONFIG_GET(string/serversqlname)
		var/server_check
		if(CONFIG_GET(flag/respect_global_bans))
			server_check = "(server_name = '[ssqlname]' OR global_ban = '1')"
		else
			server_check = "server_name = '[ssqlname]'"
		var/sql_roles
		if(islist(roles))
			var/list/sql_roles_list = list()
			for (var/i in 1 to roles.len)
				values["role[i]"] = roles[i]
				sql_roles_list += ":role[i]"
			sql_roles = sql_roles_list.Join(", ")
		else
			sql_roles = "'[roles]'"
		var/datum/db_query/query_check_ban = SSdbcore.NewQuery({"
			SELECT 1
			FROM [format_table_name("ban")]
			WHERE
				ckey = :player_ckey AND
				role IN ([sql_roles]) AND
				unbanned_datetime IS NULL
				AND (expiration_time IS NULL OR expiration_time > NOW())
				AND [server_check]
				AND (NOT :must_apply_to_admins OR applies_to_admins = 1)
		"}, values)
		if(!query_check_ban.warn_execute())
			qdel(query_check_ban)
			return
		if(query_check_ban.NextRow())
			qdel(query_check_ban)
			return TRUE
		qdel(query_check_ban)

//checks DB ban table if a ckey, ip and/or cid is banned from a specific role
//returns an associative nested list of each matching row's ban id, bantime, ban round id, expiration time, ban duration, applies to admins, reason, key, ip, cid and banning admin's key in that order
/proc/is_banned_from_with_details(player_ckey, player_ip, player_cid, role)
	if(!player_ckey && !player_ip && !player_cid)
		return
	var/ssqlname = CONFIG_GET(string/serversqlname)
	var/server_check
	if(CONFIG_GET(flag/respect_global_bans))
		server_check = "(server_name = '[ssqlname]' OR global_ban = '1')"
	else
		server_check = "server_name = '[ssqlname]'"
	var/datum/db_query/query_check_ban = SSdbcore.NewQuery({"
		SELECT
			id,
			bantime,
			round_id,
			expiration_time,
			TIMESTAMPDIFF(MINUTE, bantime, expiration_time),
			applies_to_admins,
			reason,
			server_name,
			global_ban,
			IFNULL((SELECT byond_key FROM [format_table_name("player")] WHERE [format_table_name("player")].ckey = [format_table_name("ban")].ckey), ckey),
			INET_NTOA(ip),
			computerid,
			IFNULL((SELECT byond_key FROM [format_table_name("player")] WHERE [format_table_name("player")].ckey = [format_table_name("ban")].a_ckey), a_ckey)
		FROM [format_table_name("ban")]
		WHERE role = :role
			AND (ckey = :ckey OR ip = INET_ATON(:ip) OR computerid = :computerid)
			AND unbanned_datetime IS NULL
			AND [server_check]
			AND (expiration_time IS NULL OR expiration_time > NOW())
		ORDER BY bantime DESC
	"}, list("role" = role, "ckey" = player_ckey, "ip" = player_ip, "computerid" = player_cid))
	if(!query_check_ban.warn_execute())
		qdel(query_check_ban)
		return
	. = list()
	while(query_check_ban.NextRow())
		. += list(list("id" = query_check_ban.item[1], "bantime" = query_check_ban.item[2], "round_id" = query_check_ban.item[3], "expiration_time" = query_check_ban.item[4], "duration" = query_check_ban.item[5], "applies_to_admins" = query_check_ban.item[6], "reason" = query_check_ban.item[7], "server_name" = query_check_ban.item[8], "global_ban" = query_check_ban.item[9], "key" = query_check_ban.item[10], "ip" = query_check_ban.item[11], "computerid" = query_check_ban.item[12], "admin_key" = query_check_ban.item[13]))
	qdel(query_check_ban)

/// Gets the ban cache of the passed in client
/// If the cache has not been generated, we start off a query
/// If we still have a query going for this request, we just sleep until it's received back
/proc/retrieve_ban_cache(client/player_client)
	if(QDELETED(player_client))
		return

	if(player_client.ban_cache)
		return player_client.ban_cache

	var/config_delay = CONFIG_GET(number/blocking_query_timeout) SECONDS
	// If we haven't got a query going right now, or we've timed out on the old query
	if(player_client.ban_cache_start + config_delay < REALTIMEOFDAY)
		return build_ban_cache(player_client)

	// Ok so we've got a request going, lets start a wait cycle
	// If we wait longer then config/db_ban_timeout we'll send another request
	// We use timeofday here because we're talking human time
	// We do NOT cache the start time because it can update, and we want it to be able to
	while(player_client && player_client?.ban_cache_start + config_delay >= REALTIMEOFDAY && !player_client?.ban_cache)
		// Wait a decisecond or two would ya?
		// If this causes lag on client join, increase this delay. it doesn't need to be too fast since this should
		// Realllly only happen near Login, and we're unlikely to make any new requests in that time
		stoplag(2)

	// If we have a ban cache, use it. if we've timed out, go ahead and start another query would you?
	// This will update any other sleep loops, so we should only run one at a time
	return player_client?.ban_cache || build_ban_cache(player_client)

/proc/build_ban_cache(client/player_client)
	if(!SSdbcore.Connect())
		return
	if(QDELETED(player_client))
		return
	var/current_time = REALTIMEOFDAY
	player_client.ban_cache_start = current_time

	var/ckey = player_client.ckey
	var/list/ban_cache = list()
	var/is_admin = FALSE
	if(GLOB.admin_datums[ckey] || GLOB.deadmins[ckey])
		is_admin = TRUE

	var/ssqlname = CONFIG_GET(string/serversqlname)
	var/server_check
	if(CONFIG_GET(flag/respect_global_bans))
		server_check = "(server_name = '[ssqlname]' OR global_ban = '1')"
	else
		server_check = "server_name = '[ssqlname]'"

	var/datum/db_query/query_build_ban_cache = SSdbcore.NewQuery(
		"SELECT role, applies_to_admins FROM [format_table_name("ban")] WHERE ckey = :ckey AND unbanned_datetime IS NULL AND (expiration_time IS NULL OR expiration_time > NOW()) AND [server_check]",
		list("ckey" = ckey))
	var/query_successful = query_build_ban_cache.warn_execute()
	// After we sleep, we check if this was the most recent cache build, and if so we clear our start time
	if(player_client?.ban_cache_start == current_time)
		player_client.ban_cache_start = 0
	if(!query_successful)
		qdel(query_build_ban_cache)
		return

	while(query_build_ban_cache.NextRow())
		if(is_admin && !text2num(query_build_ban_cache.item[2])) // check if applies to admins
			continue
		ban_cache[query_build_ban_cache.item[1]] = TRUE
	qdel(query_build_ban_cache)
	if(QDELETED(player_client)) // Disconnected while working with the DB.
		return
	player_client.ban_cache = ban_cache
	return ban_cache

/datum/admins/proc/ban_panel(player_key, player_ip, player_cid, role, duration = 1440, applies_to_admins = FALSE, reason = "", edit_id, page, admin_key, global_ban = TRUE, force_cryo_after = FALSE)
	var/suppressor
	if(check_rights(R_SUPPRESS, FALSE))
		suppressor = TRUE
	else
		suppressor = FALSE
	var/datum/banning_panel/ui = new(usr)
	ui.key_enabled = !isnull(player_key)
	ui.key = player_key
	ui.ip = player_ip
	ui.cid = player_cid
	ui.duration = duration
	ui.can_supress = suppressor
	ui.applies_to_admins = applies_to_admins
	ui.reason = reason
	ui.force_cryo_after = force_cryo_after
	ui.ban_type = isnull(role)? "Server": role
	ui.use_last_connection = isnull(player_ip) && isnull(player_cid)
	ui.ui_interact(usr)


/datum/banning_panel
	var/key_enabled
	var/key
	var/ip_enabled = FALSE
	var/ip
	var/cid_enabled = TRUE
	var/cid
	var/duration = 0
	var/can_supress
	var/suppressed = FALSE
	var/applies_to_admins = FALSE
	var/reason = ""
	var/force_cryo_after = FALSE
	var/ban_type = "Server"
	var/duration_type = "Temporary"
	var/time_units = "Minutes"
	var/use_last_connection = FALSE
	var/static/list/static_roles
	var/static/list/group_list = list("command","security", "engineering", "medical", "science", "supply", "civilian", "gimmick", "antagonist_positions", "forced_antagonist_positions", "ghost_roles", "others")
	var/list/selected_roles
	var/list/selected_groups

/datum/banning_panel/New()
	.=..()
	if(!static_roles)
		static_roles = list(
			"command" = SSdepartment.get_jobs_by_dept_id(DEPT_NAME_COMMAND),
			"security" = SSdepartment.get_jobs_by_dept_id(DEPT_NAME_SECURITY),
			"engineering" = SSdepartment.get_jobs_by_dept_id(DEPT_NAME_ENGINEERING),
			"medical" = SSdepartment.get_jobs_by_dept_id(DEPT_NAME_MEDICAL),
			"science" = SSdepartment.get_jobs_by_dept_id(DEPT_NAME_SCIENCE),
			"supply" = SSdepartment.get_jobs_by_dept_id(DEPT_NAME_CARGO),
			"silicon" = SSdepartment.get_jobs_by_dept_id(DEPT_NAME_SILICON),
			"civilian" = SSdepartment.get_jobs_by_dept_id(DEPT_NAME_CIVILIAN),
			"gimmick" = list(JOB_NAME_CLOWN,JOB_NAME_MIME,JOB_NAME_GIMMICK,JOB_NAME_ASSISTANT), //Hardcoded since it's not a real category but handy for rolebans
			"antagonist_positions" = list(BAN_ROLE_ALL_ANTAGONISTS) + GLOB.antagonist_bannable_roles,
			"forced_antagonist_positions" = list(BAN_ROLE_FORCED_ANTAGONISTS) + GLOB.forced_bannable_roles,
			"ghost_roles" = list(BAN_ROLE_ALL_GHOST) + GLOB.ghost_role_bannable_roles,
			"abstract" = list("Appearance", "Emote", "OOC", "DSAY"),
			"other" = GLOB.other_bannable_roles)
	selected_roles = list(0)
	selected_groups = list(0)

/datum/banning_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "BanningPanel")
		ui.open()

/datum/banning_panel/ui_state(mob/user)
	return GLOB.admin_holder_state


/datum/banning_panel/ui_data(mob/user)
	var/list/data = list()
	data["key_enabled"] = key_enabled
	data["key"] = key
	data["ip_enabled"] = ip_enabled
	data["ip"] = ip
	data["cid_enabled"] = cid_enabled
	data["cid"] = cid
	data["duration"] = duration
	data["can_supress"] = can_supress
	data["applies_to_admins"] = applies_to_admins
	data["reason"] = reason
	data["force_cryo_after"] = force_cryo_after
	data["ban_type"] = ban_type
	data["duration_type"] = duration_type
	data["ban_duration"] = duration
	data["time_units"] = time_units
	data["use_last_connection"] = use_last_connection
	data["suppressed"] = suppressed
	data["selected_roles"] = selected_roles
	data["selected_groups"] = selected_groups
	data["roles"] = static_roles

	return data

/datum/banning_panel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	. = TRUE
	switch (action)
		if("toggle_key")
			key_enabled = !key_enabled
		if ("toggle_ip")
			ip_enabled = !ip_enabled
		if ("toggle_cid")
			cid_enabled = !cid_enabled
		if ("toggle_cryo")
			force_cryo_after = !force_cryo_after
		if ("toggle_suppressed")
			suppressed = !suppressed
		if ("toggle_use_last_connection")
			use_last_connection = !use_last_connection
		if ("toggle_applies_to_admins")
			applies_to_admins = !applies_to_admins
		if ("set_duration_type")
			duration_type = params["type"]
		if ("set_time_units")
			time_units = params["units"]
		if ("set_ban_type")
			ban_type = params["type"]
		if ("update_key")
			key = params["key"]
		if ("update_ip")
			ip = params["ip"]
		if ("update_cid")
			cid = params["cid"]
		if ("update_duration")
			duration = params["duration"]
		if ("update_reason")
			reason = params["reason"]
		if ("toggle_group")
			var/group = params["group"]
			if (selected_groups.Find(group))
				selected_groups -= group
				for (var/role in static_roles[group])
					if (selected_roles.Find(role))
						selected_roles -= role
			else
				selected_groups += group
				for (var/role in static_roles[group])
					if (!selected_roles.Find(role))
						selected_roles += role

		if ("toggle_role")
			var/role = params["selected_role"]
			if (selected_roles.Find(role))
				selected_roles -= role
			else
				selected_roles += role
		if ("submit_ban")
			parse_ban(key, key_enabled, ip_enabled, ip, cid_enabled, cid, use_last_connection, applies_to_admins, duration_type, duration, time_units, "high", reason, 1, ban_type, selected_roles, suppressed, force_cryo_after)
		else
			if (action in group_list)
				if (action in selected_groups)
					selected_roles -= selected_roles & group_list[action]
				else
					selected_roles = selected_roles | group_list[action]
			else if (action in static_roles)
				if (action in selected_roles)
					selected_roles += action
				else
					selected_roles -= action
			else
				. = FALSE

/datum/banning_panel/proc/parse_ban(player_key, key_check, ip_check, player_ip, cid_check, player_cid, use_last_connection, applies_to_admins, duration_type, duration, interval, severity, reason, global_ban, ban_type, list/roles_to_ban, redact = FALSE, force_cryo_after = FALSE)
	if(!check_rights(R_BAN))
		return
	if(!SSdbcore.Connect())
		to_chat(usr, span_danger("Failed to establish database connection."))
		return

	var/list/error_state = list()

	roles_to_ban.Remove(0)
	if(redact && !check_rights(R_SUPPRESS))
		error_state += "You have attempted to issue a suppressed ban without permission, This incident has been logged."
		log_admin_private("SUPPRESS: [key_name(usr)] ATTEMPTED TO ISSUE A SUPPRESSED BAN WITHOUT THE REQUISITE RIGHT!")
	if(key_check && !player_key)
		error_state += "Key was ticked but none was provided."
	if(ip_check && !player_ip && !use_last_connection)
		error_state += "IP was ticked but none was provided."
	if(cid_check && !player_cid && !use_last_connection)
		error_state += "CID was ticked but none was provided."
	if(use_last_connection && !ip_check && !cid_check)
		error_state += "Use last connection was ticked, but neither IP nor CID was."
	if(applies_to_admins && redact)
		error_state += "Admin bans can not be suppressed."
	if(!duration)
		error_state += "No duration was provided."
	if(!reason)
		error_state += "No reason was provided."
	if(!severity)
		error_state += "No severity was selected."
	if(ban_type == "Role" && !roles_to_ban.len)
		error_state += "Role ban was selected but no roles to ban were selected."
	if(ban_type != "Server" && redact)
		error_state += "Suppression may only be applied to server bans."
	if(duration_type == "Temporary" && !duration)
		error_state += "Temporary ban was selected but no duration was provided."
	if(error_state.len)
		to_chat(usr, span_danger("Ban not created because the following errors were present:\n[error_state.Join("\n")]"))
		return
	if(ban_type == "Server")
		roles_to_ban = list("Server")
	if(duration_type == "Permanent")
		duration = null
	if(!cid_check)
		player_cid = null
	var/mob/user = usr
	if(!istype(user) || !user.client || !user.client.holder)
		return
	var/datum/admins/holder = user.client.holder
	holder.create_ban(player_key, ip_check, player_ip, cid_check, player_cid, use_last_connection, applies_to_admins, duration, interval, severity, reason, global_ban, roles_to_ban, redact, force_cryo_after)

/datum/admins/proc/ban_parse_href(list/href_list)
	if(!check_rights(R_BAN))
		return
	if(!SSdbcore.Connect())
		to_chat(usr, span_danger("Failed to establish database connection."))
		return
	var/list/error_state = list()
	var/player_key
	var/ip_check = FALSE
	var/player_ip
	var/cid_check = FALSE
	var/player_cid
	var/use_last_connection = FALSE
	var/applies_to_admins = FALSE
	var/global_ban = TRUE
	var/duration
	var/interval
	var/severity
	var/reason
	var/mirror_edit
	var/edit_id
	var/old_key
	var/old_ip
	var/old_cid
	var/old_applies
	var/old_globalban
	var/page
	var/admin_key
	var/redact
	var/force_cryo_after = FALSE
	var/list/changes = list()
	var/list/roles_to_ban = list()
	if(href_list["redactioncheck"])
		if(check_rights(R_SUPPRESS))
			if(!edit_id)
				redact = TRUE
			else
				error_state += "Bans may not have their suppression flag edited. If a ban requiring suppression was accidently issued without it, contact [CONFIG_GET(string/hostedby)] immediately."
		else
			error_state += "You have attempted to issue a suppressed ban without permission, This incident has been logged."
			log_admin_private("SUPPRESS: [key_name(usr)] ATTEMPTED TO ISSUE A SUPPRESSED BAN WITHOUT THE REQUISITE RIGHT!")
	if(href_list["keycheck"])
		player_key = href_list["keytext"]
		if(!player_key)
			error_state += "Key was ticked but none was provided."
	if(href_list["ipcheck"])
		ip_check = TRUE
	if(href_list["cidcheck"])
		cid_check = TRUE
	if(href_list["lastconn"])
		if(player_key)
			use_last_connection = TRUE
	else
		if(ip_check)
			player_ip = href_list["iptext"]
			if(!player_ip && !use_last_connection)
				error_state += "IP was ticked but none was provided."
		if(cid_check)
			player_cid = href_list["cidtext"]
			if(!player_cid && !use_last_connection)
				error_state += "CID was ticked but none was provided."
	if(!use_last_connection && !player_ip && !player_cid && !player_key)
		error_state += "At least a key, IP or CID must be provided."
	if(use_last_connection && !ip_check && !cid_check)
		error_state += "Use last connection was ticked, but neither IP nor CID was."
	if(href_list["applyadmins"])
		if(redact)
			error_state += "Admin bans can not be suppressed."
		applies_to_admins = TRUE
	if(href_list["forcecryo"])
		force_cryo_after = TRUE
	switch(href_list["radioservban"])
		if("local")
			if(CONFIG_GET(flag/disable_local_bans))
				global_ban = TRUE
			else
				global_ban = FALSE
				if(redact)
					error_state += "Suppressed bans must be global."
		if("global")
			global_ban = TRUE
	switch(href_list["radioduration"])
		if("permanent")
			duration = null
		if("temporary")
			duration = href_list["duration"]
			interval = href_list["intervaltype"]
			if(!duration)
				error_state += "Temporary ban was selected but no duration was provided."
		else
			error_state += "No duration was selected."
	reason = href_list["reason"]
	if(!reason)
		error_state += "No reason was provided."
	if(href_list["editid"])
		edit_id = href_list["editid"]
		if(href_list["mirroredit"])
			mirror_edit = TRUE
		old_key = href_list["oldkey"]
		old_ip = href_list["oldip"]
		old_cid = href_list["oldcid"]
		old_globalban = href_list["old_globalban"]
		page = href_list["page"]
		admin_key = href_list["adminkey"]
		if(player_key != old_key)
			changes += list("Key" = "[old_key] to [player_key]")
		if(global_ban != old_globalban)
			changes += list("Ban Location" = "[old_globalban] to [global_ban]")
		if(player_ip != old_ip)
			changes += list("IP" = "[old_ip] to [player_ip]")
		if(player_cid != old_cid)
			changes += list("CID" = "[old_cid] to [player_cid]")
		old_applies = text2num(href_list["oldapplies"])
		if(applies_to_admins != old_applies)
			changes += list("Applies to admins" = "[old_applies] to [applies_to_admins]")
		if(duration != href_list["oldduration"])
			changes += list("Duration" = "[href_list["oldduration"]] MINUTE to [duration] [interval]")
		if(reason != href_list["oldreason"])
			changes += list("Reason" = "[href_list["oldreason"]]<br>to<br>[reason]")
		if(!changes.len)
			error_state += "No changes were detected."
	else
		severity = href_list["radioseverity"]
		if(!severity)
			error_state += "No severity was selected."
		switch(href_list["radioban"])
			if("server")
				roles_to_ban += "Server"
			if("role")
				href_list.Remove("Command", "Security", "Engineering", "Medical", "Science", "Supply", "Silicon", "Abstract", "Civilian", "Ghost and Other Roles", "Antagonist Positions") //remove the role banner hidden input values
				if(href_list[href_list.len] == "roleban_delimiter")
					error_state += "Role ban was selected but no roles to ban were selected."
				else
					var/delimiter_pos = href_list.Find("roleban_delimiter")
					href_list.Cut(1, delimiter_pos+1)//remove every list element before and including roleban_delimiter so we have a list of only the roles to ban
					for(var/key in href_list) //flatten into a list of only unique keys
						roles_to_ban |= key
			else
				error_state += "No ban type was selected."
	if((href_list["radioban"] != "server") && redact)
		error_state += "Suppression may only be applied to server bans."
	if(error_state.len)
		to_chat(usr, span_danger("Ban not [edit_id ? "edited" : "created"] because the following errors were present:\n[error_state.Join("\n")]"))
		return
	if(edit_id)
		edit_ban(edit_id, player_key, ip_check, player_ip, cid_check, player_cid, use_last_connection, applies_to_admins, duration, interval, reason, global_ban, mirror_edit, old_key, old_ip, old_cid, old_applies, old_globalban, page, admin_key, changes)
	else
		create_ban(player_key, ip_check, player_ip, cid_check, player_cid, use_last_connection, applies_to_admins, duration, interval, severity, reason, global_ban, roles_to_ban, redact, force_cryo_after)

/datum/admins/proc/create_ban(player_key, ip_check, player_ip, cid_check, player_cid, use_last_connection, applies_to_admins, duration, interval, severity, reason, global_ban, list/roles_to_ban, redact = FALSE, force_cryo_after = FALSE)
	if(!check_rights(R_BAN))
		return
	if(!SSdbcore.Connect())
		to_chat(usr, span_danger("Failed to establish database connection."))
		return

	if(redact && alert(usr, "You are about to issue a Suppressed ban, This will require direct database editing to revoke, ARE YOU SURE?", "Protected CID", "Yes", "No", "Cancel") != "Yes")
		return
	var/player_ckey = ckey(player_key)
	if(player_ckey)
		var/datum/db_query/query_create_ban_get_player = SSdbcore.NewQuery({"
			SELECT byond_key, INET_NTOA(ip), computerid FROM [format_table_name("player")] WHERE ckey = :player_ckey
		"}, list("player_ckey" = player_ckey))
		if(!query_create_ban_get_player.warn_execute())
			qdel(query_create_ban_get_player)
			return
		if(query_create_ban_get_player.NextRow())
			player_key = query_create_ban_get_player.item[1]
			if(use_last_connection)
				if(ip_check)
					player_ip = query_create_ban_get_player.item[2]
				if(cid_check)
					player_cid = query_create_ban_get_player.item[3]
		else
			if(use_last_connection)
				if(alert(usr, "[player_key]/([player_ckey]) has not been seen before, unable to use IP and CID from last connection. Are you sure you want to create a ban for them?", "Unknown key", "Yes", "No", "Cancel") != "Yes")
					qdel(query_create_ban_get_player)
					return
			else
				if(alert(usr, "[player_key]/([player_ckey]) has not been seen before, are you sure you want to create a ban for them?", "Unknown key", "Yes", "No", "Cancel") != "Yes")
					qdel(query_create_ban_get_player)
					return
		qdel(query_create_ban_get_player)
	if(cid_check && config.protected_cids.Find(player_cid))
		if(alert(usr, "CID [player_cid] is listed as protected for the following reason: [config.protected_cids[player_cid]], Are you sure you want to restrict this CID? THIS WILL PROBABLY CATCH LEGITIMATE PLAYERS.", "Protected CID", "Yes", "No", "Cancel") != "Yes")
			return
		var/kn = key_name(usr)
		//Log the shit out of this and scream bloody murder to anyone who will listen.
		send2tgs("CID PROTECTION BYPASS", "[kn] Has overridden CID protection for a ban on CID [player_cid]!")
		message_admins(span_danger("[kn] Has overridden CID protection for a ban on CID [player_cid]!"))
		log_admin_private("[kn] Has overridden CID protection for a ban on CID [player_cid]!")
	var/admin_ckey = usr.client.ckey
	if(applies_to_admins)
		var/datum/db_query/query_check_adminban_count = SSdbcore.NewQuery({"
			SELECT COUNT(DISTINCT bantime)
			FROM [format_table_name("ban")]
			WHERE
				a_ckey = :admin_ckey AND
				applies_to_admins = 1 AND
				unbanned_datetime IS NULL AND
				(expiration_time IS NULL OR expiration_time > NOW())
		"}, list("admin_ckey" = admin_ckey))
		if(!query_check_adminban_count.warn_execute()) //count distinct bantime to treat rolebans made at the same time as one ban
			qdel(query_check_adminban_count)
			return
		if(query_check_adminban_count.NextRow())
			var/adminban_count = text2num(query_check_adminban_count.item[1])
			var/max_adminbans = MAX_ADMINBANS_PER_ADMIN
			//edit rights are a more effective way to check hierarchical rank since many non-headmins have R_PERMISSIONS
			if(rank.can_edit_rights == R_EVERYTHING)
				max_adminbans = MAX_ADMINBANS_PER_HEADMIN
			if(adminban_count >= max_adminbans)
				to_chat(usr, span_danger("You've already logged [max_adminbans] admin ban(s) or more. Do not abuse this function!"))
				qdel(query_check_adminban_count)
				return
		qdel(query_check_adminban_count)
	var/admin_ip = usr.client.address
	var/admin_cid = usr.client.computer_id
	duration = text2num(duration)
	if (!(interval in list("SECOND", "MINUTE", "HOUR", "DAY", "WEEK", "MONTH", "YEAR")))
		interval = "MINUTE"
	var/time_message = "[duration] [LOWER_TEXT(interval)]" //no DisplayTimeText because our duration is of variable interval type
	if(duration > 1) //pluralize the interval if necessary
		time_message += "s"
	var/note_reason = "Banned from [roles_to_ban[1] == "Server" ? "the server" : " Roles: [roles_to_ban.Join(", ")]"] [isnull(duration) ? "permanently" : "for [time_message]"] - [reason]"
	var/list/clients_online = GLOB.clients.Copy()
	var/list/admins_online = list()
	for(var/client/C in clients_online)
		if(C.holder) //deadmins aren't included since they wouldn't show up on adminwho
			admins_online += C
	var/who = clients_online.Join(", ")
	var/adminwho = admins_online.Join(", ")
	var/kn = key_name(usr)
	var/kna = key_name_admin(usr)

	var/special_columns = list(
		"bantime" = "NOW()",
		"server_ip" = "INET_ATON(?)",
		"ip" = "INET_ATON(?)",
		"a_ip" = "INET_ATON(?)",
		"expiration_time" = "IF(? IS NULL, NULL, NOW() + INTERVAL ? [interval])"
	)
	var/sql_ban = list()
	//I'm going to crosscheck this one last time because this is playing with fire.
	if(redact)
		if(!check_rights(R_SUPPRESS))
			to_chat(usr, span_danger("You have attempted to register a suppressed ban without the correct access, this incident has been logged, and the ban has been aborted."))
			log_admin_private("SUPPRESS: [key_name(usr)] ATTEMPTED TO ISSUE A SUPPRESSED BAN WITHOUT THE REQUISITE RIGHT!")
			return
		if(roles_to_ban[1] != "Server") //This should never happen. Still checking it.
			to_chat(usr, span_danger("You have attempted to directly register a suppressed ban that is not a server ban, this incident has been logged, and the ban has been aborted."))
			log_admin_private("SUPPRESS: [key_name(usr)] ATTEMPTED TO MANUALLY ISSUE A SUPPRESSED NON-SERVER BAN!")
			return
		if(applies_to_admins)
			to_chat(usr, span_danger("You have attempted to directly register a suppressed ban that affects admins, this incident has been logged, and the ban has been aborted."))
			log_admin_private("SUPPRESS: [key_name(usr)] ATTEMPTED TO MANUALLY ISSUE A SUPPRESSED ADMIN BAN!")
			return
	for(var/role in roles_to_ban)
		sql_ban += list(list(
			"server_name" = CONFIG_GET(string/serversqlname),
			"server_ip" = world.internet_address || 0,
			"server_port" = world.port,
			"round_id" = GLOB.round_id,
			"role" = role,
			"expiration_time" = duration,
			"applies_to_admins" = applies_to_admins,
			"reason" = reason,
			"ckey" = player_ckey || null,
			"ip" = player_ip || null,
			"computerid" = player_cid || null,
			"a_ckey" = admin_ckey,
			"a_ip" = admin_ip || null,
			"a_computerid" = admin_cid,
			"who" = who,
			"adminwho" = adminwho,
			"global_ban" = global_ban,
			"hidden" = redact
		))
	if(!SSdbcore.MassInsert(format_table_name("ban"), sql_ban, warn = TRUE, special_columns = special_columns))
		return
	var/target = ban_target_string(player_key, player_ip, player_cid)
	var/msg = "has created a [global_ban ? "global" : "local"] [isnull(duration) ? "permanent" : "temporary [time_message]"] [applies_to_admins ? "admin " : ""][roles_to_ban[1] == "Server" ? "server ban" : "role ban from [roles_to_ban.len] roles"] for [target]."
	if(!redact)
		log_admin_private("[kn] [msg][roles_to_ban[1] == "Server" ? "" : " Roles: [roles_to_ban.Join(", ")]"] Reason: [reason]")
		message_admins("[kna] [msg][roles_to_ban[1] == "Server" ? "" : " Roles: [roles_to_ban.Join("\n")]"]\nReason: [reason]")
	else
		log_admin_private("SUPPRESS: [kn] has created a suppressed ban.")
		to_chat(usr, "Ban issued successfuly, This has not been announced to other admins.")
	if(applies_to_admins && !redact) //Should never happen.
		send2tgs("BAN ALERT","[kn] [msg]")
	if(player_ckey && !redact)
		create_message("note", player_ckey, admin_ckey, note_reason, null, null, 0, 0, null, -1, severity)
	var/client/C = GLOB.directory[player_ckey]
	var/datum/help_ticket/AH = admin_ticket_log(player_ckey, msg)
	var/appeal_url = "No ban appeal url set!"
	appeal_url = CONFIG_GET(string/banappeals)
	var/is_admin = FALSE
	var/special_prefix = ""
	if(redact)
		special_prefix = "hard "
	if(applies_to_admins)
		special_prefix = "admin "
	if(C)
		build_ban_cache(C)
		to_chat(C, "[span_boldannounce("You have been [special_prefix]banned by [usr.client.key] from [roles_to_ban[1] == "Server" ? "the server" : " Roles: [roles_to_ban.Join(", ")]"].\nReason: [reason]")]<br>[span_danger("This ban is [isnull(duration) ? "permanent." : "temporary, it will be removed in [time_message]."] [global_ban ? "This ban applies to all of our servers." : "This is a single-server ban, and only applies to this server."] The round ID is [GLOB.round_id].")]<br>[span_danger(redact ? "This ban may not be appealed." : "To appeal this ban go to [appeal_url]")]")
		if(GLOB.admin_datums[C.ckey] || GLOB.deadmins[C.ckey])
			is_admin = TRUE
		if(roles_to_ban[1] == "Server" && (!is_admin || (is_admin && applies_to_admins)))
			qdel(C)
	if(roles_to_ban[1] == "Server" && AH)
		AH.Resolve()
	for(var/client/i in GLOB.clients - C)
		if(i.address == player_ip || i.computer_id == player_cid)
			build_ban_cache(i)
			to_chat(i, "[span_boldannounce("You have been [special_prefix]banned by [usr.client.key] from [roles_to_ban[1] == "Server" ? "the server" : " Roles: [roles_to_ban.Join(", ")]"].\nReason: [reason]")]<br>[span_danger("This ban is [isnull(duration) ? "permanent." : "temporary, it will be removed in [time_message]."] [global_ban ? "This ban applies to all of our servers." : "This is a single-server ban, and only applies to this server."] The round ID is [GLOB.round_id].")]<br>[span_danger("To appeal this ban go to [appeal_url]")]")
			if(GLOB.admin_datums[i.ckey] || GLOB.deadmins[i.ckey])
				is_admin = TRUE
			if(roles_to_ban[1] == "Server" && (!is_admin || (is_admin && applies_to_admins)))
				qdel(i)
	if(force_cryo_after)
		force_cryo_ckey(player_ckey)

/datum/admins/proc/unban_panel(player_key, admin_key, player_ip, player_cid, page = 0)
	if(!check_rights(R_BAN))
		return
	if(!SSdbcore.Connect())
		to_chat(usr, span_danger("Failed to establish database connection."))
		return
	var/datum/browser/unban_panel = new(usr, "unbanpanel", "Unbanning Panel", 850, 600)
	unban_panel.add_stylesheet("unbanpanelcss", 'html/admin/unbanpanel.css')
	var/list/output = list("<div class='searchbar'>")
	output += {"<form method='get' action='byond://?src=[REF(src)]'>[HrefTokenFormField()]
	<input type='hidden' name='src' value='[REF(src)]'>
	Key:<input type='text' name='searchunbankey' size='18' value='[player_key]'>
	Admin Key:<input type='text' name='searchunbanadminkey' size='18' value='[admin_key]'>
	IP:<input type='text' name='searchunbanip' size='12' value='[player_ip]'>
	CID:<input type='text' name='searchunbancid' size='10' value='[player_cid]'>
	<input type='submit' value='Search'>
	</form>
	</div>
	<div class='main'>
	"}
	if(player_key || admin_key || player_ip || player_cid)
		var/bancount = 0
		var/bansperpage = 10
		page = text2num(page)
		var/datum/db_query/query_unban_count_bans = SSdbcore.NewQuery({"
			SELECT COUNT(id)
			FROM [format_table_name("ban")]
			WHERE
				(:player_key IS NULL OR ckey = :player_key) AND
				(:admin_key IS NULL OR a_ckey = :admin_key) AND
				(:player_ip IS NULL OR ip = INET_ATON(:player_ip)) AND
				(:player_cid IS NULL OR computerid = :player_cid) AND
				hidden = 0
		"}, list(
			"player_key" = ckey(player_key),
			"admin_key" = ckey(admin_key),
			"player_ip" = player_ip || null,
			"player_cid" = player_cid || null,
		))
		if(!query_unban_count_bans.warn_execute())
			qdel(query_unban_count_bans)
			return
		if(query_unban_count_bans.NextRow())
			bancount = text2num(query_unban_count_bans.item[1])
		qdel(query_unban_count_bans)
		if(bancount > bansperpage)
			output += "<b>Page: </b>"
			var/pagecount = 1
			var/list/pagelist = list()
			while(bancount > 0)
				pagelist += "<a href='byond://?_src_=holder;[HrefToken()];unbanpagecount=[pagecount - 1];unbankey=[player_key];unbanadminkey=[admin_key];unbanip=[player_ip];unbancid=[player_cid]'>[pagecount == (page + 1) ? "<b>\[[pagecount]\]</b>" : "\[[pagecount]\]"]</a>"
				bancount -= bansperpage
				pagecount++
			output += pagelist.Join(" | ")
		var/datum/db_query/query_unban_search_bans = SSdbcore.NewQuery({"
			SELECT
				id,
				bantime,
				round_id,
				role,
				expiration_time,
				TIMESTAMPDIFF(MINUTE, bantime, expiration_time),
				IF(expiration_time < NOW(), 1, NULL),
				applies_to_admins,
				reason,
				IFNULL((
					SELECT byond_key
					FROM [format_table_name("player")]
					WHERE [format_table_name("player")].ckey = [format_table_name("ban")].ckey
				), ckey),
				INET_NTOA(ip),
				computerid,
				IFNULL((
					SELECT byond_key
					FROM [format_table_name("player")]
					WHERE [format_table_name("player")].ckey = [format_table_name("ban")].a_ckey
				), a_ckey),
				IF(edits IS NOT NULL, 1, NULL),
				unbanned_datetime,
				IFNULL((
					SELECT byond_key
					FROM [format_table_name("player")]
					WHERE [format_table_name("player")].ckey = [format_table_name("ban")].unbanned_ckey
				), unbanned_ckey),
				unbanned_round_id
			FROM [format_table_name("ban")]
			WHERE
				(:player_key IS NULL OR ckey = :player_key) AND
				(:admin_key IS NULL OR a_ckey = :admin_key) AND
				(:player_ip IS NULL OR ip = INET_ATON(:player_ip)) AND
				(:player_cid IS NULL OR computerid = :player_cid) AND
				hidden = 0
			ORDER BY id DESC
			LIMIT :skip, :take
		"}, list(
			"player_key" = ckey(player_key),
			"admin_key" = ckey(admin_key),
			"player_ip" = player_ip || null,
			"player_cid" = player_cid || null,
			"skip" = bansperpage * page,
			"take" = bansperpage,
		))
		if(!query_unban_search_bans.warn_execute())
			qdel(query_unban_search_bans)
			return
		while(query_unban_search_bans.NextRow())
			var/ban_id = query_unban_search_bans.item[1]
			var/ban_datetime = query_unban_search_bans.item[2]
			var/ban_round_id  = query_unban_search_bans.item[3]
			var/role = query_unban_search_bans.item[4]
			//make the href for unban here so only the search parameters are passed
			var/unban_href = "<a href='byond://?_src_=holder;[HrefToken()];unbanid=[ban_id];unbankey=[player_key];unbanadminkey=[admin_key];unbanip=[player_ip];unbancid=[player_cid];unbanrole=[role];unbanpage=[page]'>Unban</a>"
			var/expiration_time = query_unban_search_bans.item[5]
			//we don't cast duration as num because if the duration is large enough to be converted to scientific notation by byond then the + character gets lost when passed through href causing SQL to interpret '4.321e 007' as '4'
			var/duration = query_unban_search_bans.item[6]
			var/expired = query_unban_search_bans.item[7]
			var/applies_to_admins = text2num(query_unban_search_bans.item[8])
			var/reason = query_unban_search_bans.item[9]
			player_key = query_unban_search_bans.item[10]
			player_ip = query_unban_search_bans.item[11]
			player_cid = query_unban_search_bans.item[12]
			admin_key = query_unban_search_bans.item[13]
			var/edits = query_unban_search_bans.item[14]
			var/unban_datetime = query_unban_search_bans.item[15]
			var/unban_key = query_unban_search_bans.item[16]
			var/unban_round_id = query_unban_search_bans.item[17]
			var/target = ban_target_string(player_key, player_ip, player_cid)
			output += "<div class='banbox'><div class='header [unban_datetime ? "unbanned" : "banned"]'><b>[target]</b>[applies_to_admins ? " <b>ADMIN</b>" : ""] banned by <b>[admin_key]</b> from <b>[role]</b> on <b>[ban_datetime]</b> during round <b>#[ban_round_id]</b>.<br>"
			if(!expiration_time)
				output += "<b>Permanent ban</b>."
			else
				output += "Duration of <b>[DisplayTimeText(text2num(duration) MINUTES)]</b>, <b>[expired ? "expired" : "expires"]</b> on <b>[expiration_time]</b>."
			if(unban_datetime)
				output += "<br>Unbanned by <b>[unban_key]</b> on <b>[unban_datetime]</b> during round <b>#[unban_round_id]</b>."
			output += "</div><div class='container'><div class='reason'>[reason]</div><div class='edit'>"
			output += "<a href='byond://?_src_=holder;[HrefToken()];editbanid=[ban_id];editbankey=[player_key];editbanip=[player_ip];editbancid=[player_cid];editbanrole=[role];editbanduration=[duration];editbanadmins=[applies_to_admins];editbanreason=[rustg_url_encode(reason)];editbanpage=[page];editbanadminkey=[admin_key]'>Edit</a><br>[unban_href]"
			if(edits)
				output += "<br><a href='byond://?_src_=holder;[HrefToken()];unbanlog=[ban_id]'>Edit log</a>"
			output += "</div></div></div>"
		qdel(query_unban_search_bans)
		output += "</div>"
	unban_panel.set_content(jointext(output, ""))
	unban_panel.open()

/datum/admins/proc/unban(ban_id, player_key, player_ip, player_cid, role, page, admin_key)
	if(!check_rights(R_BAN))
		return
	if(!SSdbcore.Connect())
		to_chat(usr, span_danger("Failed to establish database connection."))
		return
	var/target = ban_target_string(player_key, player_ip, player_cid)
	if(alert(usr, "Please confirm unban of [target] from [role].", "Unban confirmation", "Yes", "No") != "Yes")
		return
	var/kn = key_name(usr)
	var/kna = key_name_admin(usr)
	var/datum/db_query/query_unban = SSdbcore.NewQuery({"
		UPDATE [format_table_name("ban")] SET
			unbanned_datetime = NOW(),
			unbanned_ckey = :admin_ckey,
			unbanned_ip = INET_ATON(:admin_ip),
			unbanned_computerid = :admin_cid,
			unbanned_round_id = :round_id
		WHERE id = :ban_id
	"}, list("ban_id" = ban_id, "admin_ckey" = usr.client.ckey, "admin_ip" = usr.client.address, "admin_cid" = usr.client.computer_id, "round_id" = GLOB.round_id))
	if(!query_unban.warn_execute())
		qdel(query_unban)
		return
	qdel(query_unban)
	log_admin_private("[kn] has unbanned [target] from [role].")
	message_admins("[kna] has unbanned [target] from [role].")
	var/client/C = GLOB.directory[player_key]
	if(C)
		build_ban_cache(C)
		to_chat(C, span_boldannounce("[usr.client.key] has removed a ban from [role] for your key."))
	for(var/client/i in GLOB.clients - C)
		if(i.address == player_ip || i.computer_id == player_cid)
			build_ban_cache(i)
			to_chat(i, span_boldannounce("[usr.client.key] has removed a ban from [role] for your IP or CID."))
	unban_panel(player_key, admin_key, player_ip, player_cid, page)

/datum/admins/proc/edit_ban(ban_id, player_key, ip_check, player_ip, cid_check, player_cid, use_last_connection, applies_to_admins, duration, interval, reason, global_ban, mirror_edit, old_key, old_ip, old_cid, old_applies, old_globalban, admin_key, page, list/changes)
	if(!check_rights(R_BAN))
		return
	if(!SSdbcore.Connect())
		to_chat(usr, span_danger("Failed to establish database connection."))
		return

	if(cid_check && config.protected_cids.Find(player_cid))
		if(alert(usr, "CID [player_cid] is listed as protected for the following reason: [config.protected_cids[player_cid]], Are you sure you want to restrict this CID? THIS WILL PROBABLY CATCH LEGITIMATE PLAYERS.", "Protected CID", "Yes", "No", "Cancel") != "Yes")
			return
		var/kn = key_name(usr)
		//Log the shit out of this and scream bloody murder to anyone who will listen.
		send2tgs("CID PROTECTION BYPASS", "[kn] Has overridden CID protection for a ban on CID [player_cid]!")
		message_admins(span_danger("[kn] Has overridden CID protection for a ban on CID [player_cid]!"))
		log_admin_private("[kn] Has overridden CID protection for a ban on CID [player_cid]!")

	var/player_ckey = ckey(player_key)
	var/bantime
	if(player_ckey)
		var/datum/db_query/query_edit_ban_get_player = SSdbcore.NewQuery({"
			SELECT
				byond_key,
				(SELECT bantime FROM [format_table_name("ban")] WHERE id = :ban_id),
				ip,
				computerid
			FROM [format_table_name("player")]
			WHERE ckey = :player_ckey
		"}, list("player_ckey" = player_ckey, "ban_id" = ban_id))
		if(!query_edit_ban_get_player.warn_execute())
			qdel(query_edit_ban_get_player)
			return
		if(query_edit_ban_get_player.NextRow())
			player_key = query_edit_ban_get_player.item[1]
			bantime = query_edit_ban_get_player.item[2]
			if(use_last_connection)
				if(ip_check)
					player_ip = query_edit_ban_get_player.item[3]
				if(cid_check)
					player_cid = query_edit_ban_get_player.item[4]
		else
			if(use_last_connection)
				if(alert(usr, "[player_key]/([player_ckey]) has not been seen before, unable to use IP and CID from last connection. Are you sure you want to edit a ban for them?", "Unknown key", "Yes", "No", "Cancel") != "Yes")
					qdel(query_edit_ban_get_player)
					return
			else
				if(alert(usr, "[player_key]/([player_ckey]) has not been seen before, are you sure you want to edit a ban for them?", "Unknown key", "Yes", "No", "Cancel") != "Yes")
					qdel(query_edit_ban_get_player)
					return
		qdel(query_edit_ban_get_player)
	if(applies_to_admins && (applies_to_admins != old_applies))
		var/datum/db_query/query_check_adminban_count = SSdbcore.NewQuery({"
			SELECT COUNT(DISTINCT bantime)
			FROM [format_table_name("ban")]
			WHERE a_ckey = :admin_ckey
				AND applies_to_admins = 1
				AND unbanned_datetime IS NULL
				AND (expiration_time IS NULL OR expiration_time > NOW())
		"}, list("admin_ckey" = usr.client.ckey))
		if(!query_check_adminban_count.warn_execute()) //count distinct bantime to treat rolebans made at the same time as one ban
			qdel(query_check_adminban_count)
			return
		if(query_check_adminban_count.NextRow())
			var/adminban_count = text2num(query_check_adminban_count.item[1])
			var/max_adminbans = MAX_ADMINBANS_PER_ADMIN
			if(R_EVERYTHING && !(R_EVERYTHING & rank.can_edit_rights)) //edit rights are a more effective way to check hierarchical rank since many non-headmins have R_PERMISSIONS now
				max_adminbans = MAX_ADMINBANS_PER_HEADMIN
			if(adminban_count >= max_adminbans)
				to_chat(usr, span_danger("You've already logged [max_adminbans] admin ban(s) or more. Do not abuse this function!"))
				qdel(query_check_adminban_count)
				return
		qdel(query_check_adminban_count)

	if (!(interval in list("SECOND", "MINUTE", "HOUR", "DAY", "WEEK", "MONTH", "YEAR")))
		interval = "MINUTE"

	var/list/changes_text = list()
	var/list/changes_keys = list()
	for(var/i in changes)
		changes_text += "[i]: [changes[i]]"
		changes_keys += i
	var/change_message = "[usr.client.key] edited the following [jointext(changes_text, ", ")]<hr>"

	var/list/arguments = list(
		"duration" = duration || null,
		"reason" = reason,
		"applies_to_admins" = applies_to_admins,
		"ckey" = player_ckey || null,
		"ip" = player_ip || null,
		"cid" = player_cid || null,
		"change_message" = change_message,
		"global_ban" = global_ban
	)
	var/where
	if(text2num(mirror_edit))
		var/list/wherelist = list("bantime = '[bantime]'")
		if(old_key)
			wherelist += "ckey = :old_ckey"
			arguments["old_ckey"] = ckey(old_key)
		if(old_ip)
			wherelist += "ip = INET_ATON(:old_ip)"
			arguments["old_ip"] = old_ip || null
		if(old_cid)
			wherelist += "computerid = :old_cid"
			arguments["old_cid"] = old_cid
		where = wherelist.Join(" AND ")
	else
		where = "id = :ban_id"
		arguments["ban_id"] = ban_id

	var/datum/db_query/query_edit_ban = SSdbcore.NewQuery({"
		UPDATE [format_table_name("ban")]
		SET
			expiration_time = IF(:duration IS NULL, NULL, bantime + INTERVAL :duration [interval]),
			applies_to_admins = :applies_to_admins,
			reason = :reason,
			global_ban = :global_ban,
			ckey = :ckey,
			ip = INET_ATON(:ip),
			computerid = :cid,
			edits = CONCAT(IFNULL(edits,''), :change_message)
		WHERE [where]
	"}, arguments)
	if(!query_edit_ban.warn_execute())
		qdel(query_edit_ban)
		return
	qdel(query_edit_ban)

	var/changes_keys_text = jointext(changes_keys, ", ")
	var/kn = key_name(usr)
	var/kna = key_name_admin(usr)
	log_admin_private("[kn] has edited the [changes_keys_text] of a ban for [old_key ? "[old_key]" : "[old_ip]-[old_cid]"].") //if a ban doesn't have a key it must have an ip and/or a cid to have reached this point normally
	message_admins("[kna] has edited the [changes_keys_text] of a ban for [old_key ? "[old_key]" : "[old_ip]-[old_cid]"].")
	if(changes["Applies to admins"])
		send2tgs("BAN ALERT","[kn] has edited a ban for [old_key ? "[old_key]" : "[old_ip]-[old_cid]"] to [applies_to_admins ? "" : "not"]affect admins")
	var/client/C = GLOB.directory[old_key]
	if(C)
		build_ban_cache(C)
		to_chat(C, span_boldannounce("[usr.client.key] has edited the [changes_keys_text] of a ban for your key."))
	for(var/client/i in GLOB.clients - C)
		if(i.address == old_ip || i.computer_id == old_cid)
			build_ban_cache(i)
			to_chat(i, span_boldannounce("[usr.client.key] has edited the [changes_keys_text] of a ban for your IP or CID."))
	unban_panel(player_key, null, null, null, page)

/datum/admins/proc/ban_log(ban_id)
	if(!check_rights(R_BAN))
		return
	if(!SSdbcore.Connect())
		to_chat(usr, span_danger("Failed to establish database connection."))
		return
	var/datum/db_query/query_get_ban_edits = SSdbcore.NewQuery({"
		SELECT edits FROM [format_table_name("ban")] WHERE id = :ban_id
	"}, list("ban_id" = ban_id))
	if(!query_get_ban_edits.warn_execute())
		qdel(query_get_ban_edits)
		return
	if(query_get_ban_edits.NextRow())
		var/edits = query_get_ban_edits.item[1]
		var/datum/browser/edit_log = new(usr, "baneditlog", "Ban edit log")
		edit_log.set_content(edits)
		edit_log.open()
	qdel(query_get_ban_edits)

/datum/admins/proc/ban_target_string(player_key, player_ip, player_cid)
	. = list()
	if(player_key)
		. += player_key
	else
		if(player_ip)
			. += player_ip
		else
			. += "NULL"
		if(player_cid)
			. += player_cid
		else
			. += "NULL"
	. = jointext(., "/")

/datum/admins/proc/old_ban_panel(player_key, player_ip, player_cid, role, duration = 1440, applies_to_admins, reason, edit_id, page, admin_key, global_ban = TRUE, force_cryo_after = FALSE)
	var/suppressor
	if(check_rights(R_SUPPRESS, FALSE))
		suppressor = TRUE
	var/panel_height = 620
	if(edit_id)
		panel_height = 240
	var/datum/browser/panel = new(usr, "banpanel", "Banning Panel", 910, panel_height)
	panel.add_stylesheet("admin_panelscss", 'html/admin/admin_panels.css')
	panel.add_stylesheet("banpanelcss", 'html/admin/banpanel.css')
	var/tgui_fancy = usr.client.prefs.read_player_preference(/datum/preference/toggle/tgui_fancy)
	if(tgui_fancy) //some browsers (IE8) have trouble with unsupported css3 elements and DOM methods that break the panel's functionality, so we won't load those if a user is in no frills tgui mode since that's for similar compatability support
		panel.add_stylesheet("admin_panelscss3", 'html/admin/admin_panels_css3.css')
		panel.add_script("banpaneljs", 'html/admin/banpanel.js')
	var/list/output = list("<form method='get' action='byond://?src=[REF(src)]'>[HrefTokenFormField()]")
	output += {"<input type='hidden' name='src' value='[REF(src)]'>
	<label class='inputlabel checkbox'>Key:
	<input type='checkbox' id='keycheck' name='keycheck' value='1'[player_key ? " checked": ""]>
	<div class='inputbox'></div></label>
	<input type='text' name='keytext' size='26' value='[player_key]'>
	<label class='inputlabel checkbox'>IP:
	<input type='checkbox' id='ipcheck' name='ipcheck' value='1'[isnull(duration) ? " checked" : ""]>
	<div class='inputbox'></div></label>
	<input type='text' name='iptext' size='18' value='[player_ip]'>
	<label class='inputlabel checkbox'>CID:
	<input type='checkbox' id='cidcheck' name='cidcheck' value='1' checked>
	<div class='inputbox'></div></label>
	<input type='text' name='cidtext' size='14' value='[player_cid]'>
	[(suppressor && !edit_id) ? "" : "<!--"]
	<label class='inputlabel checkbox banned'>Enable Suppression
	<input type='checkbox' id='redactioncheck' name='redactioncheck' value='1' onClick='suppression_lock(this)'>
	<div class='inputbox'></div></label>
	[(suppressor && !edit_id) ? "" : "-->"]
	<br>
	<label class='inputlabel checkbox'>Use IP and CID from last connection of key
	<input type='checkbox' id='lastconn' name='lastconn' value='1' [(isnull(duration) && !player_ip) || (!player_cid) ? " checked": ""]>
	<div class='inputbox'></div></label>
	<label class='inputlabel checkbox'>Applies to Admins
	<input class='redact_incompatible' type='checkbox' id='applyadmins' name='applyadmins' value='1' [applies_to_admins ? " checked": ""]>
	<div class='inputbox'></div></label>
	<label class='inputlabel checkbox'>Force Cryo Afterwards
	<input class='redact_incompatible' type='checkbox' id='forcecryo' name='forcecryo' value='1' [force_cryo_after ? " checked": ""]>
	<div class='inputbox'></div></label>
	<input type='submit' value='Submit'>
	<br>
	<div class='row'>
		<div class='column left'>
			Duration type
			<br>
			<label class='inputlabel radio'>Permanent
			<input type='radio' id='permanent' name='radioduration' value='permanent'[isnull(duration) ? " checked" : ""]>
			<div class='inputbox'></div></label>
			<br>
			<label class='inputlabel radio'>Temporary
			<input type='radio' id='temporary' name='radioduration' value='temporary'[duration ? " checked" : ""]>
			<div class='inputbox'></div></label>
			<input type='text' name='duration' size='7' value='[duration]'>
			<div class="select">
				<select name='intervaltype'>
					<option value='SECOND'>Seconds</option>
					<option value='MINUTE' selected>Minutes</option>
					<option value='HOUR'>Hours</option>
					<option value='DAY'>Days</option>
					<option value='WEEK'>Weeks</option>
					<option value='MONTH'>Months</option>
					<option value='YEAR'>Years</option>
				</select>
			</div>
		</div>
		<div class='column middle'>
			Ban type
			<br>
			<label class='inputlabel radio'>Server
			<input class='redact_force_checked' type='radio' id='server' name='radioban' value='server'[role == "Server" ? " checked" : ""][edit_id ? " disabled" : ""]>
			<div class='inputbox'></div></label>
			<br>
			<label class='inputlabel radio'>Role
			<input class='redact_incompatible' type='radio' id='role' name='radioban' value='role'[role == "Server" ? "" : " checked"][edit_id ? " disabled" : ""]>
			<div class='inputbox'></div></label>
		</div>
		<div class='column middle'>
			Severity
			<br>
			<label class='inputlabel radio'>None
			<input class='redact_incompatible' type='radio' id='none' name='radioseverity' value='none'[edit_id ? " disabled" : ""]>
			<div class='inputbox'></div></label>
			<label class='inputlabel radio'>Medium
			<input class='redact_incompatible' type='radio' id='medium' name='radioseverity' value='medium'[edit_id ? " disabled" : ""]>
			<div class='inputbox'></div></label>
			<br>
			<label class='inputlabel radio'>Minor
			<input class='redact_incompatible' type='radio' id='minor' name='radioseverity' value='minor'[edit_id ? " disabled" : ""]>
			<div class='inputbox'></div></label>
			<label class='inputlabel radio'>High
			<input class='redact_force_checked' type='radio' id='high' name='radioseverity' value='high'[edit_id ? " disabled" : ""]>
			<div class='inputbox'></div></label>
		</div>
		<div class='column right'>
			Location
			<br>
			<label class='inputlabel radio'>Local
			<input class='redact_incompatible' type='radio' id='servban' name='radioservban' value='local'[isnull(global_ban) ? " checked" : ""] disabled='[CONFIG_GET(flag/disable_local_bans) ? "true" : "false"]'>
			<div class='inputbox'></div></label>
			<br>
			<label class='inputlabel radio'>Global
			<input class='redact_force_checked' type='radio' id='servban' name='radioservban' value='global'[(global_ban) ? " checked" : "" ] disabled='[CONFIG_GET(flag/disable_local_bans) ? "true" : "false"]'>
			<div class='inputbox'></div></label>
		</div>
		<div class='column'>
			Reason
			<br>
			<textarea class='reason' name='reason'>[reason]</textarea>
		</div>
	</div>
	"}
	if(edit_id)
		output += {"<label class='inputlabel checkbox'>Mirror edits to matching bans
		<input type='checkbox' id='mirroredit' name='mirroredit' value='1'>
		<div class='inputbox'></div></label>
		<input type='hidden' name='editid' value='[edit_id]'>
		<input type='hidden' name='oldkey' value='[player_key]'>
		<input type='hidden' name='oldip' value='[player_ip]'>
		<input type='hidden' name='oldcid' value='[player_cid]'>
		<input type='hidden' name='oldapplies' value='[applies_to_admins]'>
		<input type='hidden' name='oldduration' value='[duration]'>
		<input type='hidden' name='oldreason' value='[reason]'>
		<input type]'hidden' name='oldglobal' value='[global_ban]'
		<input type='hidden' name='old_globalban' value='[global_ban]'
		<input type='hidden' name='page' value='[page]'>
		<input type='hidden' name='adminkey' value='[admin_key]'>
		<br>
		When ticked, edits here will also affect bans created with matching ckey, IP, CID and time. Use this to edit all role bans which were made at the same time.
		"}
	else
		output += "<input type='hidden' name='roleban_delimiter' value='1'>"
		//there's not always a client to use the bancache of so to avoid many individual queries from using is_banned_form we'll build a cache to use here
		var/banned_from = list()
		if(player_key)
			var/datum/db_query/query_get_banned_roles = SSdbcore.NewQuery({"
				SELECT role
				FROM [format_table_name("ban")]
				WHERE
					ckey = :player_ckey AND
					role <> 'server'
					AND unbanned_datetime IS NULL
					AND (expiration_time IS NULL OR expiration_time > NOW())
			"}, list("player_ckey" = ckey(player_key)))
			if(!query_get_banned_roles.warn_execute())
				qdel(query_get_banned_roles)
				return
			while(query_get_banned_roles.NextRow())
				banned_from += query_get_banned_roles.item[1]
			qdel(query_get_banned_roles)
		var/break_counter = 0
		var/fancy_tgui = usr.client.prefs.read_player_preference(/datum/preference/toggle/tgui_fancy)
		output += "<div class='row'><div class='column'><label class='rolegroup command'><input type='checkbox' name='Command' class='hidden' [fancy_tgui ? " onClick='toggle_checkboxes(this, \"_dep\")'" : ""]>Command</label><div class='content'>"
		//all heads are listed twice so have a javascript call to toggle both their checkboxes when one is pressed
		//for simplicity this also includes the captain even though it doesn't do anything
		for(var/job in SSdepartment.get_jobs_by_dept_id(DEPT_NAME_COMMAND))
			if(break_counter > 0 && (break_counter % 3 == 0))
				output += "<br>"
			output += {"<label class='inputlabel checkbox'>[job]
						<input type='checkbox' id='[job]_com' name='[job]' class='Command' value='1'[fancy_tgui ? " onClick='toggle_head(this, \"_dep\")'" : ""]>
						<div class='inputbox[(job in banned_from) ? " banned" : ""]'></div></label>
			"}
			break_counter++
		output += "</div></div>"
		//standard departments all have identical handling
		var/list/job_lists = list("Security" = SSdepartment.get_jobs_by_dept_id(DEPT_NAME_SECURITY),
							"Engineering" = SSdepartment.get_jobs_by_dept_id(DEPT_NAME_ENGINEERING),
							"Medical" = SSdepartment.get_jobs_by_dept_id(DEPT_NAME_MEDICAL),
							"Science" = SSdepartment.get_jobs_by_dept_id(DEPT_NAME_SCIENCE),
							"Supply" = SSdepartment.get_jobs_by_dept_id(DEPT_NAME_CARGO))
		for(var/department in job_lists)
			//the first element is the department head so they need the same javascript call as above
			output += "<div class='column'><label class='rolegroup [ckey(department)]'><input type='checkbox' name='[department]' class='hidden' [fancy_tgui ? " onClick='toggle_checkboxes(this, \"_com\")'" : ""]>[department]</label><div class='content'>"
			output += {"<label class='inputlabel checkbox'>[job_lists[department][1]]
						<input type='checkbox' id='[job_lists[department][1]]_dep' name='[job_lists[department][1]]' class='[department]' value='1'[fancy_tgui ? " onClick='toggle_head(this, \"_com\")'" : ""]>
						<div class='inputbox[(job_lists[department][1] in banned_from) ? " banned" : ""]'></div></label>
			"}
			break_counter = 1
			for(var/job in job_lists[department] - job_lists[department][1]) //skip the first element since it's already been done
				if(break_counter % 3 == 0)
					output += "<br>"
				output += {"<label class='inputlabel checkbox'>[job]
							<input type='checkbox' name='[job]' class='[department]' value='1'>
							<div class='inputbox[(job in banned_from) ? " banned" : ""]'></div></label>
				"}
				break_counter++
			output += "</div></div>"
		//departments/groups that don't have command staff would throw a javascript error since there's no corresponding reference for toggle_head()
		var/list/headless_job_lists = list("Silicon" = SSdepartment.get_jobs_by_dept_id(DEPT_NAME_SILICON),
										"Abstract" = list("Appearance", "Emote", "OOC", "DSAY"))
		for(var/department in headless_job_lists)
			output += "<div class='column'><label class='rolegroup [ckey(department)]'><input type='checkbox' name='[department]' class='hidden' [fancy_tgui ? " onClick='toggle_checkboxes(this, \"_com\")'" : ""]>[department]</label><div class='content'>"
			break_counter = 0
			for(var/job in headless_job_lists[department])
				if(break_counter > 0 && (break_counter % 3 == 0))
					output += "<br>"
				output += {"<label class='inputlabel checkbox'>[job]
							<input type='checkbox' name='[job]' class='[department]' value='1'>
							<div class='inputbox[(job in banned_from) ? " banned" : ""]'></div></label>
				"}
				break_counter++
			output += "</div></div>"
		var/list/long_job_lists = list(
			"Civilian" = SSdepartment.get_jobs_by_dept_id(DEPT_NAME_CIVILIAN) | JOB_NAME_GIMMICK,
			"Antagonist Positions" = list(BAN_ROLE_ALL_ANTAGONISTS) + GLOB.antagonist_bannable_roles,
			"Forced Antagonist Positions" = list(BAN_ROLE_FORCED_ANTAGONISTS) + GLOB.forced_bannable_roles,
			"Ghost Roles" = list(BAN_ROLE_ALL_GHOST) + GLOB.ghost_role_bannable_roles,
			"Other" = GLOB.other_bannable_roles,
		)

		for(var/department in long_job_lists)
			output += "<div class='column'><label class='rolegroup long [ckey(department)]'><input type='checkbox' name='[department]' class='hidden' [fancy_tgui ? " onClick='toggle_checkboxes(this, \"_com\")'" : ""]>[department]</label><div class='content'>"
			break_counter = 0
			for(var/job in long_job_lists[department])
				if(break_counter > 0 && (break_counter % 10 == 0))
					output += "<br>"
				output += {"<label class='inputlabel checkbox'>[job]
							<input type='checkbox' name='[job]' class='[department]' value='1'>
							<div class='inputbox[(job in banned_from) ? " banned" : ""]'></div></label>
				"}
				break_counter++
			output += "</div></div>"
		output += "</div>"
	output += "</form>"
	panel.set_content(jointext(output, ""))
	panel.open()

#undef MAX_ADMINBANS_PER_ADMIN
#undef MAX_ADMINBANS_PER_HEADMIN
