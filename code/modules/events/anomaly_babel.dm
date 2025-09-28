/datum/round_event_control/anomaly/anomaly_babel
	name = "Anomaly: Babel"
	typepath = /datum/round_event/anomaly/anomaly_babel

	max_occurrences = 5
	weight = 20

/datum/round_event/anomaly/anomaly_babel
	startWhen = 3
	announceWhen = 10
	anomaly_path = /obj/effect/anomaly/babel

/datum/round_event/anomaly/anomaly_babel/announce(fake)
	priority_announce("Babel anomaly detected on long range scanners. Expected location: [impact_area.name].", "Anomaly Alert", SSstation.announcer.get_rand_alert_sound())
