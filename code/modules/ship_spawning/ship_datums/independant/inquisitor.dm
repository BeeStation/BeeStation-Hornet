/datum/starter_ship_template/inquisitor
	faction_flags = FACTION_INDEPENDANT | FACTION_NANOTRASEN
	template_cost = 450
	job_roles = list(
		/datum/job/captain = 1,
		/datum/job/security_officer = 2,
		/datum/job/station_engineer = 3,
		/datum/job/assistant = INFINITY,
	)
	spawned_template = /datum/map_template/shuttle/ship/inquisitor
	description = ""

/datum/starter_ship_template/inquisitor/syndicate
	faction_flags = FACTION_SYNDICATE
	template_cost = 450
	job_roles = list(
		/datum/job/captain/syndicate = 1,
		/datum/job/security_officer/syndicate = 2,
		/datum/job/station_engineer/syndicate = 3,
		/datum/job/assistant/syndicate = INFINITY,
	)
	spawned_template = /datum/map_template/shuttle/ship/inquisitor/syndie
	description = ""

/datum/map_template/shuttle/ship/inquisitor
	name = "NTC Inquisitor"
	suffix = "inquisitor"

/datum/map_template/shuttle/ship/inquisitor/syndie
	name = "SYN Inquisitor"
	suffix = "inquisitor_syndie"

/area/shuttle/inquisitor
	requires_power = TRUE

/area/shuttle/inquisitor/engineering
	name = "inquisitor Engineering Bay"
	icon_state = "yellow"

/area/shuttle/inquisitor/weapons
	name = "inquisitor Weapons Bay"
	icon_state = "armory"

/area/shuttle/inquisitor/lounge
	name = "inquisitor Lounge"
	icon_state = "lounge"

/area/shuttle/inquisitor/dorms
	name = "inquisitor Dormatories"
	icon_state = "dorms"

/area/shuttle/inquisitor/bridge
	name = "inquisitor Bridge"
	icon_state = "bridge"
