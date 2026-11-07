/datum/weather/snow_storm
	name = "snow storm"
	desc = "Harsh snowstorms roam the topside of this arctic planet, burying any area unfortunate enough to be in its path."
	probability = 90

	telegraph_message = span_warning("Drifting particles of snow begin to dust the surrounding area..")
	telegraph_duration = 30 SECONDS
	telegraph_overlay = "light_snow"

	weather_message = span_userdanger("<i>Harsh winds pick up as dense snow begins to fall from the sky! Seek shelter!</i>")
	weather_overlay = "snow_storm"
	weather_duration_lower = 1 MINUTES
	weather_duration_upper = 2.5 MINUTES

	end_duration = 10 SECONDS
	end_message = span_boldannounce("The snowfall dies down, it should be safe to go outside again.")

	///Suppressed for now, until a certain map comes back
	//area_type = /area/awaymission/snowdin/outside
	target_trait = ZTRAIT_AWAY

	immunity_type = TRAIT_SNOWSTORM_IMMUNE

	weather_flags = WEATHER_MOBS | WEATHER_BAROMETER | WEATHER_STRICT_ALERT

/datum/weather/snow_storm/weather_act_mob(mob/living/victim)
	victim.adjust_bodytemperature(-rand(5,15))

