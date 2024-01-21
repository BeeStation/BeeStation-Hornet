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
	var/datum/antagonist/gang/boss/boss = owner.mind.has_antag_datum(/datum/antagonist/gang/boss)
	if(!boss)
		return
	var/datum/team/gang/gang = boss.gang
	if(!gang)
		return
	if(gang.members.len >= gang.max_members)
		to_chat(owner, "<span class='warning'>We can't support more than [gang.max_members] members, bribery and coercion can still make people cooperative.</span>")
		return
	var/mob/living/carbon/targets = list()
	for(var/mob/living/carbon/M in view_or_range(8, owner, "view"))
		if(!M.mind || M.stat == DEAD || M == owner) //Needs to have a mind, a client, be not dead and isn't us.
			continue
		targets += M
	var/mob/living/carbon/selection = input(owner,"Who to invite?", "Gang Invitation", null) as null|anything in targets
	if(selection.mind.assigned_role in GLOB.security_positions)
		to_chat(owner, "<span class='warning'>[selection] is unlikely to take you up on the offer, coercion and bribery may still work.</span>")
	if(selection.death())
		to_chat(owner, "<span class='warning'>[selection] takes you up on the invitation!</span>")
	else
		to_chat(owner, "<span class='warning'>[selection] seems uninterested.</span>")
