/datum/round_event_control/anomaly/anomaly_flesh
	name = "Anomaly: Flesh"
	typepath = /datum/round_event/anomaly/anomaly_flesh

	max_occurrences = 5
	weight = 20

/datum/round_event/anomaly/anomaly_flesh
	startWhen = 3
	announceWhen = 10
	anomaly_path = /obj/effect/anomaly/flesh

/datum/round_event/anomaly/anomaly_flesh/announce(fake)
	priority_announce("Flesh anomaly detected on long range scanners. Expected location: [impact_area.name].", "Anomaly Alert", SSstation.announcer.get_rand_alert_sound())
