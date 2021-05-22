/datum/orbital_object/z_linked/station
	name = "Space Station 13"
	mass = 0
	radius = 1
	linked_level_trait = ZTRAIT_STATION
	//The station maintains its orbit around lavaland by adjustment thrusters.
	maintain_orbit = TRUE

/datum/orbital_object/z_linked/station/Destroy()
	. = ..()
	SSticker.force_ending = TRUE
