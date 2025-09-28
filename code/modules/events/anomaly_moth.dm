/datum/round_event_control/anomaly/anomaly_moth
	name = "Anomaly: Moth"
	typepath = /datum/round_event/anomaly/anomaly_moth

	max_occurrences = 5
	weight = 20

/datum/round_event/anomaly/anomaly_moth
	startWhen = 3
	announceWhen = 10
	anomaly_path = /obj/effect/anomaly/moth

/datum/round_event/anomaly/anomaly_moth/announce(fake)
	priority_announce("Moth anomaly detected on long range scanners. Expected location: [impact_area.name].", "Anomaly Alert", SSstation.announcer.get_rand_alert_sound())
