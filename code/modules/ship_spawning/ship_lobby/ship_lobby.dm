/datum/ship_lobby
	/// The current state of the lobby, has their game
	/// started yet?
	var/lobby_state = LOBBY_MENU

	/// Lobby ID
	var/lobby_id
	/// The owner of the lobby. May be null in cases of it being a debug
	/// lobby.
	var/client/owner
	/// The list of clients inside the lobby
	var/list/members = list()
	/// Is this shuttle private or public
	var/private_lobby = TRUE
	/// List of whitelisted ckeys, players cannot join this ship outside of the whitelist
	var/list/whitelisted_ckeys = list()

	//=================
	// Lobby Tracking
	// These variables become redundant once
	// the game has started.
	//=================
	// The name of the ship in the lobby
	var/ship_name = "Unnamed Ship"
	// The ship that was selected
	var/datum/starter_ship_template/selected_ship
	// What job role each ckey wants
	var/list/wanted_roles = list()

	//=================
	// Game Variables
	// These variables are only relevant once
	// the game has started.
	//=================
	var/datum/shuttle_data/shuttle

/datum/ship_lobby/New(client/creator)
	. = ..()
	owner = creator
	member_join(creator)
	SSship_spawning.game_lobbies += src
	var/static/global_lobby_id = 0
	lobby_id = ++global_lobby_id

/datum/ship_lobby/Destroy(force, ...)
	SSship_spawning.game_lobbies -= src
	. = ..()

/datum/ship_lobby/proc/can_join(client/C)
	if (!private_lobby)
		return TRUE
	if (C in whitelisted_ckeys)
		return TRUE
	return FALSE

/datum/ship_lobby/proc/member_join(client/C)
	if (C)
		members += C
		to_chat(members, "<span class='announcement'>[C.ckey] has joined the lobby.</span>")

/datum/ship_lobby/proc/member_leave(client/C)
	members -= C
	if (C == owner)
		// Transfer host ownership
		if (length(members) > 0)
			owner = members[1]
			to_chat(owner, "<span class='bold announcement'>You are now the host.</span>")
		else
			qdel(src)
	to_chat(members, "<span class='announcement'>[C.ckey] left the lobby.</span>")

/// Is the provided client the host of the lobby?
/datum/ship_lobby/proc/is_host(client/C)
	return owner == C

/datum/ship_lobby/proc/set_name(client/C, desired_name)
	if (!is_host(C))
		return
	ship_name = desired_name

/datum/ship_lobby/proc/get_name()
	if (lobby_state == LOBBY_MENU)
		return ship_name
	return shuttle.shuttle_name

/datum/ship_lobby/proc/set_ship(client/C, datum/starter_ship_template/starter_ship)
	if (!is_host(C))
		return
	selected_ship = starter_ship

/datum/ship_lobby/proc/get_ship()
	return selected_ship

/datum/ship_lobby/proc/set_privacy_mode(client/C, new_value)
	if (!is_host(C))
		return
	private_lobby = !!new_value

/datum/ship_lobby/proc/kick_player(client/user, client/target)
	if (!is_host(user))
		return
	member_leave(target)
	tgui_alert_async(target, "You have been kicked from the lobby by [user.ckey].", "Kicked from lobby.")

/datum/ship_lobby/proc/get_job_role(client/target)
	if (lobby_state == LOBBY_MENU)
		return wanted_roles[target.ckey]

/datum/ship_lobby/proc/set_job_role(client/source, desired_role)
	if (lobby_state != LOBBY_MENU)
		return
	// Verify the role
	for (var/datum/job/job_type as() in selected_ship.job_roles)
		if (desired_role == initial(job_type.title))
			wanted_roles[source.ckey] = desired_role
			return

/datum/ship_lobby/proc/try_start_game(client/source)
	if (!is_host(source))
		return
	// TODO: Spawn the ship, spawn the players, spawn the gear

/datum/ship_lobby/proc/whitelist_add(client/source)
	if (!is_host(source))
		return
	var/provided_key = tgui_input_text(source, "Enter the ckey to add to the whitelist.", "Whitelist Add")
	if (!provided_key)
		return
	whitelisted_ckeys |= ckey(provided_key)

/datum/ship_lobby/proc/whitelist_remote(client/source)
	if (!is_host(source))
		return
	var/key_to_remove = tgui_input_list(source, "What ckey would you like to remove from the whitelist?", "Whitelist Remove", whitelisted_ckeys)
	if (!key_to_remove)
		return
	whitelisted_ckeys -= ckey(key_to_remove)
