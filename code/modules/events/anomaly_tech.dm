/datum/round_event_control/anomaly/anomaly_tech
	name = "Anomaly: Tech"
	typepath = /datum/round_event/anomaly/anomaly_tech

	max_occurrences = 5
	weight = 20

/datum/round_event/anomaly/anomaly_tech
	startWhen = 3
	announceWhen = 10
	anomaly_path = /obj/effect/anomaly/tech

/datum/round_event/anomaly/anomaly_tech/announce(fake)
	priority_announce("EMP anomaly detected on long range scanners. Expected location: [impact_area.name].", "Anomaly Alert", SSstation.announcer.get_rand_alert_sound())
