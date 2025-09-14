/datum/round_event_control/anomaly/anomaly_greed
	name = "Anomaly: Greed"
	typepath = /datum/round_event/anomaly/anomaly_greed

	max_occurrences = 5
	weight = 20

/datum/round_event/anomaly/anomaly_greed
	startWhen = 3
	announceWhen = 10
	anomaly_path = /obj/effect/anomaly/greed

/datum/round_event/anomaly/anomaly_greed/announce(fake)
	priority_announce("Coin anomaly detected on long range scanners. Expected location: [impact_area.name].", "Anomaly Alert", SSstation.announcer.get_rand_alert_sound())
