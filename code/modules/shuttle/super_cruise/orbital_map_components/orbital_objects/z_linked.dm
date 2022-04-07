/datum/orbital_object/z_linked
	name = "Unidentified Beacon"
	collision_type = COLLISION_Z_LINKED
	collision_flags = COLLISION_SHUTTLES
	//The space level(s) we are linked to
	var/list/datum/space_level/linked_z_level
	//If docking is forced upon collision
	//If you hit a planet, you are going to the planet whether you like it or not.
	var/forced_docking = FALSE
	//Can you dock on this Z-level anywhere?
	var/can_dock_anywhere = FALSE
	//If we can't dock anywhere, will we just crash on the Z-level at a random position?
	var/random_docking = FALSE
	//Inherit the name of z-level?
	var/inherit_name = FALSE
	//are we generating
	var/is_generating = FALSE

/datum/orbital_object/z_linked/proc/link_to_z(datum/space_level/level)
	LAZYADD(linked_z_level, level)
	if(inherit_name)
		name = level.name

/datum/orbital_object/z_linked/explode()
	message_admins("ORBITAL BODY [name] WAS DESTROYED.")
	log_game("Orbital body [name] was destroyed.")
	//Holy shit this is bad.
	for(var/mob/living/L in GLOB.mob_living_list)
		for(var/datum/space_level/level as() in linked_z_level)
			if(L.z == level.z_value)
				qdel(L)
				break
	//Prevent access to the z-level.
	//Announcement
	priority_announce("The orbital body [name] has been destroyed. Transit to this location is no longer possible.", "Nanotrasen Orbital Body Division")
	qdel(src)

/datum/orbital_object/z_linked/proc/z_in_contents(z_value)
	if(!LAZYLEN(linked_z_level))
		return FALSE
	for(var/datum/space_level/level as() in linked_z_level)
		if(level.z_value == z_value)
			return TRUE
	return FALSE
