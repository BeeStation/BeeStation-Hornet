/datum/antagonist/siege
	name = "Besieger"
	antagpanel_category = "Besieger"
	job_rank = ROLE_BESIEGER
	var/special_role = ROLE_BESIEGER
	antag_moodlet = /datum/mood_event/focused
	var/datum/team/brother_team/siege/team

/datum/antagonist/siege/create_team(datum/team/brother_team/siege/new_team)
	if(!new_team)
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	team = new_team

/datum/antagonist/siege/get_team()
	return team

/datum/antagonist/siege/on_gain()
	SSticker.mode.besiegers += owner
	objectives += team.objectives
	for(var/datum/objective/O in team.objectives)
		log_objective(owner, O.explanation_text)
	owner.special_role = special_role
	finalize_brother()
	return ..()

/datum/antagonist/siege/on_removal()
	SSticker.mode.besiegers -= owner
	if(owner.current)
		to_chat(owner.current,"<span class='userdanger'>You are no longer the besieger!</span>")
	owner.special_role = null
	return ..()

/datum/antagonist/siege/antag_panel_data()
	return "Conspirators : [get_besieger_names()]"

/datum/antagonist/siege/proc/get_besieger_names()
	var/list/besiegers = team.members - owner
	var/besieger = ""
	for(var/i = 1 to besiegers.len)
		var/datum/mind/M = besiegers[i]
		besieger += M.name
		if(i == besiegers.len - 1)
			besieger += " and "
		else if(i != besiegers.len)
			besieger += ", "
	return besieger

/datum/antagonist/siege/proc/give_meeting_area()
	if(!owner.current || !team || !team.meeting_area)
		return
	to_chat(owner.current, "<B>Your designated meeting area:</B> [team.meeting_area]")
	antag_memory += "<b>Meeting Area</b>: [team.meeting_area]<br>"

/datum/antagonist/siege/greet()
	to_chat(owner.current, "<span class='alertsyndie'>You are a Syndicate Saboteur.</span>")
	to_chat(owner.current, "You have been activated. Sow chaos and degrade the station's defensive capabilities in preparation for invasion. You and your team are outfitted with communication implants allowing for direct, encrypted communication. You are not expected to survive. Glory to the Syndicate.")
	owner.announce_objectives()
	to_chat(owner.current, "<B>Your designated meeting area:</B> [team.meeting_area]")
	antag_memory += "<b>Meeting Area</b>: [team.meeting_area]<br>"
	owner.current.client?.tgui_panel?.give_antagonist_popup("Besieger",
		"You have been activated. Sow chaos and degrade the station's defensive capabilities in preparation for invasion. You and your team are outfitted with communication implants allowing for direct, encrypted communication. You are not expected to survive. Glory to the Syndicate.")
	return ..()

/datum/antagonist/siege/proc/finalize_brother()
	var/obj/item/implant/bloodbrother/I = new /obj/item/implant/bloodbrother()
	I.implant(owner.current, null, TRUE, TRUE)
	I.implant_colour = "#ff0000"
	for(var/datum/mind/M in team.members) // Link the implants of all team members
		var/obj/item/implant/bloodbrother/T = locate() in M.current.implants
		I.link_implant(T)
	SSticker.mode.update_brother_icons_added(owner)
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/tatoralert.ogg', 100, FALSE, pressure_affected = FALSE, use_reverb = FALSE)

/datum/team/brother_team/siege
	name = "besiegers"
	member_name = "besieger"
	team_id = "besieger"
	objectives = list(new/datum/objective/martyr)

/datum/team/brother_team/siege/roundend_report()
	var/list/parts = list()
	parts += "<span class='header'>The Besieger Saboteurs [name] were:</span>"
	for(var/datum/mind/M in members)
		parts += printplayer(M)
	return "<div class='panel redborder'>[parts.Join("<br>")]</div>"

/datum/team/brother_team/siege/update_name()
	name = "besiegers"

/datum/team/brother_team/siege/admin_add_member(mob/user)
	var/list/candidates = list()
	for(var/mob/M in GLOB.player_list)
		if(M.mind?.special_role)
			continue
		candidates += M.mind
	var/datum/mind/value = input("Select new member:", "New team member", null) as null|anything in sortNames(candidates)
	if (!value)
		return
