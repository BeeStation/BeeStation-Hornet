/**
 * Ghostizes the holoparasite, sending it to nullspace.
 */
/mob/living/simple_animal/hostile/holoparasite/death(gibbed)
	. = ..()
	tracking_beacon.toggle_visibility(FALSE)
	tracking_beacon.remove_from_huds()
	SSblackbox.record_feedback("amount", "holoparasites_killed", 1)
	ghostize(can_reenter_corpse = FALSE)
	nullspace()

/**
 * Prevents holoparasites from being wabbajacked - instead, it will forward a random amount of toxin + clone damage to the summoner.
 */
/mob/living/simple_animal/hostile/holoparasite/proc/on_pre_wabbajacked()
	SIGNAL_HANDLER
	SSblackbox.record_feedback("amount", "holoparasites_wabbajacked", 1)
	visible_message("<span class='danger bold'>[color_name] quickly demanifests in a nauseating array of colors!</span>")
	to_chat(summoner.current, "<span class='danger bold'>You feel oddly nauseous as [color_name] suddenly recalls!</span>")
	summoner.current.adjustToxLoss(rand(10, 20), forced = TRUE)
	summoner.current.adjustCloneLoss(rand(5, 15))
	recall(forced = TRUE)
	return STOP_WABBAJACK
