/datum/smite/ghostize
	name = "Offer to Ghosts"

/datum/smite/ghostize/effect(client/user, mob/living/target)
	. = ..()
	if(target.key)
		target.ghostize(FALSE,SENTIENCE_FORCE)
	else
		target.set_playable()

