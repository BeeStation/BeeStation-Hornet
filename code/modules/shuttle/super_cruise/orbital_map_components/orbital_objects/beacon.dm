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

//Ruin z-levels
/datum/orbital_object/z_linked/beacon/ruin
	linked_z_level = 0

/datum/orbital_object/z_linked/beacon/ruin/proc/assign_z_level()
	var/datum/space_level/assigned_space_level = SSzclear.get_free_z_level()
	linked_z_level = assigned_space_level
	assigned_space_level.orbital_body = src
	generate_space_ruin(world.maxx / 2, world.maxy / 2, assigned_space_level.z_value, 100, 100)

/datum/orbital_object/z_linked/beacon/ruin/post_map_setup()
	//Orbit around the systems sun
	set_orbitting_around_body(SSorbits.orbital_map.center, 4000 + 250 * rand(4, 20))
