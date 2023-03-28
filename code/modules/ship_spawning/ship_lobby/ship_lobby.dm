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
	// The faction that we desire to join
	var/desired_faction = NONE

	var/list/job_list
	var/list/assoc_spawn_points

	var/living_users = 0

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
	START_PROCESSING(SSship_spawning, src)

/datum/ship_lobby/Destroy(force, ...)
	SSship_spawning.game_lobbies -= src
	STOP_PROCESSING(SSship_spawning, src)
	for (var/client/C in members)
		if (C.lobby == src)
			C.lobby = null
	. = ..()

/datum/ship_lobby/process(delta_time)
	if (lobby_state != LOBBY_GAME)
		return
	// Check if our members are alive
	for (var/client/C in members)
		if (C.mob.stat != DEAD)
			return
	// Everyone died, disband the lobby
	on_lobby_eliminated()

/datum/ship_lobby/proc/on_lobby_eliminated()
	to_chat(members, "<span class='announce'>Everyone has died, the story of [ship_name] ends here...</span>")
	qdel(src)

/datum/ship_lobby/proc/can_join(client/C)
	if (!private_lobby)
		return TRUE
	if (C.ckey in whitelisted_ckeys)
		return TRUE
	return FALSE

/datum/ship_lobby/proc/member_join(client/C)
	if (C)
		members += C
		C.lobby = src
		to_chat(members, "<span class='announce'>[C.ckey] has joined the lobby.</span>")

/datum/ship_lobby/proc/member_leave(client/C)
	members -= C
	if (C.lobby == src)
		C.lobby = null
	if (C == owner)
		// Transfer host ownership
		if (length(members) > 0)
			owner = members[1]
			to_chat(owner, "<span class='greenannounce'>You are now the host.</span>")
		else
			qdel(src)
	to_chat(members, "<span class='announce'>[C.ckey] left the lobby.</span>")

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
	if (!shuttle)
		return "ERROR"
	return shuttle.shuttle_name

/datum/ship_lobby/proc/set_faction(client/C, desired_faction)
	if (!is_host(C) || loading || lobby_state != LOBBY_MENU)
		return
	if (!selected_ship)
		return
	if (!(desired_faction & selected_ship.faction_flags))
		return
	if (bit_count(desired_faction) != 1)
		return
	// Verify
	src.desired_faction = desired_faction

/datum/ship_lobby/proc/get_faction()
	return desired_faction

