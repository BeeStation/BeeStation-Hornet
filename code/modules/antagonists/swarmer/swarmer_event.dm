/datum/round_event_control/spawn_swarmer
	name = "Spawn Swarmer Shell"
	typepath = /datum/round_event/spawn_swarmer
	weight = 7
	max_occurrences = 1 //Only once okay fam
	earliest_start = 30 MINUTES
	min_players = 15
	dynamic_should_hijack = TRUE

/datum/round_event_control/spawn_swarmer/preRunEvent()
	if(!GLOB.the_gateway)
		return EVENT_CANT_RUN // We don't return CANT_RUN if the gateway is off because this disqualifies the event from EVER running again.
	..()

/datum/round_event/spawn_swarmer

/datum/round_event/spawn_swarmer/start()
	if(find_swarmer())
		return FALSE // There already is active swarmers
	if(isnull(GLOB.the_gateway))
		return FALSE // There is no gateway
	if(!GLOB.the_gateway.powered() || !GLOB.the_gateway.active)
		return FALSE // The gateway
	new /obj/effect/mob_spawn/swarmer(get_step(GLOB.the_gateway, SOUTH))
	if(prob(25)) //25% chance to announce it to the crew
		announce_swarmer()

/proc/announce_swarmer()
	var/swarmer_report = "<span class='big bold'>[command_name()] High-Priority Update</span>"
	swarmer_report += "<br><br>Our long-range sensors have detected an odd signal emanating from your station's gateway. We recommend immediate investigation of your gateway, as something may have come through."
	print_command_report(swarmer_report, announce=TRUE)

/datum/round_event/spawn_swarmer/proc/find_swarmer()
	for(var/i in GLOB.mob_living_list)
		var/mob/living/L = i
		if(istype(L, /mob/living/simple_animal/hostile/swarmer) && L.client) //If there is a swarmer with an active client, we've found our swarmer
			return 1
	return 0
