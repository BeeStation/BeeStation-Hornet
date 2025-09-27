/datum/round_event_control/anomaly/anomaly_trap
	name = "Anomaly: Trap"
	typepath = /datum/round_event/anomaly/anomaly_trap

	max_occurrences = 5
	weight = 20

/datum/round_event/anomaly/anomaly_trap
	startWhen = 3
	announceWhen = 10
	anomaly_path = /obj/effect/anomaly/trap

/datum/round_event/anomaly/anomaly_trap/announce(fake)
	priority_announce("A beartrap anomaly detected on long range scanners. Expected location: [impact_area.name].", "Anomaly Alert", SSstation.announcer.get_rand_alert_sound())
