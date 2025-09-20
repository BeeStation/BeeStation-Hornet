/datum/round_event_control/anomaly/anomaly_omni
	name = "Anomaly: Omni"
	typepath = /datum/round_event/anomaly/anomaly_omni

	max_occurrences = 5
	weight = 5

/datum/round_event/anomaly/anomaly_omni
	startWhen = 3
	announceWhen = 10
	anomaly_path = /obj/effect/anomaly/omni

/datum/round_event/anomaly/anomaly_omni/announce(fake)
	priority_announce("An anomaly transcending all others has been detected on long range scanners. Expected location: [impact_area.name].", "Anomaly Alert", SSstation.announcer.get_rand_alert_sound())
