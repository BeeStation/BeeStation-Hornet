/datum/orbital_object/z_linked/triea
	name = "Triea"
	mass = 1000
	radius = 50
	render_mode = RENDER_MODE_PLANET
	priority = 20

/datum/orbital_object/z_linked/triea/New()
	. = ..()

	SSorbits.triea_instance = src

/datum/orbital_object/z_linked/triea/post_map_setup()
	//Orbit around the systems sun
	var/datum/orbital_map/linked_map = SSorbits.orbital_maps[orbital_map_index]
	set_orbitting_around_body(linked_map.center, 15000)
