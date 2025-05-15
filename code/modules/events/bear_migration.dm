/datum/round_event_control/bear_migration
	name = "Bear Migration"
	typepath = /datum/round_event/bear_migration
	weight = 15
	min_players = 2
	earliest_start = 10 MINUTES
	max_occurrences = 4
	map_whitelist = list("Echo Station")

/datum/round_event/bear_migration
	announceWhen = 3
	startWhen = 50
	var/hasAnnounced = FALSE

/datum/round_event/bear_migration/setup()
	startWhen = rand(40, 60)

/datum/round_event/bear_migration/announce(fake)
	priority_announce("Unknown mammalian entities have been detected near [station_name()], please stand-by.", "Lifesign Alert", SSstation.announcer.get_rand_alert_sound())


/datum/round_event/bear_migration/start()
	var/mob/living/simple_animal/hostile/bear/mammal
	for(var/obj/effect/landmark/carpspawn/B in GLOB.landmarks_list)
		if(prob(33))
			mammal = new (B.loc)
		else
			mammal = new /mob/living/simple_animal/hostile/bear/malnourished(B.loc)	//bears are much more dangerous than carps, so let's cut some slack.

	bearannounce(mammal)

/datum/round_event/bear_migration/proc/bearannounce(atom/mammal)
	if (!hasAnnounced)
		announce_to_ghosts(mammal)
		hasAnnounced = TRUE

