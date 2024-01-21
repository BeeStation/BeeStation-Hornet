/datum/round_event_control/anomaly/insanity_pulse
	name = "Anomaly: Sanity Disruptor"
	typepath = /datum/round_event/anomaly/insanity_pulse

	min_players = 15
	max_occurrences = 2

/datum/round_event/anomaly/insanity_pulse
	start_when = 3
	announce_when = 10
	anomaly_path = /obj/effect/anomaly/insanity_pulse

/datum/round_event/anomaly/insanity_pulse/announce(fake)
	priority_announce("Sanity disruptor anomaly detected on long range scanners. Expected location: [impact_area.name].", "Anomaly Alert", SSstation.announcer.get_rand_alert_sound())
