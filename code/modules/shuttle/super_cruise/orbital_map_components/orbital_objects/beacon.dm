/datum/orbital_object/z_linked/beacon
	name = "Unidentified Signal"
	mass = 0
	radius = 60
	can_dock_anywhere = TRUE
	render_mode = RENDER_MODE_BEACON
	signal_range = 2000
	//The attached event
	var/datum/ruin_event/ruin_event

/datum/orbital_object/z_linked/beacon/New()
	. = ..()
	var/datum/orbital_map/linked_map = SSorbits.orbital_maps[orbital_map_index]
	ruin_event = SSorbits.get_event()
	if(ruin_event?.warning_message)
		name = "[initial(name)] #[rand(1, 9)][linked_map.object_count][rand(1, 9)] ([ruin_event.warning_message])"
	else
		name = "[initial(name)] #[rand(1, 9)][linked_map.object_count][rand(1, 9)]"
	//Link the ruin event to ourselves
	ruin_event?.linked_z = src

/datum/orbital_object/z_linked/beacon/post_map_setup()
	//Orbit around the systems sun
	var/datum/orbital_map/linked_map = SSorbits.orbital_maps[orbital_map_index]
	set_orbitting_around_body(linked_map.center, 4000 + 250 * linked_z_level[1].z_value)

/datum/orbital_object/z_linked/beacon/weak
	name = "Weak Signal"
	signal_range = 700

/datum/orbital_object/z_linked/beacon/proc/assign_z_level(quick_generation = FALSE)
	var/datum/space_level/assigned_space_level = SSzclear.get_free_z_level()
	linked_z_level = list(assigned_space_level)
	SSorbits.assoc_z_levels["[assigned_space_level.z_value]"] = src

//====================
// Asteroids
//====================

/datum/orbital_object/z_linked/beacon/asteroid
	name = "Asteroid"
	render_mode = RENDER_MODE_DEFAULT
	signal_range = 0

/datum/orbital_object/z_linked/beacon/asteroid/New()
	. = ..()
	radius = rand(40, 160)

/datum/orbital_object/z_linked/beacon/asteroid/assign_z_level(quick_generation = FALSE)
	var/datum/space_level/assigned_space_level = SSzclear.get_free_z_level()
	linked_z_level = list(assigned_space_level)
	SSorbits.assoc_z_levels["[assigned_space_level.z_value]"] = src
	generate_asteroids(world.maxx / 2, world.maxy / 2, assigned_space_level.z_value, quick_generation ? 40 : 70, rand(-0.5, 0), rand(40, 70))

/datum/orbital_object/z_linked/beacon/asteroid/post_map_setup()
	//Orbit around the systems central gravitional body
	//Pack closely together to make an asteriod belt.
	var/datum/orbital_map/linked_map = SSorbits.orbital_maps[orbital_map_index]
	set_orbitting_around_body(linked_map.center, 4000 + rand(-2000, 2000))

/datum/orbital_object/z_linked/beacon/asteroid/crilium
	name = "Asteroid (Crilium)"

/datum/orbital_object/z_linked/beacon/asteroid/crilium/assign_z_level(quick_generation = FALSE)
	var/datum/space_level/assigned_space_level = SSzclear.get_free_z_level()
	linked_z_level = list(assigned_space_level)
	SSorbits.assoc_z_levels["[assigned_space_level.z_value]"] = src
	generate_asteroids(world.maxx / 2, world.maxy / 2, assigned_space_level.z_value, quick_generation ? 40 : 70, rand(-0.3, 0), 25, /turf/closed/mineral/random/crilium)

/datum/orbital_object/z_linked/beacon/asteroid/crilium/post_map_setup()
	//Orbit around the systems central gravitional body
	//Pack closely together to make an asteriod belt.
	var/datum/orbital_map/linked_map = SSorbits.orbital_maps[orbital_map_index]
	set_orbitting_around_body(linked_map.center, 14000 + rand(-4000, 4000))

//====================
// Regular Ruin Z-levels
//====================

/datum/orbital_object/z_linked/beacon/spaceruin
	name = "Unknown Signal"

/datum/orbital_object/z_linked/beacon/spaceruin/New()
	. = ..()
	SSorbits.ruin_levels ++

/datum/orbital_object/z_linked/beacon/spaceruin/Destroy(force, ...)
	. = ..()
	SSorbits.ruin_levels --

/datum/orbital_object/z_linked/beacon/spaceruin/assign_z_level(quick_generation = FALSE)
	var/datum/space_level/assigned_space_level = SSzclear.get_free_z_level()
	linked_z_level = list(assigned_space_level)
	SSorbits.assoc_z_levels["[assigned_space_level.z_value]"] = src
	seedRuins(list(assigned_space_level.z_value), CONFIG_GET(number/space_budget), /area/space, SSmapping.space_ruins_templates)

/datum/orbital_object/z_linked/beacon/spaceruin/post_map_setup()
	//Orbit around the systems sun
	var/datum/orbital_map/linked_map = SSorbits.orbital_maps[orbital_map_index]
	set_orbitting_around_body(linked_map.center, 4000 + 250 * rand(4, 20))

//====================
//Stranded shuttles
//====================

/datum/orbital_object/z_linked/beacon/stranded_shuttle
	name = "Distress Beacon"
	static_object = TRUE
	signal_range = 0

/datum/orbital_object/z_linked/beacon/stranded_shuttle/assign_z_level(quick_generation = FALSE)
	var/datum/space_level/assigned_space_level = SSzclear.get_free_z_level()
	linked_z_level = list(assigned_space_level)
	SSorbits.assoc_z_levels["[assigned_space_level.z_value]"] = src
	generate_asteroids(world.maxx / 2, world.maxy / 2, assigned_space_level.z_value, quick_generation ? 40 : 120, -0.2, 40)

/datum/orbital_object/z_linked/beacon/stranded_shuttle/post_map_setup()
	return

//====================
//Interdiction
//====================

/datum/orbital_object/z_linked/beacon/interdiction
	name = "Distress Beacon"
	static_object = TRUE
	signal_range = 0

/datum/orbital_object/z_linked/beacon/interdiction/assign_z_level(quick_generation = FALSE)
	var/datum/space_level/assigned_space_level = SSzclear.get_free_z_level()
	linked_z_level = list(assigned_space_level)
	SSorbits.assoc_z_levels["[assigned_space_level.z_value]"] = src

/datum/orbital_object/z_linked/beacon/interdiction/post_map_setup()
	return
