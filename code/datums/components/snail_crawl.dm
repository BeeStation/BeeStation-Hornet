/datum/component/snailcrawl
	var/mob/living/carbon/snail

/datum/component/snailcrawl/Initialize()
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(lubricate))
	snail = parent

/datum/component/snailcrawl/proc/lubricate()
	SIGNAL_HANDLER

	if(snail.resting && !snail.buckled) //s l i d e
		var/turf/open/OT = get_turf(snail)
		if(isopenturf(OT))
			OT.MakeSlippery(TURF_WET_LUBE, 20)
		snail.add_movespeed_modifier(/datum/movespeed_modifier/snail_crawl)
	else
		snail.remove_movespeed_modifier(/datum/movespeed_modifier/snail_crawl)

/datum/component/snailcrawl/_RemoveFromParent()
	snail.remove_movespeed_modifier(/datum/movespeed_modifier/snail_crawl)
	return ..()
