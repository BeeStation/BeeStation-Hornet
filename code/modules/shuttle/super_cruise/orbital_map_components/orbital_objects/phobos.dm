//Centcom Z-Level.
//Syndicate infiltrator level.
/datum/orbital_object/z_linked/phobos
	name = "Phobos"
	mass = 500
	radius = 130

/datum/orbital_object/z_linked/phobos/post_map_setup()
	//Orbit around the systems sun
	var/datum/orbital_map/linked_map = SSorbits.orbital_maps[orbital_map_index]
	set_orbitting_around_body(linked_map.center, 3800)
