/datum/orbital_object/star
	name = "Auri Geminae"
	mass = 100000
	radius = 1000
	static_object = TRUE
	collision_flags = ALL
	priority = 100

/datum/orbital_object/star/New()
	. = ..()
	var/datum/orbital_map/linked_map = SSorbits.orbital_maps[orbital_map_index]
	linked_map.center = src
