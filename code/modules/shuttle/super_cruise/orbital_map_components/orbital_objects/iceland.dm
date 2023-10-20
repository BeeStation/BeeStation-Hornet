/datum/orbital_object/z_linked/iceland
	name = "Iceland"
	mass = 9000
	radius = 190
	forced_docking = TRUE
	static_object = TRUE
	random_docking = FALSE
	render_mode = RENDER_MODE_PLANET
	priority = 90

/datum/orbital_object/z_linked/iceland/New()
	. = ..()
	var/datum/orbital_map/linked_map = SSorbits.orbital_maps[orbital_map_index]
	linked_map.center = src
