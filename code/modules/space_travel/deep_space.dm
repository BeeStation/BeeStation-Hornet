/turf/open/space/deep_space
	density = FALSE
	var/direction = 0

/turf/open/space/deep_space/CanBuildHere()
	return FALSE

/turf/open/space/deep_space/Bumped(atom/movable/AM)
	to_chat(world, "ENTERED DEEP SPACE TURF")

/turf/open/space/deep_space/Entered(atom/movable/AM, atom/old_loc, list/atom/old_locs)
	. = ..()

	GLOB.spaceTravelManager.atom_entered_deep_space(AM, direction)

