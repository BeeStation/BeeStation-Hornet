/datum/round_event_control/space_dust
	name = "Minor Space Dust"
	description = "A single space dust is hurled at the station."
	category = EVENT_CATEGORY_SPACE
	typepath = /datum/round_event/space_dust
	weight = 200
	max_occurrences = 1000
	earliest_start = 0 MINUTES
	alert_observers = FALSE
	map_flags = EVENT_SPACE_ONLY

/datum/round_event/space_dust
	start_when		= 1
	end_when			= 2
	fakeable = FALSE

/datum/round_event/space_dust/start()
	spawn_meteors(1, GLOB.meteorsC)

/datum/round_event_control/sandstorm
	name = "Sandstorm"
	description = "The station is pelted by an extreme amount of dust, from all sides, for several minutes. Very destructive and likely to cause lag. Use at own risk."
	category = EVENT_CATEGORY_SPACE
	typepath = /datum/round_event/sandstorm
	weight = 0
	max_occurrences = 0
	earliest_start = 0 MINUTES

/datum/round_event/sandstorm
	start_when = 1
	end_when = 150 // ~5 min
	announce_when = 0
	fakeable = FALSE

/datum/round_event/sandstorm/tick()
	spawn_meteors(10, GLOB.meteorsC)
