/datum/round_event_control/spider_infestation
	name = "Spider Infestation (AI-Controlled)"
	typepath = /datum/round_event/spider_infestation
	weight = 5
	max_occurrences = 1
	min_players = 10
	dynamic_should_hijack = TRUE
	can_malf_fake_alert = TRUE

/datum/round_event/spider_infestation
	announceWhen = 400
	var/sentient = FALSE
	var/spawncount = 1

/datum/round_event/spider_infestation/setup()
	announceWhen = rand(announceWhen, announceWhen + 50)
	spawncount = rand(5, 8)

/datum/round_event/spider_infestation/announce(fake)
	priority_announce("Unidentified lifesigns detected coming aboard [station_name()]. Secure any exterior access, including ducting and ventilation.", "Lifesign Alert", ANNOUNCER_ALIENS)

/datum/round_event/spider_infestation/start()
	var/list/vents = list()
	for(var/obj/machinery/atmospherics/components/unary/vent_pump/temp_vent in GLOB.machines)
		if(QDELETED(temp_vent))
			continue
		if(is_station_level(temp_vent.loc.z) && !temp_vent.welded)
			var/datum/pipeline/temp_vent_parent = temp_vent.parents[1]
			if(temp_vent_parent.other_atmosmch.len > 20)
				vents += temp_vent

	while((spawncount >= 1) && vents.len)
		var/obj/vent = pick(vents)
		var/spawn_type = /obj/structure/spider/spiderling
		if(spawncount > 1 && prob(50))
			spawn_type = /obj/structure/spider/spiderling/nurse
		if(sentient && spawncount == 1) // If it's sentient spiders, always give them a midwife so they can coordinate and have someone to make more spiders
			spawn_type = /obj/structure/spider/spiderling/midwife
		var/obj/structure/spider/spiderling/new_spider = spawn_atom_to_turf(spawn_type, vent, 1, FALSE)
		if(sentient)
			new_spider.player_spiders = TRUE
		announce_to_ghosts(spawn_atom_to_turf(spawn_type, vent, 1, FALSE))
		vents -= vent
		spawncount--

/datum/round_event_control/spider_infestation/sentient
	name = "Spider Infestation (Player-Controlled)"
	typepath = /datum/round_event/spider_infestation/sentient
	min_players = 15

/datum/round_event/spider_infestation/sentient
	announceWhen = 400
	sentient = FALSE
	spawncount = 1
	sentient = TRUE
