/// Used for all kinds of weather, ex. lavaland ash storms.
SUBSYSTEM_DEF(weather)
	name = "Weather"
	ss_flags = SS_BACKGROUND
	dependencies = list(
		/datum/controller/subsystem/mapping,
	)
	wait = 1 SECONDS
	runlevels = RUNLEVEL_GAME

	/// The weather instances that are currently processing
	var/list/processing = list()
	/// An associative list of z-levels to possible weathers
	var/list/eligible_zlevels = list()
	/// Used by barometers to know when the next storm is coming
	var/list/next_hit_by_zlevel = list()

/datum/controller/subsystem/weather/Initialize()
	for(var/datum/weather/weather_type as anything in subtypesof(/datum/weather))
		// any weather with a probability set may occur at random
		if (!weather_type::probability)
			continue

		for(var/z in SSmapping.levels_by_trait(weather_type::target_trait))
			LAZYINITLIST(eligible_zlevels["[z]"])
			eligible_zlevels["[z]"][weather_type] = weather_type::probability
	return SS_INIT_SUCCESS

/datum/controller/subsystem/weather/get_metrics()
	. = ..()
	var/list/cust = list()
	cust["processing"] = length(processing)
	.["custom"] = cust

/datum/controller/subsystem/weather/fire(resumed = FALSE)
	// process active weather
	for(var/datum/weather/weather_event as anything in processing)
		if(!(weather_event.weather_flags & WEATHER_MOBS) || weather_event.stage != MAIN_STAGE)
			continue

		for(var/mob/act_on as anything in GLOB.mob_living_list)
			if(weather_event.can_weather_act_mob(act_on))
				weather_event.weather_act_mob(act_on)

	// start random weather on relevant levels
	for(var/z in eligible_zlevels)
		var/possible_weather = eligible_zlevels[z]
		var/datum/weather/our_event = pick_weight(possible_weather)
		run_weather(our_event, list(text2num(z)))
		eligible_zlevels -= z
		var/rand_time = rand(5 MINUTES, 10 MINUTES)
		next_hit_by_zlevel["[z]"] = addtimer(CALLBACK(src, PROC_REF(make_eligible), z, possible_weather), rand_time + initial(our_event.weather_duration_upper), TIMER_UNIQUE|TIMER_STOPPABLE) //Around 5-10 minutes between weathers

/datum/controller/subsystem/weather/proc/run_weather(datum/weather/weather_datum_type, z_levels)
	if (!ispath(weather_datum_type, /datum/weather))
		CRASH("run_weather called with invalid weather_datum_type: [weather_datum_type || "null"]")

	if (isnull(z_levels))
		z_levels = SSmapping.levels_by_trait(initial(weather_datum_type.target_trait))
	else if (isnum_safe(z_levels))
		z_levels = list(z_levels)
	else if (!islist(z_levels))
		CRASH("run_weather called with invalid z_levels: [z_levels || "null"]")

	var/datum/weather/new_weather = new weather_datum_type(z_levels)
	new_weather.telegraph()

/datum/controller/subsystem/weather/proc/make_eligible(z, possible_weather)
	eligible_zlevels[z] = possible_weather
	next_hit_by_zlevel["[z]"] = null
