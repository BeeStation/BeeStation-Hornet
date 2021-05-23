/datum/orbital_object/z_linked/lavaland
	name = "Lavaland"
	mass = 50
	radius = 20
	forced_docking = TRUE

/datum/orbital_object/z_linked/lavaland/post_map_setup()
	//Orbit around the systems sun
	set_orbitting_around_body(SSorbits.orbital_map.star, 2000 + 250 * linked_z_level.z_value)
