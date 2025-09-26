/datum/round_event_control/easter
	name = "Easter Eggselence"
	description = "Hides surprise filled easter eggs in maintenance."
	category = EVENT_CATEGORY_HOLIDAY
	holidayID = EASTER
	typepath = /datum/round_event/easter
	weight = -1
	max_occurrences = 1
	earliest_start = 0 MINUTES

/datum/round_event/easter/announce(fake)
	priority_announce(pick("Hip-hop into Easter!","Find some Bunny's stash!","Today is National 'Hunt a Wabbit' Day.","Be kind, give Chocolate Eggs!"), sound = SSstation.announcer.get_rand_alert_sound())

/datum/round_event_control/rabbitrelease
	name = "Release the Rabbits!"
	description = "Summons a wave of cute rabbits."
	category = EVENT_CATEGORY_HOLIDAY
	holidayID = EASTER
	typepath = /datum/round_event/rabbitrelease
	weight = 5
	max_occurrences = 10

/datum/round_event/rabbitrelease/announce(fake)
	priority_announce("Unidentified furry objects detected coming aboard [station_name()]. Beware of Adorable-ness.", "Fluffy Alert", ANNOUNCER_ALIENS)


/datum/round_event/rabbitrelease/start()
	for(var/obj/effect/landmark/R in GLOB.landmarks_list)
		if(R.name != "blobspawn")
			if(prob(35))
				if(isspaceturf(R.loc))
					new /mob/living/simple_animal/rabbit/easter/space(R.loc)
				else
					new /mob/living/simple_animal/rabbit(R.loc)
