
#define STATE_INITIAL 0
#define STATE_CREATE 1
#define STATE_JOIN 2

/datum/ship_start_selector
	// Start in the initial state
	var/state = STATE_INITIAL
	// The relevant lobby
	var/datum/ship_lobby/lobby

/datum/ship_start_selector/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "StartMenu")
		ui.open()
		ui.set_autoupdate(TRUE)

/datum/ship_start_selector/ui_state(mob/user)
	return GLOB.new_player_state

/// Things that update frequently and are hard
/// to track.
/datum/ship_start_selector/ui_data(mob/user)
	var/list/data = list()
	// This should be a signal but cba
	if (state == STATE_CREATE && !(user.client in lobby.members))
		lobby = null
		// Switch to the new state
		src.state = STATE_INITIAL
		update_static_data(user)
	switch (state)
		if (STATE_INITIAL)
			data["is_admin"] = !!user.client.holder
		if (STATE_CREATE)
			var/list/member_list = list()
			for (var/client/C in lobby.members)
				var/datum/job/desired_job = lobby.get_job_role(C)
				member_list += list(list(
					"name" = C.ckey,
					"job" = initial(desired_job.title),
				))
			data["lobby_id"] = lobby.lobby_id
			data["lobby_member_list"] = member_list
			data["lobby_can_join"] = lobby.can_join(user.client)
			data["lobby_private"] = lobby.private_lobby
			data["selected_faction"] = lobby.get_faction()
			data["is_host"] = lobby.owner == user.client
			data["lobby_name"] = lobby.get_name()
			data["selected_ship"] = null
			data["whitelist"] = lobby.whitelisted_ckeys
			if (lobby.selected_ship)
				var/list/ship_roles = list()
				for (var/datum/job/job_type as() in lobby.selected_ship.job_roles)
					var/count = lobby.selected_ship.job_roles[job_type]
					ship_roles += list(list(
						"job_name" = initial(job_type.title),
						"used" = 0,
						"amount" = count,
					))
				data["selected_ship"] = list(
					"name" = lobby.selected_ship.spawned_template.name,
					"cost" = lobby.selected_ship.template_cost,
					"roles" = ship_roles,
					"description" = lobby.selected_ship.description,
					"faction_flags" = lobby.selected_ship.faction_flags,
				)
			return data
		if (STATE_JOIN)
			// The available lobbies
			data["lobby_list"] = list()
			for (var/datum/ship_lobby/lobby in SSship_spawning.game_lobbies)
				data["lobby_list"] += list(list(
					"id" = lobby.lobby_id,
					"state" = lobby.lobby_state,
					"owner" = lobby.owner?.ckey || "null",
					"private" = lobby.private_lobby,
					"member_count" = length(lobby.members),
				))
			// Extra info about selected lobby
			if (lobby)
				var/list/member_list = list()
				for (var/client/C in lobby.members)
					member_list += list(list(
						"name" = C.ckey,
						"job" = null
					))
				data["selected_lobby"] = list(
					"id" = lobby.lobby_id,
					"member_list" = member_list,
					"can_join" = lobby.can_join(user.client),
					"private" = lobby.private_lobby,
				)

	return data

/// Things that update slowly
/datum/ship_start_selector/ui_static_data(mob/user)
	var/list/data = list()
	// The current state of the UI, updates when necessary
	data["state"] = state
	switch (state)
		// Create State
		if (STATE_CREATE)
			// Add the list of ships that can be selected
			data["selectable_ships"] = list()
			for (var/datum/starter_ship_template/starter_ship in SSship_spawning.starter_ships)
				data["selectable_ships"] += list(list(
					"name" = starter_ship.spawned_template.name,
					"cost" = starter_ship.template_cost,
				))
			data["faction_flags"] = list(
				"nanotrasen" = FACTION_NANOTRASEN,
				"independant" = FACTION_INDEPENDANT,
				"syndicate" = FACTION_SYNDICATE,
			)
			return data
		// Join state
		if (STATE_JOIN)
			return data
	return data

