/datum/round_event_control/spider_infestation
	name = "Spider Infestation"
	typepath = /datum/round_event/ghost_role/spider_infestation
	weight = 10

	min_players = 20

	dynamic_should_hijack = TRUE
	can_malf_fake_alert = TRUE

/datum/round_event/ghost_role/spider_infestation
	announceWhen = 400
	var/spawncount = 2

/datum/round_event/ghost_role/spider_infestation/setup()
	announceWhen = rand(announceWhen, announceWhen + 50)

/datum/round_event/ghost_role/spider_infestation/announce(fake)
	priority_announce("Unidentified lifesigns detected coming aboard [station_name()]. Secure any exterior access, including ducting and ventilation.", "Lifesign Alert", ANNOUNCER_ALIENS)

/datum/round_event/ghost_role/alien_infestation/spawn_role()
	var/list/vents = list()
	for(var/obj/machinery/atmospherics/components/unary/vent_pump/temp_vent in GLOB.machines)
		if(QDELETED(temp_vent))
			continue
		if(is_station_level(temp_vent.loc.z) && !temp_vent.welded)
			var/datum/pipeline/temp_vent_parent = temp_vent.parents[1]
			if(!temp_vent_parent)
				continue// no parent vent

			if(temp_vent_parent.other_atmosmch.len > 20)
				vents += temp_vent // Makes sure the vent network's big enough

	if(!vents.len)
		message_admins("An event attempted to spawn spiders but no suitable vents were found. Using backup spawning.")
		return MAP_ERROR

	var/list/candidates = get_candidates(ROLE_ALIEN, null, ROLE_ALIEN)

	while(spawncount > 0 && vents.len && candidates.len)
		var/obj/vent = pick_n_take(vents)
		var/client/C = pick_n_take(candidates)

		/mob/living/simple_animal/hostile/poison/giant_spider/nurse/midwife/spooder = new(vent.loc)
		spooder.key = C.key

		spawncount--
		message_admins("[ADMIN_LOOKUPFLW(new_xeno)] has been made into a spider by an event.")
		log_game("[key_name(new_xeno)] was spawned as a spider by an event.")
		spawned_mobs += spooder

	if(spawncount)
		if(create_midwife_eggs(spawncount) == TRUE)
			return SUCCESSFUL_SPAWN
		else
			return MAP_ERROR

	return SUCCESSFUL_SPAWN

/proc/create_midwife_eggs(amount)
	var/list/spawn_locs = list()
	for(var/x in GLOB.xeno_spawn)
		var/turf/spawn_turf = x
		var/light_amount = spawn_turf.get_lumcount()
		if(light_amount < SHADOW_SPECIES_LIGHT_THRESHOLD)
			spawn_locs += spawn_turf
	if(spawn_locs.len < amount)
		message_admins("Not enough valid spawn locations found in GLOB.xeno_spawn, aborting spider spawning...")
		return MAP_ERROR
	while(amount > 0)
		var/obj/structure/spider/eggcluster/midwife/new_eggs = new /obj/structure/spider/eggcluster/midwife(pick_n_take(spawn_locs))
		new_eggs.amount_grown = 98
		amount--
	log_game("Midwife spider eggs were spawned via an event.")
	return TRUE
