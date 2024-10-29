/*
	Major
	These traits cause the xenoartifact to do a specific action

	* weight - All majors should have a weight that is a multiple of 3
	* conductivity - If a major should have conductivity, it will be a multiple of 3 too
*/
/datum/xenoartifact_trait/major
	priority = TRAIT_PRIORITY_MAJOR
	weight = 3
	conductivity = 0

/datum/xenoartifact_trait/major/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	for(var/mob/living/M in view(XENOA_TRAIT_BALLOON_HINT_DIST, get_turf(component_parent.parent)))
		do_hint(M)
