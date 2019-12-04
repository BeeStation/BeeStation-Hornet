/datum/round_event_control/fugitives
	name = "Spawn Fugitives"
	typepath = /datum/round_event/ghost_role/fugitives
	max_occurrences = 1
	min_players = 20
	earliest_start = 30 MINUTES //deadchat sink, lets not even consider it early on.
	gamemode_blacklist = list("nuclear")

/datum/round_event/ghost_role/fugitives
	minimum_required = 1
	role_name = "fugitive"
	fakeable = FALSE

/datum/round_event/ghost_role/fugitives/spawn_role()
	var/turf/landing_turf = pick(GLOB.xeno_spawn)
	if(!landing_turf)
		message_admins("No valid spawn locations found, aborting...")
		return MAP_ERROR

	var/list/possible_backstories = list()
	var/list/candidates = get_candidates(ROLE_TRAITOR, null, ROLE_TRAITOR)
	if(candidates.len >= 1) //solo refugees
		possible_backstories += "waldo"
	if(candidates.len >= 4)//group refugees
		possible_backstories += "prisoner"
		possible_backstories += "cultists"
		possible_backstories += "synth"
	if(!possible_backstories.len)
		return NOT_ENOUGH_PLAYERS

	var/backstory = pick(possible_backstories)
	var/member_size = 3
	var/leader
	switch(backstory)
		if("cultists" || "synth")
			leader = pick_n_take(candidates)
		if("waldo")
			member_size = 0 //solo refugees have no leader so the member_size gets bumped to one a bit later
	var/list/members = list()
	var/list/spawned_mobs = list()
	if(isnull(leader))
		member_size++ //if there is no leader role, then the would be leader is a normal member of the team.

	for(var/i in 1 to member_size)
		members += pick_n_take(candidates)

	for(var/mob/dead/selected in members)
		var/mob/living/carbon/human/S = gear_fugitive(selected, landing_turf, backstory)
		spawned_mobs += S
	if(!isnull(leader))
		gear_fugitive_leader(leader, landing_turf, backstory)


//after spawning
	playsound(src, 'sound/weapons/emitter.ogg', 50, 1)
	new /obj/item/storage/toolbox/mechanical(landing_turf) //so they can actually escape maint
	addtimer(CALLBACK(src, .proc/spawn_hunters), 6000) //10 minutes
	role_name = "fugitive hunter"
	return SUCCESSFUL_SPAWN

/datum/round_event/ghost_role/fugitives/proc/gear_fugitive(var/mob/dead/selected, var/turf/landing_turf, backstory) //spawns normal fugitive
	var/datum/mind/player_mind = new /datum/mind(selected.key)
	player_mind.active = TRUE
	var/mob/living/carbon/human/S = new(landing_turf)
	player_mind.transfer_to(S)
	player_mind.assigned_role = "Fugitive"
	player_mind.special_role = "Fugitive"
	player_mind.add_antag_datum(/datum/antagonist/fugitive)
	var/datum/antagonist/fugitive/fugitiveantag = player_mind.has_antag_datum(/datum/antagonist/fugitive)
	INVOKE_ASYNC(fugitiveantag, /datum/antagonist/fugitive.proc/greet, backstory) //some fugitives have a sleep on their greet, so we don't want to stop the entire antag granting proc with fluff

	switch(backstory)
		if("prisoner")
			S.equipOutfit(/datum/outfit/prisoner)
		if("cultist")
			S.equipOutfit(/datum/outfit/yalp_cultist)
		if("waldo")
			S.equipOutfit(/datum/outfit/waldo)
		if("synth")
			S.equipOutfit(/datum/outfit/synthetic)
	message_admins("[ADMIN_LOOKUPFLW(S)] has been made into a Fugitive by an event.")
	log_game("[key_name(S)] was spawned as a Fugitive by an event.")
	spawned_mobs += S
	return S

 //special spawn for one member. it can be used for a special mob or simply to give one normal member special items.
/datum/round_event/ghost_role/fugitives/proc/gear_fugitive_leader(var/mob/dead/leader, var/turf/landing_turf, backstory)
	var/datum/mind/player_mind = new /datum/mind(leader.key)
	player_mind.active = TRUE
	switch(backstory)
		if("cultist")
			var/mob/camera/yalp_elor/yalp = new(landing_turf)
			player_mind.transfer_to(yalp)
			player_mind.assigned_role = "Yalp Elor"
			player_mind.special_role = "Old God"
			player_mind.add_antag_datum(/datum/antagonist/fugitive)
		if("synth")
			var/mob/living/carbon/human/S = gear_fugitive(leader, landing_turf, backstory)
			var/obj/item/choice_beacon/augments/A = new(S)
			S.put_in_hands(A)
			new /obj/item/autosurgeon(landing_turf)

//security team gets called in after 10 minutes of prep to find the refugees
/datum/round_event/ghost_role/fugitives/proc/spawn_hunters()
	var/backstory = pick("space cop", "russian")
	var/static/list/hunter_ship_types = list(
		"space cop"		= /datum/map_template/space_cop_ship,
		"russian"		= /datum/map_template/russian_ship)

	var/datum/map_template/ship = hunter_ship_types[backstory]
	ship = new
	var/x = rand(TRANSITIONEDGE,world.maxx - TRANSITIONEDGE - ship.width)
	var/y = rand(TRANSITIONEDGE,world.maxy - TRANSITIONEDGE - ship.height)
	var/z = SSmapping.empty_space.z_value
	var/turf/T = locate(x,y,z)
	if(!T)
		CRASH("Fugitive Hunters (Created from fugitive event) found no turf to load in")
	if(!ship.load(T))
		CRASH("Loading hunter ship failed!")
	priority_announce("Unidentified armed ship detected near the station.")
	for(var/turf/A in ship.get_affected_turfs(T))
		for(var/obj/structure/chair/chair in A) //every chair gets a spawner on it.
			switch(backstory)
				if("space cop")
					new /obj/effect/mob_spawn/human/fugitive/spacepol(get_turf(chair))
				if("russian")
					new /obj/effect/mob_spawn/human/fugitive/russian(get_turf(chair))
