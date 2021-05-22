/datum/orbital_object/z_linked
	name = "Unidentified Beacon"
	var/linked_level_trait = -1
	var/list/linked_z_levels = list()

/datum/orbital_object/z_linked/New()
	if(linked_level_trait != -1 && !length(linked_z_levels))
		var/list/levels = SSmapping.levels_by_trait(linked_level_trait)
		linked_z_levels = levels

	. = ..()

/datum/orbital_object/z_linked/proc/link_to_z(new_z)
	linked_z_levels = SSmapping.get_level(new_z)
	//Orbit around the systems sun
	set_orbitting_around_body(SSorbits.orbital_map.star, 50 * new_z)

/datum/orbital_object/z_linked/Destroy()
	. = ..()
	message_admins("ORBITAL BODY [name] WAS DESTROYED.")
	log_game("Orbital body [name] was destroyed.")
	//Holy shit this is bad.
	for(var/mob/living/L in GLOB.mob_living_list)
		if(L.z in linked_z_levels)
			qdel(L)
	//Prevent access to the z-level.
	//Announcement
	priority_announce("The orbital body [name] has been destroyed. Transit to this location is no longer possible.", "Nanotrasen Orbital Body Division")

/datum/orbital_object/z_linked/collision(datum/orbital_object/other)
	//Send shuttle to z-level for docking.
	if(istype(other, /datum/orbital_object/shuttle))
		//send them to the place
		var/datum/orbital_object/shuttle/shuttle = other
		shuttle.commence_docking(linked_z_levels)
