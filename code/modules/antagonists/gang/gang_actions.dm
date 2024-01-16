/datum/action/innate/gang
	icon_icon = 'icons/mob/actions/actions_cult.dmi'
	background_icon_state = "bg_demon"
	buttontooltipstyle = "cult"
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/innate/gang/invitation
	name = "Invite to Gang"
	desc = "Invite someone nearby to join your criminal organization. You have a maximum limit on members, choose wisely."
	button_icon_state = "cult_comms"

/datum/action/innate/gang/invitation/Activate()
	var/mob/living/carbon/targets = list()
	for(var/mob/living/carbon/M in view_or_range(8, owner, "view"))
		if(!M.mind || M.stat == DEAD || HAS_TRAIT(M, TRAIT_MINDSHIELD) || M == user) //Needs to have a mind, a client, be not dead, have a mindshield and not be ourselves.
			continue
		targets += M
	var/mob/living/carbon/selection = input(owner,"Who to invite?", "Gang Invitation", null) as null|anything in targets
	selection.death()
