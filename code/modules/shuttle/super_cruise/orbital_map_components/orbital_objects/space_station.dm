/datum/orbital_object/z_linked/station
	name = "Space Station 13"
	mass = 0
	radius = 5
	//The station maintains its orbit around lavaland by adjustment thrusters.
	maintain_orbit = TRUE

/datum/orbital_object/z_linked/station/Destroy()
	. = ..()
	SSticker.force_ending = TRUE

/datum/orbital_object/z_linked/station/post_map_setup()
	//Orbit around the systems sun
	var/datum/orbital_object/z_linked/lavaland/lavaland = locate() in SSorbits.orbital_map.bodies
	set_orbitting_around_body(lavaland, 50)
