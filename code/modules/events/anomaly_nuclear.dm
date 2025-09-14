/datum/round_event_control/anomaly/anomaly_nuclear
	name = "Anomaly: Nuclear"
	typepath = /datum/round_event/anomaly/anomaly_nuclear

	max_occurrences = 5
	weight = 20

/datum/round_event/anomaly/anomaly_nuclear
	startWhen = 3
	announceWhen = 10
	anomaly_path = /obj/effect/anomaly/nuclear

/datum/round_event/anomaly/anomaly_nuclear/announce(fake)
	priority_announce("Nuclear anomaly detected on long range scanners. Expected location: [impact_area.name].", "Anomaly Alert", SSstation.announcer.get_rand_alert_sound())
