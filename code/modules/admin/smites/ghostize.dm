/datum/smite/ghostize
	name = "Offer to Ghosts"

/datum/smite/ghostize/effect(client/user, mob/living/target)
	. = ..()
	target.ghostize(FALSE, SENTIENCE_FORCE)
