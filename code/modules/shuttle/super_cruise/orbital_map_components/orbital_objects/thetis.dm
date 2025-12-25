//Centcom Z-Level.
//Syndicate infiltrator level.
/datum/orbital_object/z_linked/thetis
	name = "Thetis"
	mass = 50000
	radius = 500
	render_mode = RENDER_MODE_PLANET
	priority = 20

/datum/orbital_object/z_linked/thetis/New()
	. = ..()

	SSorbits.thetis_instance = src

/datum/orbital_object/z_linked/thetis/post_map_setup()
	//Orbit around the systems sun
	var/datum/orbital_map/linked_map = SSorbits.orbital_maps[orbital_map_index]
	set_orbitting_around_body(linked_map.center, 6000)
