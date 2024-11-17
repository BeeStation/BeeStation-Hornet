/datum/smite/ghostize
	name = "Offer to Ghosts"

/datum/smite/ghostize/effect(client/user, mob/living/target)
	. = ..()
	if(target.key)
		target.ghostize(FALSE)
	target.AddComponent(/datum/component/ghost_spawner, BAN_ROLE_ALL_GHOST, TRUE, flavour_message="You have inhabited the body of [target.real_name].")

