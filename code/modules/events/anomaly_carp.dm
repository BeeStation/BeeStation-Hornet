/datum/round_event_control/anomaly/anomaly_carp
	name = "Anomaly: Carp"
	typepath = /datum/round_event/anomaly/anomaly_carp

	max_occurrences = 5
	weight = 20

/datum/round_event/anomaly/anomaly_carp
	startWhen = 3
	announceWhen = 10
	anomaly_path = /obj/effect/anomaly/carp

/datum/round_event/anomaly/anomaly_carp/announce(fake)
	priority_announce("Carp anomaly detected on long range scanners. Expected location: [impact_area.name].", "Anomaly Alert", SSstation.announcer.get_rand_alert_sound())
