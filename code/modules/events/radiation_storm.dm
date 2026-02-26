/datum/round_event_control/radiation_storm
	name = "Radiation Storm"
	typepath = /datum/round_event/radiation_storm
	max_occurrences = 1
	can_malf_fake_alert = TRUE

/datum/round_event/radiation_storm
	/// Sound playlist for fake alerts - maps areas to looping sound types
	var/list/playlist = list()

/datum/round_event/radiation_storm/setup()
	startWhen = 3
	endWhen = startWhen + 1
	announceWhen = 1

/datum/round_event/radiation_storm/announce(fake)
	priority_announce("High levels of radiation detected near the station. Maintenance is best shielded from radiation.", "Anomaly Alert", ANNOUNCER_RADIATION)

	// Real alerts are handled by the weather system
	if(!fake)
		return ..()

	// Fake alerts need manual status display and sound handling
	var/datum/radio_frequency/frequency = SSradio.return_frequency(FREQ_STATUS_DISPLAYS)
	if(frequency)
		var/datum/signal/signal = new
		signal.data["command"] = "alert"
		signal.data["picture_state"] = "radiation"
		var/atom/movable/virtualspeaker/virt = new(null)
		frequency.post_signal(virt, signal)

	// Build sound playlist for each area
	var/list/eligible_areas = list()
	for(var/z in SSmapping.levels_by_trait(ZTRAIT_STATION))
		eligible_areas += SSmapping.areas_in_z["[z]"]
	for(var/i in 1 to length(eligible_areas))
		var/area/place = eligible_areas[i]
		if(istype(place, /area/maintenance))
			playlist[place] = /datum/looping_sound/rad_alert_inside
		else
			playlist[place] = /datum/looping_sound/rad_alert_outside
		CHECK_TICK

	GLOB.rad_storm_sounds += playlist
	SEND_GLOBAL_SIGNAL(COMSIG_WEATHER_TELEGRAPH(/datum/weather/rad_storm))
	addtimer(CALLBACK(src, PROC_REF(cleanup_fake_alert)), 40 SECONDS)
	return ..()

/// Cleans up sounds and status displays after a fake radiation alert
/datum/round_event/radiation_storm/proc/cleanup_fake_alert()
	GLOB.rad_storm_sounds -= playlist
	SEND_GLOBAL_SIGNAL(COMSIG_WEATHER_END(/datum/weather/rad_storm))

	var/datum/radio_frequency/frequency = SSradio.return_frequency(FREQ_STATUS_DISPLAYS)
	if(frequency)
		var/datum/signal/signal = new
		signal.data["command"] = "shuttle"
		var/atom/movable/virtualspeaker/virt = new(null)
		frequency.post_signal(virt, signal)

/datum/round_event/radiation_storm/start()
	SSweather.run_weather(/datum/weather/rad_storm)
