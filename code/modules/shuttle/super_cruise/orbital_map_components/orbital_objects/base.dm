/datum/orbital_object/z_linked/base
	name = "Unknown Base"
	mass = 0
	radius = 60
	priority = 400
	//The station maintains its orbit around lavaland by adjustment thrusters.
	maintain_orbit = TRUE
	//Sure, why not?
	can_dock_anywhere = TRUE
	signal_range = 4000

#ifdef LOWMEMORYMODE
	var/datum/orbital_map/linked_map = SSorbits.orbital_maps[orbital_map_index]
	linked_map.center = src
#endif

/datum/orbital_object/z_linked/base/post_map_setup()
	//Orbit around the system center
	var/datum/orbital_map/linked_map = SSorbits.orbital_maps[orbital_map_index]
	set_orbitting_around_body(linked_map.center, 7000)

/datum/orbital_object/z_linked/base/syndicate
	name = "Syndicate Hideout"

/datum/orbital_object/z_linked/base/nanotrasen
	name = "Nanotrasen Forward Operating Base"
