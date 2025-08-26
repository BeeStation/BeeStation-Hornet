/// Admin heals the target
/datum/smite/aheal
	name = "Aheal"

/datum/smite/aheal/effect(client/user, mob/living/target)
	. = ..()
	target.revive(ADMIN_HEAL_ALL)
