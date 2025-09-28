/datum/round_event_control/anomaly/anomaly_endo
	name = "Anomaly: Endothermic"
	typepath = /datum/round_event/anomaly/anomaly_endo

	max_occurrences = 5
	weight = 20

/datum/round_event/anomaly/anomaly_endo
	startWhen = 3
	announceWhen = 10
	anomaly_path = /obj/effect/anomaly/endo

/datum/round_event/anomaly/anomaly_endo/announce(fake)
	priority_announce("Endothermic anomaly detected on long range scanners. Expected location: [impact_area.name].", "Anomaly Alert", SSstation.announcer.get_rand_alert_sound())
