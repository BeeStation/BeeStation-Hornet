/datum/orbital_object/z_linked/beacon
	name = "Unidentified Signal"
	mass = 0
	radius = 30
	can_dock_anywhere = TRUE

/datum/orbital_object/z_linked/beacon/New()
	. = ..()
	name = "[initial(name)] #[rand(1, 9)][SSorbits.orbital_map.bodies.len][rand(1, 9)]"

/datum/orbital_object/z_linked/beacon/post_map_setup()
	//Orbit around the systems sun
	set_orbitting_around_body(SSorbits.orbital_map.center, 4000 + 250 * linked_z_level.z_value)

/datum/orbital_object/z_linked/beacon/weak
	name = "Weak Signal"
