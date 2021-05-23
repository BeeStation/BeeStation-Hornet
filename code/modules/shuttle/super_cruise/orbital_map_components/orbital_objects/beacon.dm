/datum/orbital_object/z_linked/beacon
	name = "Beacon"
	mass = 0
	radius = 10

/datum/orbital_object/z_linked/beacon/post_map_setup()
	//Orbit around the systems sun
	set_orbitting_around_body(SSorbits.orbital_map.star, 2000 + 250 * linked_z_level.z_value)
