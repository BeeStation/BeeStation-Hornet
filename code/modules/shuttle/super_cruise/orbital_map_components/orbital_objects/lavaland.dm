/datum/orbital_object/z_linked/lavaland
	name = "Cinis"
	mass = 10000
	radius = 200
	forced_docking = TRUE
	random_docking = TRUE
	render_mode = RENDER_MODE_PLANET
	priority = 90

/datum/orbital_object/z_linked/lavaland/New()
	. = ..()

	SSorbits.cinis_instance = src

/datum/orbital_object/z_linked/lavaland/post_map_setup()
	//Orbit around the systems sun
	var/datum/orbital_map/linked_map = SSorbits.orbital_maps[orbital_map_index]
	set_orbitting_around_body(linked_map.center, 2000)