/datum/ship_start_selector/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/_state)
	if (..())
		return

	// The user MUST have a client
	if (!usr.client)
		return

	if (SSticker.current_state == GAME_STATE_STARTUP)
		tgui_alert_async(usr, "Please wait, the game is still loading.", "Game loading")
		return

	// Global Actions
	switch (action)
		if ("return_main")
			// Leave the lobby if necessary
			if (lobby)
				lobby.member_leave(usr.client)
				lobby = null
			// Switch to the new state
			src.state = STATE_INITIAL
			update_static_data(usr, ui)
			return TRUE
		if ("create_lobby")
			// Leave the lobby if necessary
			if (lobby)
				lobby.member_leave(usr.client)
				lobby = null
			// Switch to the new state
			src.state = STATE_CREATE
			// Create a new lobby
			lobby = new /datum/ship_lobby(usr.client)
			update_static_data(usr, ui)

	switch (src.state)
		if (STATE_INITIAL)
			switch(action)
				//======= Lobby Action =======
				if ("setup_character")
					// Display the preference/character creator menu
					usr.client.prefs.ShowChoices(usr)
				if ("join_lobby")
					// Switch to the new state
					src.state = STATE_JOIN
					update_static_data(usr, ui)
				if ("observe")
					if (!usr.client.holder)
						return FALSE
					var/mob/dead/new_player/np = usr
					if (!istype(np))
						return FALSE
					np.make_me_an_observer()
		if (STATE_JOIN)
			switch(action)
				//======= Join Crew Actions =======
				if ("select_ship")
					var/target = params["lobby_id"]
					lobby = SSship_spawning.get_lobby(target)
					update_static_data(usr, ui)
				if ("join_crew")
					var/target = params["lobby_id"]
					// Attempt to join the requested lobby
					lobby = SSship_spawning.try_join_lobby(usr.client, target)
					if (lobby)
						if (lobby.lobby_state == LOBBY_MENU)
							// Change to the create state, so we can see the state of the lobby
							src.state = STATE_CREATE
							update_static_data(usr, ui)
					else
						tgui_alert(usr, "Failed to join requested lobby, the lobby may be private or deleted.", "Join Failed")
		if (STATE_CREATE)
			switch(action)
				//======= Create Ship Actions =======
				if ("set_name")
					// Name sanitation: State approved characters
					// only.
					var/name = reject_bad_name(params["name"], TRUE)
					if (!name)
						return FALSE
					if (OOC_FILTER_CHECK(name))
						tgui_alert(usr, "Banned words in ship name. Please check the server rules.", "Banned Name")
						return FALSE
					lobby.set_name(usr.client, name)
				if ("set_ship")
					var/ship_name = params["ship_id"]
					for (var/datum/starter_ship_template/starter_ship in SSship_spawning.starter_ships)
						if (starter_ship.spawned_template.name == ship_name)
							lobby.set_ship(usr.client, starter_ship)
							return TRUE
				if ("set_faction")
					var/faction_flag = text2num(params["faction_flag"])
					lobby.set_faction(usr.client, faction_flag)
				if ("set_privacy_mode")
					var/new_private_mode = params["new_private"]
					lobby.set_privacy_mode(usr.client, new_private_mode)
				if ("kick_player")
					var/client/target = null
					var/desired_ckey = ckey(params["ckey"])
					for (var/client/C in lobby.members)
						if (C.ckey == desired_ckey)
							target = C
							break
					if (target)
						lobby.kick_player(usr.client, target)
				if ("add_equipment")
					return
				if ("remove_equipment")
					return
				if ("start_game")
					lobby.try_start_game(usr.client)
				if ("set_job")
					var/desired_job_role = params["job"]
					lobby.set_job_role(usr.client, desired_job_role)
				if ("whitelist")
					lobby.whitelist_add(usr.client)
				if ("dewhitelist")
					lobby.whitelist_remote(usr.client)
	return TRUE

/datum/ship_start_selector/ui_assets(mob/user)
	. = ..()
	. += get_asset_datum(/datum/asset/spritesheet/job_icons)
