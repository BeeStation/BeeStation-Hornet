// Global list used by admins to force a backstory
GLOBAL_LIST_EMPTY(fugitive_backstory_selection)

/datum/round_event_control/fugitives
	name = "Spawn Fugitives"
	typepath = /datum/round_event/ghost_role/fugitives
	max_occurrences = 1
	min_players = 20
	earliest_start = 30 MINUTES //deadchat sink, lets not even consider it early on.
	gamemode_blacklist = list("nuclear")
	cannot_spawn_after_shuttlecall = TRUE

/datum/round_event/ghost_role/fugitives
	minimum_required = 1
	role_name = ROLE_FUGITIVE
	fakeable = FALSE

/datum/round_event/ghost_role/fugitives/spawn_role()
	for(var/datum/team/fugitive/F in GLOB.antagonist_teams)
		return MAP_ERROR
	for(var/datum/team/fugitive_hunters/F in GLOB.antagonist_teams)
		return MAP_ERROR
	var/list/possible_spawns = list()//Some xeno spawns are in some spots that will instantly kill the refugees, like atmos
	for(var/turf/X in GLOB.xeno_spawn)
		if(istype(X.loc, /area/maintenance))
			possible_spawns += X
	if(!length(possible_spawns))
		message_admins("No valid spawn locations found, aborting...")
		return MAP_ERROR
	var/turf/landing_turf = pick(possible_spawns)
	var/list/candidates = get_candidates(ROLE_FUGITIVE, /datum/role_preference/midround_ghost/fugitive)
	var/result = spawn_fugitives(landing_turf, candidates, spawned_mobs)
	if(result != SUCCESSFUL_SPAWN)
		return result
	// Switch the round event to "hunter" mode
	role_name = ROLE_FUGITIVE_HUNTER
	return SUCCESSFUL_SPAWN

/proc/spawn_fugitives(turf/landing_turf, list/candidates, list/spawned_mobs)
	var/list/possible_backstories = list()
	for(var/type_key as() in GLOB.fugitive_types)
		var/datum/fugitive_type/F = GLOB.fugitive_types[type_key]
		// without this second check it will filter out "safe" backstories even if there are enough players to fill it
		if(length(candidates) > F.max_amount_allowed && F.max_amount_allowed < MAXIMUM_TOTAL_FUGITIVES)
			continue
		// Not enough for this backstory
		if(length(candidates) < F.min_spawn_amount)
			continue
		possible_backstories += type_key
	if(!length(possible_backstories) || length(candidates) < 1)
		return NOT_ENOUGH_PLAYERS

	var/datum/fugitive_type/backstory = GLOB.fugitive_types[admin_select_backstory(possible_backstories)]
	var/member_size = min(length(candidates), backstory.max_spawn_amount)
	var/leader
	if(backstory.has_leader)
		leader = pick_n_take(candidates)
		member_size--
		var/mob/living/carbon/human/S = gear_fugitive(1, leader, landing_turf, backstory, leader = TRUE)
		spawned_mobs += S

	for(var/i in 1 to member_size)
		var/mob/dead/selected = pick_n_take(candidates)
		if(!selected)
			continue
		var/mob/living/carbon/human/S = gear_fugitive(i, selected, landing_turf, backstory)
		spawned_mobs += S

	// After spawning:
	playsound(landing_turf, 'sound/weapons/emitter.ogg', 50, TRUE)
	// Tools so they can actually escape maintenance
	new /obj/item/storage/toolbox/mechanical(landing_turf)

	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(spawn_hunters)), 10 MINUTES)
	return SUCCESSFUL_SPAWN

