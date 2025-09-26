/datum/round_event_control/anomaly/anomaly_pyro
	name = "Anomaly: Pyroclastic"
	description = "This anomaly sets things on fire, and creates a pyroclastic slime."
	typepath = /datum/round_event/anomaly/anomaly_pyro

	max_occurrences = 5
	weight = 20

/datum/round_event/anomaly/anomaly_pyro
	start_when = 3
	announce_when = 10
	anomaly_path = /obj/effect/anomaly/pyro

/datum/round_event/anomaly/anomaly_pyro/announce(fake)
	priority_announce("Pyroclastic anomaly detected on long range scanners. Expected location: [impact_area.name].", "Anomaly Alert", SSstation.announcer.get_rand_alert_sound())
