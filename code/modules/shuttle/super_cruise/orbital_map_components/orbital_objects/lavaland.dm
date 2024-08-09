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
	if(!linked_map.center) // only if there's no centre of the universe
		linked_map.center = src

/datum/orbital_object/z_linked/lavaland/post_map_setup()
	// Lavaland planet will orbit the sun when they're not the centre
	var/datum/orbital_map/linked_map = SSorbits.orbital_maps[orbital_map_index]
	set_orbitting_around_body(linked_map.center, 3000)
