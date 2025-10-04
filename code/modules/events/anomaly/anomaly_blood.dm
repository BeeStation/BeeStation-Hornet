/datum/round_event_control/anomaly/blood
	name = "Anomaly: Blood"
	description = "This anomaly teleports to people and shoots projectiles at them."
	typepath = /datum/round_event/anomaly/blood

	min_players = 15
	max_occurrences = 2

/datum/round_event/anomaly/blood
	start_when = 3
	announce_when = 10
	anomaly_path = /obj/effect/anomaly/blood

/datum/round_event/anomaly/blood/announce(fake)
	priority_announce("Blood anomaly detected on long range scanners. Expected location: [impact_area.name].", "Anomaly Alert", SSstation.announcer.get_rand_alert_sound())
