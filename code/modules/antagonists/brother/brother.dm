/datum/antagonist/brother
	name = "Brother"
	antagpanel_category = "Brother"
	banning_key = ROLE_BROTHER
	required_living_playtime = 4
	ui_name = "AntagInfoBrother"
	hijack_speed = 0.5
	var/datum/team/brother_team/team
	antag_moodlet = /datum/mood_event/focused

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
	finalize_brother()
	return ..()

/datum/antagonist/brother/on_removal()
	if(owner.current)
		to_chat(owner.current,span_userdanger("You are no longer the Blood Brother!"))
	owner.special_role = null
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
	to_chat(owner.current, span_alertsyndie("You are the Blood Brother of [brother_text]."))
	to_chat(owner.current, "The Syndicate only accepts those that have proven themselves. Prove yourself and prove your [team.member_name]s by completing your objectives together! You and your team are outfitted with communication implants allowing for direct, encrypted communication.")
	owner.announce_objectives()
	give_meeting_area()
	owner.current.client?.tgui_panel?.give_antagonist_popup("Blood Brother",
		"The Syndicate only accepts those that have proven themselves. Prove yourself and prove your [team.member_name]s by completing your objectives together!")

/datum/antagonist/brother/proc/finalize_brother()
	var/obj/item/implant/bloodbrother/I = new /obj/item/implant/bloodbrother()
	I.implant(owner.current, null, TRUE, TRUE)
	if(team.team_id <= length(GLOB.color_list_blood_brothers))
		I.span_implant_colour = GLOB.color_list_blood_brothers[team.team_id]
	else
		I.span_implant_colour = "cfc_redpurple"
		stack_trace("Blood brother teams exist more than [length(GLOB.color_list_blood_brothers)] teams, and colour preset is ran out")
	for(var/datum/mind/M in team.members) // Link the implants of all team members
		var/obj/item/implant/bloodbrother/T = locate() in M.current.implants
		I.link_implant(T)
	add_antag_hud(ANTAG_HUD_BROTHER, "brother", owner.current)
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/tatoralert.ogg', vol = 100, vary = FALSE, channel = CHANNEL_ANTAG_GREETING, pressure_affected = FALSE, use_reverb = FALSE)

/datum/antagonist/brother/admin_add(datum/mind/new_owner,mob/admin)
	//show list of possible brothers
	var/list/candidates = list()
	for(var/mob/living/L in GLOB.player_list)
		if(!L.mind || L.mind == new_owner || !can_be_owned(L.mind))
			continue
		candidates += L.mind

	var/choice = input(admin,"Choose the blood brother.", "Brother") as null|anything in sort_names(candidates)
	if(!choice)
		return
	var/datum/mind/bro = choice
	var/datum/team/brother_team/T = new
	T.add_member(new_owner)
	T.add_member(bro)
	T.pick_meeting_area()
	T.forge_brother_objectives()
	new_owner.add_antag_datum(/datum/antagonist/brother,T)
	bro.add_antag_datum(/datum/antagonist/brother, T)
	T.update_name()
	message_admins("[key_name_admin(admin)] made [key_name_admin(new_owner)] and [key_name_admin(bro)] into blood brothers.")
	log_admin("[key_name(admin)] made [key_name(new_owner)] and [key_name(bro)] into blood brothers.")

/datum/team/brother_team
	name = "brotherhood"
	member_name = "blood brother"
	var/team_id
	var/meeting_area
	var/static/meeting_areas = list("The Bar", "Dorms", "Escape Dock", "Arrivals", "Holodeck", "Primary Tool Storage", "Recreation Area", "Chapel", "Library")

/datum/team/brother_team/New(starting_members)
	. = ..()
	var/static/blood_teams
	team_id = ++blood_teams

/datum/team/brother_team/is_solo()
	return FALSE

/datum/team/brother_team/proc/pick_meeting_area()
	meeting_area = pick(meeting_areas)
	meeting_areas -= meeting_area

/datum/team/brother_team/proc/update_name()
	var/list/last_names = list()
	for(var/datum/mind/M in members)
		var/list/split_name = splittext(M.name," ")
		last_names += split_name[split_name.len]

	name = last_names.Join(" & ")

/datum/team/brother_team/roundend_report()
	var/list/parts = list()

	parts += span_header("The blood brothers of [name] were:")
	for(var/datum/mind/M in members)
		parts += printplayer(M)
	var/win = TRUE
	var/objective_count = 1
	for(var/datum/objective/objective in objectives)
		if(objective.check_completion())
			parts += "<B>Objective #[objective_count]</B>: [objective.explanation_text] [span_greentext("Success!")]"
		else
			parts += "<B>Objective #[objective_count]</B>: [objective.explanation_text] [span_redtext("Fail.")]"
			win = FALSE
		objective_count++
	if(win)
		parts += span_greentext("The blood brothers were successful!")
	else
		parts += span_redtext("The blood brothers have failed!")

	return "<div class='panel redborder'>[parts.Join("<br>")]</div>"

/datum/team/brother_team/proc/add_objective(datum/objective/O, needs_target = FALSE)
	O.team = src
	if(needs_target)
		O.find_target(dupe_search_range = list(src))
	O.update_explanation_text()
	objectives += O
	for(var/datum/mind/member in members)
		log_objective(member, O.explanation_text)

/datum/team/brother_team/proc/forge_brother_objectives()
	objectives = list()
	var/is_hijacker = prob(10)
	for(var/i = 1 to max(1, CONFIG_GET(number/brother_objectives_amount) + (members.len > 2) - is_hijacker))
		forge_single_objective()
	if(is_hijacker)
		if(!locate(/datum/objective/hijack) in objectives)
			add_objective(new/datum/objective/hijack)
	else if(!locate(/datum/objective/escape) in objectives)
		add_objective(new/datum/objective/escape)

/datum/team/brother_team/proc/forge_single_objective()
	if(prob(50))
		if(LAZYLEN(active_ais()) && prob(100/GLOB.joined_player_list.len))
			add_objective(new/datum/objective/destroy, TRUE)
		else if(prob(30))
			add_objective(new/datum/objective/maroon, TRUE)
		else
			add_objective(new/datum/objective/assassinate, TRUE)
	else
		add_objective(new/datum/objective/steal, TRUE)

/datum/team/brother_team/antag_listing_name()
	return "[name] blood brothers"
