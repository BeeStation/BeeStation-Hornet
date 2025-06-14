/// Admin heals the target
/datum/smite/aheal
	name = "Aheal"

/datum/smite/aheal/effect(client/user, mob/living/target)
	. = ..()
	target.revive(full_heal = 1, admin_revive = 1)
