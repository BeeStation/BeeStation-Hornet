/datum/round_event_control/anomaly/anomaly_lock
	name = "Anomaly: Lock"
	typepath = /datum/round_event/anomaly/anomaly_lock

	max_occurrences = 5
	weight = 20

/datum/round_event/anomaly/anomaly_lock
	startWhen = 3
	announceWhen = 10
	anomaly_path = /obj/effect/anomaly/lock

/datum/round_event/anomaly/anomaly_lock/announce(fake)
	priority_announce("Lock anomaly detected on long range scanners. Expected location: [impact_area.name].", "Anomaly Alert", SSstation.announcer.get_rand_alert_sound())
