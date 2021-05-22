/datum/orbital_object/z_linked/lavaland
	name = "Lavaland"
	mass = 50
	radius = 1
	linked_level_trait = ZTRAIT_MINING

/datum/orbital_object/z_linked/lavaland/New()
	. = ..()
	//Force set orbitting body of the station to be around us, we are special.
	for(var/datum/orbital_object/z_linked/station/station in SSorbits.orbital_map.bodies)
		set_orbitting_around_body(station, 25, TRUE)
		break
