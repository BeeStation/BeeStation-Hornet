/datum/starter_ship_template/vanguard
	faction_flags = FACTION_SYNDICATE
	template_cost = 150
	job_roles = list(
		/datum/job/assistant/syndicate = INFINITY,
	)
	spawned_template = /datum/map_template/shuttle/ship/vanguard
	description = "The vanguard is a small 2 person scouting vessel. It is equipped with a single devestating railgun and has a \
		well-equipped armoury, but has little in the way of engineering or medical areas."

/datum/map_template/shuttle/ship/vanguard
	name = "SYN Vanguard"
	suffix = "vanguard"

/area/shuttle/vanguard
	name = "The Vanguard"
	icon_state = "yellow"
	requires_power = TRUE
