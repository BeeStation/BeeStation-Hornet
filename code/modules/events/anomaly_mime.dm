/datum/round_event_control/anomaly/anomaly_mime
	name = "Anomaly: Mime"
	typepath = /datum/round_event/anomaly/anomaly_mime

	max_occurrences = 5
	weight = 20

/datum/round_event/anomaly/anomaly_mime
	startWhen = 3
	announceWhen = 10
	anomaly_path = /obj/effect/anomaly/mime

/datum/round_event/anomaly/anomaly_mime/announce(fake)
	priority_announce("Mime anomaly detected on long range scanners. Expected location: [impact_area.name].", "Anomaly Alert", SSstation.announcer.get_rand_alert_sound())
