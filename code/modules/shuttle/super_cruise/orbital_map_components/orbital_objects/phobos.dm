//Centcom Z-Level.
//Syndicate infiltrator level.
/datum/orbital_object/z_linked/phobos
	name = "Phobos"
	mass = 500
	radius = 130

/datum/orbital_object/z_linked/phobos/post_map_setup()
	//Orbit around the systems sun
	set_orbitting_around_body(SSorbits.orbital_map.center, 3800)
