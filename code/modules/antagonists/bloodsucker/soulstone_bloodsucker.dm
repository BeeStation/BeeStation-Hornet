// special soulstone for the malkavian clan
/obj/item/soulstone/bloodsucker
	theme = THEME_WIZARD
	required_role = /datum/antagonist/vassal //vassals can free their master

/obj/item/soulstone/bloodsucker/getCultGhost(mob/living/carbon/victim, mob/user)
	var/mob/dead/observer/chosen_ghost = victim.get_ghost(FALSE, TRUE)
	if(QDELETED(chosen_ghost?.client))
		victim.dust()
		return FALSE
	victim.unequip_everything()
	init_shade(victim, user, shade_controller = chosen_ghost)
	return TRUE