/datum/ship_lobby/proc/set_ship(client/C, datum/starter_ship_template/starter_ship)
	if (!is_host(C) || loading || lobby_state != LOBBY_MENU)
		return
	selected_ship = starter_ship
	desired_faction = NONE

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
	if (!target.mob.mind.assigned_role)
		return "unknown"
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
	assoc_spawn_points = list()
	var/obj/docking_port/mobile/M
	for(var/turf/place in turfs)
		if (!M)
			M = locate(/obj/docking_port/mobile) in place
		for (var/obj/effect/landmark/start/start_landmark in place)
			if (!assoc_spawn_points[start_landmark.name])
				assoc_spawn_points[start_landmark.name] = list()
			assoc_spawn_points[start_landmark.name] += start_landmark
	// Keep track of the job list
	job_list = selected_ship.job_roles.Copy()
	var/list/unspawned_clients = list()
	var/mob/most_important_player
	var/highest_importance = 0
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
		if (!assoc_spawn_points[initial(desired_job.spawn_title)])
			// Spawn at a random point
			if (length(assoc_spawn_points))
				selected_spawn_point = get_turf(pick(pick(assoc_spawn_points)))
			else
				// Yolospawn
				selected_spawn_point = pick(turfs)
		else
			selected_spawn_point = get_turf(pick(assoc_spawn_points[initial(desired_job.spawn_title)]))
		// Perform roundstart prefs loading
		var/mob/living/carbon/human/created_character = new(selected_spawn_point)
		player.prefs.active_character.copy_to(created_character)
		created_character.dna.update_dna_identity()
		// Spawn the job role
		var/datum/job/job_instance = SSjob.GetJob(initial(desired_job.title))
		job_instance.equip(created_character)
		created_character.key = player.key
		if (job_instance.importance > highest_importance)
			highest_importance = job_instance.importance
			most_important_player = created_character
	// Set the name of the ship
	if (ship_name == initial(ship_name))
		// Set a name, nerd
		ship_name = selected_ship.spawned_template.name
	// Check ship name
	var/number = 0
	for (var/obj/docking_port/mobile/other_ship in SSshuttle.mobile)
		if (other_ship.name == ship_name || other_ship.name == "[ship_name] [number]")
			number++
	// Highly Mathemtical
	if (number)
		ship_name = "[ship_name] [number]"
	M.name = ship_name
	var/datum/shuttle_data/data = SSorbits.get_shuttle_data(M.id)
	data.shuttle_name = ship_name
	// Check ship faction
	if (!desired_faction)
		desired_faction = (FACTION_INDEPENDANT & selected_ship.faction_flags) ? FACTION_INDEPENDANT : (FACTION_NANOTRASEN & selected_ship.faction_flags) ? FACTION_NANOTRASEN : FACTION_SYNDICATE
	// Set the ships factoin
	data.faction = get_new_faction_from_flag(desired_faction)
	// Spawn and players that weren't spawned with randomised jobs
	// If there are literally no job slots left, spawn as an assistant
	for (var/client/player in unspawned_clients)
		var/datum/job/desired_job = null
		for (var/job_type in job_list)
			desired_job = job_type
			// Check if there are enough slots left
			var/slots_left = job_list[desired_job]
			if (slots_left <= 0)
				unspawned_clients += player
				continue
			slots_left --
			job_list[desired_job] = slots_left
			break
		if (!desired_job)
			tgui_alert_async(player, "You were unable to be spawned!", "Could not spawn")
			continue
		// Spawn the player at a valid spawn point
		var/turf/selected_spawn_point
		if (!assoc_spawn_points[initial(desired_job.title)])
			// Spawn at a random point
			if (length(assoc_spawn_points))
				selected_spawn_point = get_turf(pick(pick(assoc_spawn_points)))
			else
				// Yolospawn
				selected_spawn_point = pick(turfs)
		else
			selected_spawn_point = get_turf(pick(assoc_spawn_points[initial(desired_job.spawn_title)]))
		// Perform roundstart prefs loading
		var/mob/living/carbon/human/created_character = new(selected_spawn_point)
		player.prefs.active_character.copy_to(created_character)
		created_character.dna.update_dna_identity()
		// Spawn the job role
		var/datum/job/job_instance = SSjob.GetJob(initial(desired_job.spawn_title))
		job_instance.equip(created_character)
		created_character.key = player.key
		if (job_instance.importance > highest_importance)
			highest_importance = job_instance.importance
			most_important_player = created_character
	// Give the budget card
	var/obj/item/card/id/departmental_budget/shuttle/shuttle_budget = new (most_important_player.loc, M)
	most_important_player.put_in_hands(shuttle_budget)
	// Launch the ship into supercruise
	// TODO: Start docked at a station?
	//M.enter_supercruise(new /datum/orbital_vector(rand(-10000, 10000), rand(-10000, 10000)))
	var/obj/docking_port/stationary/docking_port = SSship_spawning.get_spawn_point(desired_faction, M)
	if (docking_port)
		M.initiate_docking(docking_port)
	else
		// Enter at a random location
		M.enter_supercruise(new /datum/orbital_vector(rand(-10000, 10000), rand(-10000, 10000)))

/datum/ship_lobby/proc/choose_job(client/user)
	var/list/options = list()
	for (var/datum/job/job_type as() in job_list)
		var/amount_left = job_list[job_type]
		if (amount_left)
			options["[initial(job_type.title)] ([amount_left > 99 ? "Unlimited" : amount_left] slots)"] = job_type
	var/selected_key = tgui_input_list(user, "Select the job to spawn as", "Select Job", options)
	var/datum/job/selected_choice = options[selected_key]
	if (!selected_choice)
		return FALSE
	// Check if there are enough slots left
	var/slots_left = job_list[selected_choice]
	if (slots_left <= 0)
		return FALSE
	slots_left --
	job_list[selected_choice] = slots_left
	// Spawn the player at a valid spawn point
	var/turf/selected_spawn_point
	if (!assoc_spawn_points[initial(selected_choice.title)])
		// Spawn at a random point
		selected_spawn_point = get_turf(pick(pick(assoc_spawn_points)))
	else
		selected_spawn_point = get_turf(pick(assoc_spawn_points[initial(selected_choice.title)]))
	// Perform roundstart prefs loading
	var/mob/living/carbon/human/created_character = new(selected_spawn_point)
	user.prefs.active_character.copy_to(created_character)
	created_character.dna.update_dna_identity()
	// Spawn the job role
	var/datum/job/job_instance = SSjob.GetJob(initial(selected_choice.title))
	job_instance.equip(created_character)
	created_character.key = user.key
	return TRUE

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
