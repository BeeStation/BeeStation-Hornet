/datum/round_event_control/radiation_storm
	name = "Radiation Storm"
	typepath = /datum/round_event/radiation_storm
	max_occurrences = 1
	can_malf_fake_alert = TRUE

/datum/round_event/radiation_storm


/datum/round_event/radiation_storm/setup()
	startWhen = 3
	endWhen = startWhen + 1
	announceWhen	= 1

/datum/round_event/radiation_storm/announce(fake)
	priority_announce("High levels of radiation detected near the station. Maintenance is best shielded from radiation.", "Anomaly Alert", ANNOUNCER_RADIATION)
	//sound not longer matches the text, but an audible warning is probably good

	// Copied from `radiation_storm.dm`
	if(fake)
		var/datum/radio_frequency/frequency = SSradio.return_frequency(FREQ_STATUS_DISPLAYS)
		if(!frequency)
			return

		var/datum/signal/signal = new
		signal.data["command"] = "alert"
		signal.data["picture_state"] = "radiation"

		var/atom/movable/virtualspeaker/virt = new(null)
		frequency.post_signal(virt, signal)

/datum/round_event/radiation_storm/start()
	SSweather.run_weather(/datum/weather/rad_storm)
