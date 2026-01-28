/datum/antagonist/brother
	name = "Brother"
	antagpanel_category = "Brother"
	banning_key = ROLE_BROTHER
	faction = FACTION_SYNDICATE
	required_living_playtime = 4
	ui_name = "AntagInfoBrother"
	hijack_speed = 0.5
	var/datum/team/brother_team/team
	antag_moodlet = /datum/mood_event/focused
	leave_behaviour = ANTAGONIST_LEAVE_KEEP

/datum/antagonist/brother/create_team(datum/team/brother_team/new_team)
	if(!new_team)
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	team = new_team

/datum/antagonist/brother/get_team()
	return team

/datum/antagonist/brother/on_gain()
	objectives += team.objectives
	for(var/datum/objective/O in team.objectives)
		log_objective(owner, O.explanation_text)
	owner.special_role = ROLE_BROTHER
	. = ..()
	// Little bit jank, finalize the brother after 1 second to give time for other antagonist
	// roles to spawn; so that our logic for allocated appropriate brothers is sound.
	addtimer(CALLBACK(src, PROC_REF(finalize_brother)), 1 SECONDS)

/datum/antagonist/brother/on_removal()
	if (!silent && owner.current)
		owner.current.visible_message("[span_deconversionmessage("[owner.current] looks like [owner.current.p_theyve()] just remembered [owner.current.p_their()] their true allegiance!")]", null, null, null, owner.current)
		to_chat(owner.current, span_userdanger("Your mind slips away from the clutches of your blood-brother. You are no longer required to follow their orders, but blackmail of your past crimes may make it difficult for you to find a way out of working with them..."))
		owner.current.log_message("has had their blood brother removed!", LOG_ATTACK, color="#960000")
	owner.special_role = null
	remove_antag_hud(ANTAG_HUD_BROTHER, owner.current)
	if (owner.current)
		for (var/obj/item/implant/bloodbrother/brother_implant in owner.current.implants)
			if (brother_implant.linked_team == team)
				qdel(brother_implant)
	return ..()

/datum/antagonist/brother/antag_panel_data()
	return "Conspirators : [get_brother_names()]"

/datum/antagonist/brother/ui_static_data(mob/user)
	var/list/data = list()
	data["antag_name"] = name
	data["objectives"] = get_objectives()
	data["brothers"] = get_brother_names()
	return data

/datum/antagonist/brother/proc/get_brother_names()
	var/list/brothers = team.members - owner
	var/brother_text = ""
	for(var/i = 1 to brothers.len)
		var/datum/mind/M = brothers[i]
		brother_text += M.name
		if(i == brothers.len - 1)
			brother_text += " and "
		else if(i != brothers.len)
			brother_text += ", "
	return brother_text

/datum/antagonist/brother/proc/give_meeting_area()
	if(!owner.current || !team || !team.meeting_area)
		return
	to_chat(owner.current, "<B>Your designated meeting area:</B> [team.meeting_area]")
	antag_memory += "<b>Meeting Area</b>: [team.meeting_area]<br>"

/datum/antagonist/brother/greet()
	var/brother_text = get_brother_names()
	if (brother_text)
		to_chat(owner.current, span_alertsyndie("You are the Blood Brother of [brother_text]."))
	else
		to_chat(owner.current, span_alertsyndie("You are the Blood Brother."))
	to_chat(owner.current, "The Syndicate only accepts those that have proven themselves. Prove yourself and prove your [team.member_name]s by completing your objectives together! You and your team are outfitted with communication implants allowing for direct, encrypted communication.")
	owner.announce_objectives()
	give_meeting_area()
	owner.current.client?.tgui_panel?.give_antagonist_popup("Blood Brother",
		"The Syndicate only accepts those that have proven themselves. Prove yourself and prove your [team.member_name]s by completing your objectives together!")
	for (var/datum/mind/brother in team.members)
		if (brother == owner)
			continue
		to_chat(brother.current, span_alertsyndie("[owner.current.name] is now your blood brother."))

/datum/antagonist/brother/proc/finalize_brother()
	add_antag_hud(ANTAG_HUD_BROTHER, "brother", owner.current)
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/tatoralert.ogg', vol = 100, vary = FALSE, channel = CHANNEL_ANTAG_GREETING, pressure_affected = FALSE, use_reverb = FALSE)

/datum/antagonist/brother/admin_add(datum/mind/new_owner,mob/admin)
	// Jank: Add it normally
	if (istype(src, /datum/antagonist/brother/prime))
		create_team(new /datum/team/brother_team)
		team.forge_brother_objectives()
		return ..()
	//show list of possible brothers
	var/list/candidates = list()
	for(var/mob/living/L in GLOB.player_list)
		if(!L.mind || L.mind == new_owner || !can_be_owned(L.mind))
			continue
		candidates += L.mind

	var/choice = input(admin, "Choose the blood brother.", "Brother") as null|anything in sort_names(candidates)
	if(!choice)
		return
	var/datum/mind/bro = choice
	var/datum/team/brother_team/T = new
	T.add_member(new_owner)
	T.add_member(bro)
	T.pick_meeting_area()
	T.forge_brother_objectives()
	new_owner.add_antag_datum(/datum/antagonist/brother/prime/no_conversion, T)
	bro.add_antag_datum(/datum/antagonist/brother, T)
	T.update_name()
	message_admins("[key_name_admin(admin)] made [key_name_admin(new_owner)] and [key_name_admin(bro)] into blood brothers.")
	log_admin("[key_name(admin)] made [key_name(new_owner)] and [key_name(bro)] into blood brothers.")
