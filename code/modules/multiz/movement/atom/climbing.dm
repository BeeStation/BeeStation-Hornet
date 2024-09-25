/proc/turf_can_climb(turf/target)
	if(!isopenspace(target))
		return FALSE
	for(var/obj/structure/S in target)
		if(S.can_climb_through())
			return TRUE
	return FALSE

/// If you can climb WITHIN this structure, lattices for example. Used by z_transit (Move Upwards verb)
/obj/structure/proc/can_climb_through()
	return FALSE

/obj/structure/lattice/can_climb_through()
	return TRUE

/obj/structure/lattice/catwalk/can_climb_through()
	return FALSE
