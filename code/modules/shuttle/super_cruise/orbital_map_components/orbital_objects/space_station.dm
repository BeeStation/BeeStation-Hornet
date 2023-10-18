/datum/orbital_object/z_linked/station
	name = "Space Station 13"
	mass = 0
	radius = 30
	priority = 50
	//The station maintains its orbit around lavaland by adjustment thrusters.
	maintain_orbit = TRUE
	//Sure, why not?
	can_dock_anywhere = TRUE

/datum/orbital_object/z_linked/station/New()
	. = ..()
	SSorbits.station_instance = src
	//SSorbits initialises after mapping
	if (SSmapping.config.planetary_station)
		render_mode = RENDER_MODE_PLANET
		radius = SSmapping.config.planet_radius
		mass = SSmapping.config.planet_mass
		if (SSmapping.config.planet_name)
			name = "[SSmapping.config.planet_name] (Outpost 13)"

#ifdef LOWMEMORYMODE
	var/datum/orbital_map/linked_map = SSorbits.orbital_maps[orbital_map_index]
	linked_map.center = src
#endif

/datum/orbital_object/z_linked/station/explode()
	. = ..()
	SSticker.force_ending = TRUE

/datum/orbital_object/z_linked/station/post_map_setup()
	//Orbit around the system center
	var/datum/orbital_map/linked_map = SSorbits.orbital_maps[orbital_map_index]
	set_orbitting_around_body(linked_map.center, 2500)
