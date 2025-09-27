/datum/round_event_control/anomaly/anomaly_monkey
	name = "Anomaly: Monkey"
	typepath = /datum/round_event/anomaly/anomaly_monkey

	max_occurrences = 5
	weight = 20

/datum/round_event/anomaly/anomaly_monkey
	startWhen = 3
	announceWhen = 10
	anomaly_path = /obj/effect/anomaly/monkey

/datum/round_event/anomaly/anomaly_monkey/announce(fake)
	priority_announce("Monkey anomaly detected on long range scanners. Expected location: [impact_area.name].", "Anomaly Alert", SSstation.announcer.get_rand_alert_sound())
