/datum/smite/ghostize
	name = "Ghostize"

/datum/smite/ghostize/effect(client/user, mob/living/target)
	. = ..()
	if(target.key)
		target.ghostize(FALSE,SENTIENCE_FORCE)
	else
		target.set_playable()

