/datum/round_event_control/raticide
	name = "Raticide"
	typepath = /datum/round_event/ghost_role/raticide
	weight = 8

	min_players = 10

/datum/round_event/ghost_role/raticide
	minimum_required = 1
	role_name = "regal rat"
	var/regal_rats = 5
	var/minimum_mice = 5
	var/maximum_mice = 15

/datum/round_event/ghost_role/raticide/setup()
	announceWhen = rand(announceWhen, announceWhen + 50)
	regal_rats = rand (2,5)

/datum/round_event/ghost_role/raticide/announce(fake)
	var/cause = pick("space-winter", "budget-cuts", "Ragnarok",
		"space being cold", "\[REDACTED\]", "climate change",
		"bad luck")
	var/plural = pick("a number of", "a horde of", "a pack of", "a swarm of",
		"a whoop of", "not more than [maximum_mice]")
	var/name = pick("rodents", "mice", "squeaking things",
		"wire eating mammals", "\[REDACTED\]", "energy draining parasites")
	var/movement = pick("migrated", "swarmed", "stampeded", "descended")
	var/location = pick("maintenance tunnels", "maintenance areas",
		"\[REDACTED\]", "place with all those juicy wires")

	priority_announce("Due to [cause], [plural] [name] have [movement] \
		into the [location].", "Migration Alert",
		'sound/effects/mousesqueek.ogg')


/datum/round_event/ghost_role/raticide/spawn_role()
	var/list/possible_spawns = list()//Some xeno spawns are in some spots that will instantly kill the refugees, like atmos
	for(var/turf/X in GLOB.xeno_spawn)
		if(istype(X.loc, /area/maintenance))
			possible_spawns += X
	if(!possible_spawns.len)
		message_admins("No valid spawn locations found, aborting...")
		return MAP_ERROR

	var/list/candidates = get_candidates(ROLE_ALIEN, null, ROLE_ALIEN)

	if(!candidates.len)
		return NOT_ENOUGH_PLAYERS

	while(regal_rats > 0 && possible_spawns.len && candidates.len)
		var/turf/landing_turf = pick_n_take(possible_spawns)
		var/client/C = pick_n_take(candidates)


		var/mob/living/simple_animal/hostile/rat/king/your_king = new(landing_turf)
		your_king.key = C.key
	
		regal_rats--
		message_admins("[ADMIN_LOOKUPFLW(your_king)] has been made into a rat king by an event.")
		log_game("[key_name(your_king)] was spawned as a rat king by an event.")
		spawned_mobs += your_king
		
	var/num_rats = rand(minimum_mice,maximum_mice)
	var/mob/living/simple_animal/hostile/rat/simp/pleb

	while((num_rats > 0) && possible_spawns.len)
		var/proposed_turf = pick_n_take(possible_spawns)
		if(!pleb)
			pleb = new(proposed_turf)
		else
			pleb.forceMove(proposed_turf)
		if(pleb.environment_air_is_safe())
			num_rats --
			pleb = null

	return SUCCESSFUL_SPAWN
