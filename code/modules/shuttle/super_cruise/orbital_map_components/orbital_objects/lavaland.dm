/datum/orbital_object/z_linked/lavaland
	name = "Lavaland"
	mass = 10000
	radius = 200
	forced_docking = TRUE
	static_object = TRUE
	random_docking = TRUE
	render_mode = RENDER_MODE_PLANET
	priority = 90

/datum/orbital_object/z_linked/lavaland/New()
	. = ..()
	var/datum/orbital_map/linked_map = SSorbits.orbital_maps[orbital_map_index]
	linked_map.center = src

/datum/orbital_object/z_linked/lavaland/shattered
	name = "Lavaland Remnants"
	forced_docking = FALSE
	random_docking = FALSE
