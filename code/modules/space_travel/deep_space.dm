/turf/open/space/deep_space
	var/direction = 0

/turf/open/space/deep_space/deep_space_border
	density = TRUE

/turf/open/space/deep_space/CanBuildHere()
	return FALSE

/turf/open/space/deep_space/Bumped(atom/movable/AM)
	to_chat(world, "BUMPED DEEP SPACE TURF")

/turf/open/space/deep_space/Entered(atom/movable/AM, atom/old_loc, list/atom/old_locs)
	. = ..()

	GLOB.spaceTravelManager.atom_entered_deep_space(AM, direction)

/turf/open/space/deep_space/deep_space_border/Entered(atom/movable/AM, atom/old_loc, list/atom/old_locs)

	GLOB.spaceTravelManager.teleport_atom_to_safety(AM, direction)
