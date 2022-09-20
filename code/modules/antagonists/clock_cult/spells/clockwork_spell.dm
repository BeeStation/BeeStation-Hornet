/datum/action/innate/clockcult/insight

/datum/action/innate/clockcult/insight/Grant(mob/M)
	. = ..()
	button.screen_loc = DEFAULT_BLOODSPELLS
	button.moved = DEFAULT_BLOODSPELLS
	button.ordered = FALSE
