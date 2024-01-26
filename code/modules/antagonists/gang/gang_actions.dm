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
	for(var/mob/living/carbon/M in get_hearers_in_view(6, owner))
		if(!M.mind || M.stat == DEAD || M == owner) //Needs to have a mind, a client, be not dead and isn't us. Client not included for testing purposes
			continue
		targets += M
	if(!length(targets))
		return

	var/offer = tgui_input_text(owner, "Please choose what to say for your invitation.", "Gang Invitation", "")
	if(!offer || !IsAvailable())
		return

	if(CHAT_FILTER_CHECK(offer))
		to_chat(usr, "<span class='warning'>You cannot send a message that contains a word prohibited in IC chat!</span>")
		return

	var/mob/living/carbon/selection = input(owner,"Who to invite?", "Gang Invitation", null) as null|anything in targets

	if(!IsAvailable())
		return

	if(!(selection in get_hearers_in_view(8, owner)))
		return

	if(selection.mind.assigned_role in GLOB.security_positions)
		to_chat(owner, "<span class='warning'>[selection] is unlikely to take you up on the offer, coercion and bribery may still work.</span>")
		return

	owner.say(html_decode(offer))

	if(alert(owner, "[owner] is inviting you to join the [gang.name] gang. Do you accept?", "Gang Invitation", "Yes", "No") == "Yes")
		to_chat(owner, "<span class='warning'>[selection] takes you up on the invitation!</span>")
		selection.mind.add_antag_datum(/datum/antagonist/gang, gang)
	else
		to_chat(owner, "<span class='warning'>[selection] seems uninterested.</span>")
