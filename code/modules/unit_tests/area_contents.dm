/// Verifies that an area's perception of their "turfs" is correct, and no other area overlaps with them
/// Quite slow, but needed
/datum/unit_test/area_contents
	priority = TEST_LONGER

/datum/unit_test/area_contents/Run()
	/// assoc list of turfs -> areas
	var/list/turf_to_area = list()
	// First, we check that there are no entries in more then one area
	// That or duplicate entries
	for(var/area/space in GLOB.areas)
		for(var/turf/position as anything in space.get_contained_turfs())
			if(!isturf(position))
				Fail("Found a [position.type] in [space.type]'s turf listing")
			var/area/existing = turf_to_area[position]
			if(existing == space)
				Fail("Found a duplicate turf [position.type] inside [space.type]'s turf listing")
			else if(existing)
				Fail("Found a shared turf [position.type] between [space.type] and [existing.type]'s turf listings")

			var/area/dream_spot = position.loc
			if(dream_spot != space)
				Fail("Found a turf [position.type] which is IN [dream_spot.type], but is registered as being in [space.type]")

			turf_to_area[position] = space

	for(var/turf/position in ALL_TURFS())
		if(!turf_to_area[position])
			Fail("Found a turf [position.type] inside [position.loc.type] that is NOT stored in any area's turf listing")

