/datum/round_event_control/anomaly/anomaly_clown
	name = "Anomaly: Clown"
	typepath = /datum/round_event/anomaly/anomaly_clown

	max_occurrences = 5
	weight = 20

/datum/round_event/anomaly/anomaly_clown
	startWhen = 3
	announceWhen = 10
	anomaly_path = /obj/effect/anomaly/clown

/datum/round_event/anomaly/anomaly_clown/announce(fake)
	priority_announce("Clown anomaly detected on long range scanners. Expected location: [impact_area.name].", "Anomaly Alert", SSstation.announcer.get_rand_alert_sound())
