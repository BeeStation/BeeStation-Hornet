/datum/weather/snow_storm
	name = "snow storm"
	desc = "Harsh snowstorms roam the topside of this arctic planet, burying any area unfortunate enough to be in its path."
	probability = 90

	telegraph_message = "<span class='warning'>Drifting particles of snow begin to dust the surrounding area..</span>"
	telegraph_duration = 300
	telegraph_overlay = "light_snow"

	weather_message = "<span class='userdanger'><i>Harsh winds pick up as dense snow begins to fall from the sky! Seek shelter!</i></span>"
	weather_overlay = "snow_storm"
	weather_duration_lower = 600
	weather_duration_upper = 1500

	end_duration = 100
	end_message = "<span class='boldannounce'>The snowfall dies down, it should be safe to go outside again.</span>"

	area_type = /area
	protect_indoors = TRUE
	target_trait = ZTRAIT_SNOWSTORM

	immunity_type = "snow"

	barometer_predictable = TRUE

	protected_areas = list(/area/iceland/underground/safe)//Areas that are protected and excluded from the affected areas.

	var/list/weak_sounds = list()
	var/list/strong_sounds = list()
	///Lowest we can cool someone randomly per weather act. Positive values only
	var/cooling_lower = 5
	///Highest we can cool someone randomly per weather act. Positive values only
	var/cooling_upper = 15

/datum/weather/snow_storm/weather_act(mob/living/L)
	L.adjust_bodytemperature(-rand(cooling_lower, cooling_upper))

/datum/weather/snow_storm/telegraph()
	var/list/eligible_areas = list()
	for (var/z in impacted_z_levels)
		eligible_areas += SSmapping.areas_in_z["[z]"]
	for(var/i in 1 to eligible_areas.len)
		var/area/place = eligible_areas[i]
		if(place.outdoors)
			weak_sounds[place] = /datum/looping_sound/weak_outside_ashstorm
			strong_sounds[place] = /datum/looping_sound/active_outside_ashstorm
		else
			weak_sounds[place] = /datum/looping_sound/weak_inside_ashstorm
			strong_sounds[place] = /datum/looping_sound/active_inside_ashstorm
		CHECK_TICK

	//We modify this list instead of setting it to weak/stron sounds in order to preserve things that hold a reference to it
	//It's essentially a playlist for a bunch of components that chose what sound to loop based on the area a player is in
	GLOB.ash_storm_sounds += weak_sounds
	return ..()

/datum/weather/snow_storm/start()
	GLOB.ash_storm_sounds -= weak_sounds
	GLOB.ash_storm_sounds += strong_sounds
	return ..()

/datum/weather/snow_storm/wind_down()
	GLOB.ash_storm_sounds -= strong_sounds
	GLOB.ash_storm_sounds += weak_sounds
	return ..()

/datum/weather/snow_storm/end()
	GLOB.ash_storm_sounds -= weak_sounds
	return ..()

//Snowfalls are the result of an ash storm passing by close to the playable area of Iceland. They have a 15% chance to trigger in place of an snow storm.
/datum/weather/snow_storm/snowfall
	name = "snowfall"
	desc = "A passing snow storm blankets the area in a gentle snow."

	weather_message = "<span class='notice'>Gentle snow waft down around you. The storm seems to have passed you by...</span>"
	weather_overlay = "light_ash"

	end_message = "<span class='notice'>The snowfall slows, stops. Another layer of hardened snow to the ground beneath your feet.</span>"
	end_sound = null

	aesthetic = TRUE

	probability = 15

///A storm that doesn't stop storming, and is a bit stronger only admin triggerable
/datum/weather/snow_storm/forever_storm
	telegraph_duration = 0
	perpetual = TRUE
	probability = 0
	cooling_lower = 10
	cooling_upper = 20
