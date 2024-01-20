/datum/xenoartifact_trait/misc
	flags = null
	register_targets = FALSE
	weight = 0
	conductivity = 0
	contribute_calibration = FALSE
	can_pearl = FALSE

/datum/xenoartifact_trait/misc/objective
	blacklist_traits = list(/datum/xenoartifact_trait/minor/delicate)

/datum/xenoartifact_trait/misc/objective/New(atom/_parent)
	. = ..()
	var/atom/A = parent.parent
	A.AddComponent(/datum/component/gps, "[scramble_message_replace_chars("#########", 100)]", TRUE)

/datum/xenoartifact_trait/misc/objective/Destroy(force, ...)
	var/atom/A = parent.parent
	var/datum/component/gps/G = A.GetComponent(/datum/component/gps)
	qdel(G)
	return ..()
