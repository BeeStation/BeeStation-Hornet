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
	var/list/possible_spawns = list()//Some xeno spawns are in some spots that will instantly kill the refugees, like atmos
	for(var/turf/X in GLOB.xeno_spawn)
		if(istype(X.loc, /area/maintenance))
			possible_spawns += X
	if(!length(possible_spawns))
		message_admins("No valid spawn locations found, aborting...")
		return MAP_ERROR
	var/turf/landing_turf = pick(possible_spawns)
	var/list/possible_backstories = list()

	var/list/candidates = get_candidates(ROLE_FUGITIVE, null, ROLE_FUGITIVE)

	for(var/type_key as() in GLOB.fugitive_types)
		var/datum/fugitive_type/F = GLOB.fugitive_types[type_key]
		if(length(candidates) > F.max_amount)
			continue
		possible_backstories += F
	if(!length(possible_backstories) || length(candidates) < 1)
		return NOT_ENOUGH_PLAYERS

	var/datum/fugitive_type/backstory = pick(possible_backstories)
	var/member_size = min(length(candidates), backstory.max_amount)
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
	playsound(src, 'sound/weapons/emitter.ogg', 50, 1)
	// Tools so they can actually escape maintenance
	new /obj/item/storage/toolbox/mechanical(landing_turf)

	// Switch the round event to "hunter" mode
	addtimer(CALLBACK(src, .proc/spawn_hunters), 10 MINUTES)
	role_name = ROLE_FUGITIVE_HUNTER
	return SUCCESSFUL_SPAWN

/datum/round_event/ghost_role/fugitives/proc/gear_fugitive(index, mob/dead/selected, turf/landing_turf, datum/fugitive_type/backstory, leader = FALSE)
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
/datum/round_event/ghost_role/fugitives/proc/spawn_hunters()
	var/datum/fugitive_type/hunter/backstory = GLOB.hunter_types[pick(GLOB.hunter_types)]
	var/list/candidates = pollGhostCandidates("The Fugitive Hunters are looking for a [backstory.name]. Would you like to be considered for this role?", ROLE_FUGITIVE_HUNTER)
	var/datum/map_template/shuttle/ship = new backstory.ship_type
	var/x = rand(TRANSITIONEDGE,world.maxx - TRANSITIONEDGE - ship.width)
	var/y = rand(TRANSITIONEDGE,world.maxy - TRANSITIONEDGE - ship.height)
	var/z = SSmapping.empty_space.z_value
	var/turf/T = locate(x,y,z)
	if(!T)
		CRASH("Fugitive Hunters (Created from fugitive event) found no turf to load in")
	var/datum/map_generator/template_placer = ship.load(T)
	template_placer.on_completion(CALLBACK(src, .proc/announce_fugitive_spawns, ship, candidates, backstory))

/datum/round_event/ghost_role/fugitives/proc/announce_fugitive_spawns(datum/map_template/shuttle/ship, list/candidates, backstory, datum/map_generator/map_generator, turf/T)
	var/obj/effect/mob_spawn/human/fugitive_hunter/leader_spawn
	var/list/spawners = list()
	for(var/turf/A in ship.get_affected_turfs(T))
		for(var/obj/effect/mob_spawn/human/fugitive_hunter/spawner in A)
			spawner.backstory = backstory
			if(istype(spawner, /obj/effect/mob_spawn/human/fugitive_hunter/leader))
				leader_spawn = spawner
			else
				spawners += spawner
	// Leader goes first, so this is the first one taken
	if(istype(leader_spawn))
		announce_pod(leader_spawn, candidates)
	for(var/obj/effect/mob_spawn/human/fugitive_hunter/spawner as() in spawners)
		announce_pod(spawner, candidates)
	priority_announce("Unidentified ship detected near the station.", sound = SSstation.announcer.get_rand_alert_sound())

/datum/round_event/ghost_role/fugitives/proc/announce_pod(obj/effect/mob_spawn/human/fugitive_hunter/spawner, list/candidates)
	if(length(candidates))
		var/mob/M = pick_n_take(candidates)
		spawner.create(M.ckey)
		notify_ghosts("The fugitive hunter ship has an object of interest: [M]!", source=M, action=NOTIFY_ORBIT, header="Something's Interesting!")
	else
		notify_ghosts("The fugitive hunter ship has an object of interest: [spawner]!", source=spawner, action=NOTIFY_ORBIT, header="Something's Interesting!")
