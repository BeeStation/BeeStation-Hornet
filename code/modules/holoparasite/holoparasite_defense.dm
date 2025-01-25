/**
 * Ghostizes the holoparasite, sending it to nullspace.
 */
/mob/living/simple_animal/hostile/holoparasite/death(gibbed)
	. = ..()
	tracking_beacon.toggle_visibility(FALSE)
	tracking_beacon.remove_from_huds()
	SSblackbox.record_feedback("amount", "holoparasites_killed", 1)
	nullspace_if_dead(forced = TRUE)

/**
 * Prevents holoparasites from being wabbajacked - instead, it will forward a random amount of toxin + clone damage to the summoner.
 */
/mob/living/simple_animal/hostile/holoparasite/proc/on_pre_wabbajacked()
	SIGNAL_HANDLER
	SSblackbox.record_feedback("amount", "holoparasites_wabbajacked", 1)
	visible_message(span_dangerbold("[color_name] quickly demanifests in a nauseating array of colors!"))
	to_chat(summoner.current, span_dangerbold("You feel oddly nauseous as [color_name] suddenly recalls!"))
	summoner.current.adjustToxLoss(rand(10, 20), updating_health = FALSE, forced = TRUE)
	summoner.current.adjustCloneLoss(rand(5, 15), updating_health = TRUE)
	recall(forced = TRUE)
	return STOP_WABBAJACK
