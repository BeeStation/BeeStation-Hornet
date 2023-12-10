/datum/round_event_control/anomaly/insanity_pulse
	name = "Anomaly: Sanity Disruptor"
	typepath = /datum/round_event/anomaly/insanity_pulse

	min_players = 15
	max_occurrences = 2
	weight = 25
	// This has a high chance to appear, but needs more players

/datum/round_event/anomaly/insanity_pulse
	startWhen = 3
	announceWhen = 10
	anomaly_path = /obj/effect/anomaly/insanity_pulse

/datum/round_event/anomaly/insanity_pulse/announce(fake)
	priority_announce("Sanity disruptor anomaly detected on long range scanners. Expected location: [impact_area.name].", "Anomaly Alert", SSstation.announcer.get_rand_alert_sound())
