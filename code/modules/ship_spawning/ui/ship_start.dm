
#define STATE_INITIAL 0
#define STATE_CREATE 1
#define STATE_JOIN 2

/datum/ship_start_selector
	// Start in the initial state
	var/state = STATE_INITIAL
	// The relevant lobby
	var/datum/ship_lobby/lobby

/datum/ship_start_selector/ui_interact(mob/user, datum/tgui/ui)
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
	switch (state)
		if (STATE_CREATE)
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
					member_list += C.ckey
				data["selected_lobby"] = list(
					"member_list" = member_list,
					"can_join" = lobby.can_join(user.client)
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

	switch (src.state)
		if (STATE_INITIAL)
			switch(action)
				//======= Lobby Action =======
				if ("setup_character")
					// Display the preference/character creator menu
					usr.client.prefs.ShowChoices(usr)
				if ("create_lobby")
					// Switch to the new state
					src.state = STATE_CREATE
					// Create a new lobby
					lobby = new /datum/ship_lobby(usr.client)
					update_static_data(usr, ui)
				if ("join_lobby")
					// Switch to the new state
					src.state = STATE_JOIN
					update_static_data(usr, ui)
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
							// Join the game as a job
							tgui_alert(usr, "Select job (Not implemented)", "Select job")
					else
						tgui_alert(usr, "Failed to join requested lobby, the lobby may be private or deleted.", "Join Failed")
		if (STATE_CREATE)
			switch(action)
				//======= Create Ship Actions =======
				if ("disband_crew")
					return
				if ("set_name")
					return
				if ("set_ship")
					return
				if ("set_privacy_mode")
					return
				if ("kick_player")
					return
				if ("add_equipment")
					return
				if ("remove_equipment")
					return
				if ("add_whitelist")
					return
				if ("remove_whitelist")
					return
				if ("start_game")
					return
	return TRUE

/datum/ship_start_selector/ui_assets(mob/user)
	. = ..()
	. += get_asset_datum(/datum/asset/spritesheet/job_icons)
