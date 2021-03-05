
/datum/round_event_control/vitality
	name = "Random Human-level Intelligence"
	typepath = /datum/round_event/ghost_role/vitality
	weight = 10

/datum/round_event/ghost_role/vitality
	minimum_required = 1
	role_name = "random animal"
	var/spawns = 1
	var/one = "one"
	fakeable = TRUE

/datum/round_event/ghost_role/vitality/announce(fake)
	var/vitality_report = ""

	var/data = pick("scans from our long-range sensors", "our sophisticated probabilistic models", "our omnipotence", "the communications traffic on your station", "energy emissions we detected", "\[REDACTED\]")
	var/pets = pick("animals/bots", "bots/animals", "pets", "simple animals", "lesser lifeforms", "\[REDACTED\]")
	var/strength = pick("human", "moderate", "lizard", "security", "command", "clown", "low", "very low", "\[REDACTED\]")

	vitality_report += "Based on [data], we believe that [one] of the station's [pets] has developed [strength] level intelligence, and the ability to communicate."

	priority_announce(vitality_report,"[command_name()] Medium-Priority Update")

/datum/round_event/ghost_role/vitality/spawn_role()
	var/list/mob/dead/observer/candidates = get_candidates(ROLE_REVENANT, null, ROLE_REVENANT)
	
	if(!candidates.len)
		return NOT_ENOUGH_PLAYERS
	
	var/list/dead_bodies = list()
	
	for(var/mob/living/carbon/human/body in GLOB.dead_mob_list) //look for any dead bodies
		var/turf/T = get_turf(body)
		if(T && is_station_level(T.z))
			LAZYADD(body,dead_bodies)
			
			//check damage
			//check head, heart, garments
			//check if it still has a mind
	
	if(!dead_bodies.len)
		return WAITING_FOR_SOMETHING

	var/revived_zeds = min(spawns,candidates.len,potential.len)
	while(revived_zeds > 0)
		var/mob/living/carbon/human/zombie = popleft(potential)
		var/mob/dead/observer/SG = pick_n_take(dead_bodies)

		revived_zeds--

		SA.key = SG.key

		SA.vitality_act()

		spawned_mobs += SA

		to_chat(SA, "<span class='userdanger'>Hello world!</span>")
		to_chat(SA, "<span class='warning'>Due to freak radiation and/or chemicals \
			and/or lucky chance, you have gained human level intelligence \
			and the ability to speak and understand human language!</span>")

	return SUCCESSFUL_SPAWN