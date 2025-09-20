/datum/round_event_control/anomaly/anomaly_exo
	name = "Anomaly: Exothermic"
	typepath = /datum/round_event/anomaly/anomaly_exo

	max_occurrences = 5
	weight = 20

/datum/round_event/anomaly/anomaly_exo
	startWhen = 3
	announceWhen = 10
	anomaly_path = /obj/effect/anomaly/exo

/datum/round_event/anomaly/anomaly_exo/announce(fake)
	priority_announce("Exothermic anomaly detected on long range scanners. Expected location: [impact_area.name].", "Anomaly Alert", SSstation.announcer.get_rand_alert_sound())