/proc/gear_fugitive(index, mob/dead/selected, turf/landing_turf, datum/fugitive_type/backstory, leader = FALSE)
	var/datum/mind/player_mind = new /datum/mind(selected.key)
	player_mind.active = TRUE
	var/mob/living/carbon/human/S = new(landing_turf)
	player_mind.transfer_to(S)
	player_mind.assigned_role = ROLE_FUGITIVE
	player_mind.special_role = ROLE_FUGITIVE
	var/datum/antagonist/fugitive/A = new()
	A.backstory = backstory
	player_mind.add_antag_datum(A)
	var/outfit = (leader && backstory.has_leader) ? backstory.leader_outfit : backstory.outfit
	if(islist(outfit))
		outfit = outfit[((index - 1) % length(outfit)) + 1]
	S.equipOutfit(outfit)

	message_admins("[ADMIN_LOOKUPFLW(S)] has been made into a Fugitive by an event.")
	log_game("[key_name(S)] was spawned as a Fugitive by an event.")
	return S

// Security team gets called in after 10 minutes of prep to find the fugitives
/proc/spawn_hunters()
	set waitfor = FALSE
	var/datum/fugitive_type/hunter/backstory = GLOB.hunter_types[admin_select_backstory(GLOB.hunter_types)]
	var/list/candidates = poll_ghost_candidates("The Fugitive Hunters are looking for a [backstory.name]. Would you like to be considered for this role?", ROLE_FUGITIVE_HUNTER, /datum/role_preference/midround_ghost/fugitive_hunter, 15 SECONDS)
	var/datum/map_template/shuttle/ship = new backstory.ship_type
	var/x = rand(TRANSITIONEDGE,world.maxx - TRANSITIONEDGE - ship.width)
	var/y = rand(TRANSITIONEDGE,world.maxy - TRANSITIONEDGE - ship.height)
	var/z = SSmapping.empty_space.z_value
	var/turf/T = locate(x,y,z)
	if(!T)
		CRASH("Fugitive Hunters (Created from fugitive event) found no turf to load in")
	var/datum/async_map_generator/template_placer = ship.load(T)
	template_placer.on_completion(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(announce_fugitive_spawns), ship, candidates, backstory))

/proc/announce_fugitive_spawns(datum/map_template/shuttle/ship, list/candidates, datum/fugitive_type/hunter/backstory, datum/map_generator/map_generator, turf/T)
	var/obj/effect/mob_spawn/human/fugitive_hunter/leader_spawn
	var/list/spawners = list()
	for(var/turf/A in ship.get_affected_turfs(T))
		for(var/obj/effect/mob_spawn/human/fugitive_hunter/spawner in A)
			spawner.backstory = backstory
			if(istype(spawner, /obj/effect/mob_spawn/human/fugitive_hunter/leader))
				spawner.name = "[backstory.name] leader pod"
				leader_spawn = spawner
			else
				spawner.name = "[backstory.name] pod"
				spawners += spawner
	// Leader goes first, so this is the first one taken
	if(istype(leader_spawn))
		announce_fugitive_pod(leader_spawn, candidates)
	for(var/obj/effect/mob_spawn/human/fugitive_hunter/spawner as() in spawners)
		announce_fugitive_pod(spawner, candidates)
	priority_announce("Unidentified ship detected near the station.", sound = SSstation.announcer.get_rand_alert_sound())

/proc/announce_fugitive_pod(obj/effect/mob_spawn/human/fugitive_hunter/spawner, list/candidates)
	if(length(candidates))
		var/mob/M = pick_n_take(candidates)
		spawner.create(M.ckey)
		notify_ghosts("The fugitive hunter ship has an object of interest: [M]!", source=M, action=NOTIFY_ORBIT, header="Something's Interesting!")
	else
		notify_ghosts("The fugitive hunter ship has an object of interest: [spawner]!", source=spawner, action=NOTIFY_ORBIT, header="Something's Interesting!")

/proc/admin_select_backstory(list/backstory_keys)
	GLOB.fugitive_backstory_selection = backstory_keys
	message_admins("Choosing random fugitive backstory in 20 seconds. \
		<a href='byond://?_src_=holder;[HrefToken(TRUE)];backstory_select=[REF(backstory_keys)]'>SELECT MANUALLY</a>")
	play_sound_to_all_admins('sound/effects/admin_alert.ogg')
	sleep(20 SECONDS)
	return pick(GLOB.fugitive_backstory_selection)
