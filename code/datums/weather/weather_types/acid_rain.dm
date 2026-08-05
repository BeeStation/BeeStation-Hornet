//Acid rain is part of the natural weather cycle in the humid forests of Planetstation, and cause acid damage to anyone unprotected.
/datum/weather/acid_rain
	name = "acid rain"
	desc = "The planet's thunderstorms are by nature acidic, and will incinerate anyone standing beneath them without protection."

	telegraph_duration = 40 SECONDS
	telegraph_message = span_boldwarning("Thunder rumbles far above. You hear droplets drumming against the canopy. Seek shelter.")
	telegraph_sound = 'sound/ambience/acidrain_start.ogg'

	weather_message = span_userdanger("<i>Acidic rain pours down around you! Get inside!</i>")
	weather_overlay = "acid_rain"
	weather_duration_lower = 1 MINUTES
	weather_duration_upper = 2.5 MINUTES
	weather_sound = 'sound/ambience/acidrain_mid.ogg'

	end_duration = 10 SECONDS
	end_message = span_boldannounce("The downpour gradually slows to a light shower. It should be safe outside now.")
	end_sound = 'sound/ambience/acidrain_end.ogg'

	area_type = /area
	target_trait = ZTRAIT_ACIDRAIN

	weather_flags = WEATHER_MOBS | WEATHER_BAROMETER

/datum/weather/acid_rain/weather_act_mob(mob/living/victim)
	var/resist = victim.getarmor(null, ACID)
	if(prob(max(0, 100-resist)))
		victim.acid_act(20,20)
