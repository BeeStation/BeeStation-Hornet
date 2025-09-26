/datum/round_event_control/anomaly/anomaly_vortex
	name = "Anomaly: Vortex"
	description = "This anomaly sucks in and detonates items."
	typepath = /datum/round_event/anomaly/anomaly_vortex

	min_players = 20
	max_occurrences = 2
	weight = 5

/datum/round_event/anomaly/anomaly_vortex
	start_when = 10
	announce_when = 3
	anomaly_path = /obj/effect/anomaly/bhole

/datum/round_event/anomaly/anomaly_vortex/announce(fake)
	priority_announce("Localized high-intensity vortex anomaly detected on long range scanners. Expected location: [impact_area.name]", "Anomaly Alert", SSstation.announcer.get_rand_alert_sound())
