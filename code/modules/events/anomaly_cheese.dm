/datum/round_event_control/anomaly/anomaly_cheese
	name = "Anomaly: Cheese"
	typepath = /datum/round_event/anomaly/anomaly_cheese

	max_occurrences = 5
	weight = 20

/datum/round_event/anomaly/anomaly_cheese
	startWhen = 3
	announceWhen = 10
	anomaly_path = /obj/effect/anomaly/cheese

/datum/round_event/anomaly/anomaly_cheese/announce(fake)
	priority_announce("Cheese anomaly detected on long range scanners. Expected location: [impact_area.name].", "Anomaly Alert", SSstation.announcer.get_rand_alert_sound())
