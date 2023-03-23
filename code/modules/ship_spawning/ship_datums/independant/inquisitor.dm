/datum/starter_ship_template/inquisitor
	template_cost = 450
	job_roles = list(
		/datum/job/captain = 1,
		/datum/job/security_officer = 2,
		/datum/job/station_engineer = 3,
		/datum/job/assistant = INFINITY,
	)
	spawned_template = /datum/map_template/shuttle/ship/inquisitor
	description = ""

/datum/map_template/shuttle/ship/inquisitor
	name = "Inquisitor"
	suffix = "inquisitor"

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
