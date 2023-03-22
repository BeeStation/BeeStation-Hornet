/datum/starter_ship_template/stringray
	template_cost = 800
	job_roles = list(
		/datum/job/captain = 1,
		/datum/job/medical_doctor = 1,
		/datum/job/security_officer = 3,
		/datum/job/station_engineer = 2,
		/datum/job/assistant = INFINITY,
	)
	spawned_template = /datum/map_template/shuttle/ship/stringray

/datum/map_template/shuttle/ship/stringray
	name = "Stingray"
	suffix = "stingray"

/area/shuttle/stingray
	requires_power = TRUE

/area/shuttle/stingray/engineering
	name = "Stringray Engineering"
	icon_state = "yellow"

/area/shuttle/stingray/central
	name = "Stringray Central Hallway"
	icon_state = "purple"

/area/shuttle/stingray/armoury
	name = "Stringray Armoury"
	icon_state = "armory"

/area/shuttle/stingray/bridge
	name = "Stringray Bridge"
	icon_state = "bridge"

/area/shuttle/stingray/security
	name = "Stringray Security"
	icon_state = "security"

/area/shuttle/stingray/cargo
	name = "Stringray Cargo"
	icon_state = "cargo_bay"
