/datum/round_event_control/anomaly/anomaly_glitch
	name = "Anomaly: Glitch"
	typepath = /datum/round_event/anomaly/anomaly_glitch

	max_occurrences = 5
	weight = 10

/datum/round_event/anomaly/anomaly_glitch
	startWhen = 3
	announceWhen = 10
	anomaly_path = /obj/effect/anomaly/glitch

/datum/round_event/anomaly/anomaly_glitch/announce(fake)
	priority_announce("Glitch anomaly detected on long range scanners. Expected location: [impact_area.name].", "Anomaly Alert", SSstation.announcer.get_rand_alert_sound())
