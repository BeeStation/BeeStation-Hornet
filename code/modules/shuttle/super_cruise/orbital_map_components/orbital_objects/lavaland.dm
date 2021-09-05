/datum/orbital_object/z_linked/lavaland
	name = "Lavaland"
	mass = 10000
	radius = 200
	forced_docking = TRUE
	static_object = TRUE
	random_docking = TRUE

/datum/orbital_object/z_linked/lavaland/New()
	. = ..()
	SSorbits.orbital_map.center = src
