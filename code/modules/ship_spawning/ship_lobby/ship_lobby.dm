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
	/// Are we currently loading? Block changes while loading
	var/loading = FALSE

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
	if (C.ckey in whitelisted_ckeys)
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
	if (!is_host(C) || loading || lobby_state != LOBBY_MENU)
		return
	selected_ship = starter_ship

/datum/ship_lobby/proc/get_ship()
	return selected_ship

/datum/ship_lobby/proc/set_privacy_mode(client/C, new_value)
	if (!is_host(C))
		return
	private_lobby = !!new_value

/datum/ship_lobby/proc/kick_player(client/user, client/target)
	if (!is_host(user) || loading)
		return
	member_leave(target)
	tgui_alert_async(target, "You have been kicked from the lobby by [user.ckey].", "Kicked from lobby.")

/datum/ship_lobby/proc/get_job_role(client/target)
	if (lobby_state == LOBBY_MENU)
		return wanted_roles[target.ckey]
	return SSjob.GetJob(target.mob.mind.assigned_role)

/datum/ship_lobby/proc/set_job_role(client/source, desired_role)
	if (lobby_state != LOBBY_MENU || loading)
		return
	// Verify the role
	for (var/datum/job/job_type as() in selected_ship.job_roles)
		if (desired_role == initial(job_type.title))
			wanted_roles[source.ckey] = job_type
			return

/datum/ship_lobby/proc/try_start_game(client/source)
	if (!is_host(source) || lobby_state != LOBBY_MENU || loading)
		return
	if (SSticker.current_state < GAME_STATE_PLAYING)
		tgui_alert_async(source, "The game is not ready yet, please wait.", "Cannot start")
		return
	if (!selected_ship)
		tgui_alert_async(source, "You must selected a ship before you can start the game.", "Cannot start")
		return
	var/list/bad_clients = get_invalid_clients()
	if (length(bad_clients))
		if (tgui_alert(source, "Some players do not have jobs, or cannot get their desired role. Do you want to start and assign random jobs to these players?", "Invalid Configuration", list("Start", "Cancel")) != "Start")
			return
	// Check to see if we can still start
	if (!is_host(source) || lobby_state != LOBBY_MENU || loading)
		return
	if (!selected_ship)
		tgui_alert_async(source, "You must selected a ship before you can start the game.", "Cannot start")
		return
	loading = TRUE
	// Spawn the ship
	var/datum/map_generator/map_place/placer = SSship_spawning.spawn_ship(selected_ship.spawned_template)
	if (!placer)
		tgui_alert_async(source, "Failed to load selected map, please file a GitHub issue or contact the Head Developer.", "Loading error")
		loading = FALSE
		return
	// Give the clients their jobs, give bad clients a random job
	placer.on_completion(COMPLETION_PRIORITY_PREVIEW, CALLBACK(src, PROC_REF(after_ship_spawned)))

/datum/ship_lobby/proc/after_ship_spawned(datum/map_generator/map_gen, turf/T, init_atmos, datum/parsed_map/parsed, finalize = TRUE, register = TRUE, list/turfs)
	loading = FALSE
	lobby_state = LOBBY_GAME
	// Locate all the player spawns and put the players in them
	// Any player that doesn't have a job, or has their job role filled
	// will get a random role assigned at the end of job assignation.
	// The order in which players get randomly re-assigned is undefined,
	// players in lobbies are expected to agree on their job roles before starting
	// this is just a failsafe for when that innevitably doesn't happen.
	// List of job names to list of turfs
	var/list/assoc_spawn_points = list()
	var/obj/docking_port/mobile/M
	for(var/turf/place in turfs)
		if (!M)
			M = locate(/obj/docking_port/mobile) in place
		for (var/obj/effect/landmark/start/start_landmark in place)
			if (!assoc_spawn_points[start_landmark.name])
				assoc_spawn_points[start_landmark.name] = list()
			assoc_spawn_points[start_landmark.name] += place
	// Keep track of the job list
	var/list/job_list = selected_ship.job_roles.Copy()
	var/list/unspawned_clients = list()
	// Start player spawning procedures
	for (var/client/player in members)
		var/datum/job/desired_job = wanted_roles[player.ckey]
		// Check if the job role is valid
		if (!job_list[desired_job])
			unspawned_clients += player
			continue
		// Check if there are enough slots left
		var/slots_left = job_list[desired_job]
		if (slots_left <= 0)
			unspawned_clients += player
			continue
		slots_left --
		job_list[desired_job] = slots_left
		// Spawn the player at a valid spawn point
		var/turf/selected_spawn_point
		if (!assoc_spawn_points[initial(desired_job.title)])
			// Spawn at a random point
			if (length(assoc_spawn_points))
				selected_spawn_point = pick(pick(assoc_spawn_points))
			else
				// Yolospawn
				selected_spawn_point = pick(turfs)
		else
			selected_spawn_point = pick(assoc_spawn_points[initial(desired_job.title)])
		// Perform roundstart prefs loading
		var/mob/living/carbon/human/created_character = new(selected_spawn_point)
		player.prefs.active_character.copy_to(created_character)
		created_character.dna.update_dna_identity()
		// Spawmn the job role
		var/datum/job/job_instance = SSjob.GetJob(initial(desired_job.title))
		job_instance.equip(created_character)
		created_character.key = player.key
	// Set the name of the ship
	M.name = ship_name
	// Spawn and players that weren't spawned with randomised jobs
	// If there are literally no job slots left, spawn as an assistant
	// TODO
	// Launch the ship into supercruise
	// TODO: Start docked at a station?
	M.enter_supercruise(new /datum/orbital_vector(rand(-10000, 10000), rand(-10000, 10000)))

/datum/ship_lobby/proc/get_invalid_clients()
	var/list/bad_clients = list()
	var/list/job_list = selected_ship.job_roles.Copy()
	// Check if we can start
	for (var/client/person in members)
		var/datum/job/desired_job = wanted_roles[person.ckey]
		if (!desired_job)
			bad_clients += person
			continue
		if (!job_list[desired_job])
			bad_clients += person
			continue
		var/job_count = job_list[desired_job]
		if (job_count <= 0)
			bad_clients += person
			continue
		// Thie client is good
		job_count --
		job_list[desired_job] = job_count
	return bad_clients

/datum/ship_lobby/proc/whitelist_add(client/source)
	if (!is_host(source) || loading)
		return
	var/provided_key = tgui_input_text(source, "Enter the ckey to add to the whitelist.", "Whitelist Add")
	if (!provided_key)
		return
	whitelisted_ckeys |= ckey(provided_key)

/datum/ship_lobby/proc/whitelist_remote(client/source)
	if (!is_host(source) || loading)
		return
	var/key_to_remove = tgui_input_list(source, "What ckey would you like to remove from the whitelist?", "Whitelist Remove", whitelisted_ckeys)
	if (!key_to_remove)
		return
	whitelisted_ckeys -= ckey(key_to_remove)
