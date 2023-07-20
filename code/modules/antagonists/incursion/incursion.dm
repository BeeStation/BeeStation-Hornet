/datum/antagonist/incursion
	name = "Syndicate Incursion Member"
	antagpanel_category = "Incursion"
	job_rank = ROLE_INCURSION
	ui_name = "AntagInfoIncursion"
	var/special_role = ROLE_INCURSION
	var/datum/team/incursion/team
	var/datum/weakref/uplink_ref
	antag_moodlet = /datum/mood_event/focused
	hijack_speed = 0.5

/datum/antagonist/incursion/create_team(datum/team/incursion/new_team)
	if(!new_team)
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	team = new_team

/datum/antagonist/incursion/get_team()
	return team

/datum/antagonist/incursion/on_gain()
	SSticker.mode.incursionists += owner
	for(var/datum/objective/O in team.objectives)
		objectives += O
		log_objective(owner, O.explanation_text)
	owner.special_role = special_role
	finalize_incursion()
	return ..()

/datum/antagonist/incursion/on_removal()
	SSticker.mode.incursionists -= owner
	if(owner.current)
		to_chat(owner.current,"<span class='userdanger'>The Syndicate plans have fallen apart, you are no longer a member of the incursion.</span>")
	owner.special_role = null
	return ..()

/datum/antagonist/incursion/antag_panel_data()
	return "Conspirators : [get_team_members()]]"

/datum/antagonist/incursion/ui_static_data(mob/user)
	var/datum/component/uplink/uplink = uplink_ref?.resolve()
	var/list/data = list()
	data["antag_name"] = name
	data["code"] = uplink?.unlock_code
	data["failsafe_code"] = uplink?.failsafe_code
	data["uplink_unlock_info"] = uplink?.unlock_text
	data["objectives"] = get_objectives()
	data["members"] = team.get_member_names()
	return data

/datum/antagonist/incursion/proc/get_team_members()
	var/list/members = team.members - owner
	var/member_text = ""
	for(var/i = 1 to members.len)
		var/datum/mind/M = members[i]
		member_text += M.name
		if(i == members.len - 1)
			member_text += " and "
		else if(i != members.len)
			member_text += ", "
	return member_text

/datum/antagonist/incursion/greet()
	to_chat(owner.current, "<span class='alertsyndie'>You are the member of a Syndicate incursion team!</span>")
	to_chat(owner.current, "You have formed a team of Syndicate members with a similar mindset and must infiltrate the ranks of the station!")
	to_chat(owner.current, "You have been implanted with a syndicate headset for communication with your team. This headset can only be heard by you directly and if those pigs at Nanotrasen try to steal it they will violently explode!")
	owner.announce_objectives()
	owner.current.client?.tgui_panel?.give_antagonist_popup("Incursion",
		"Work with your team members to complete your objectives.")

/datum/antagonist/incursion/apply_innate_effects(mob/living/mob_override)
	if(issilicon(owner))
		var/mob/living/silicon/S = owner
		if(istype(S.laws, /datum/ai_laws/syndicate_override))
			SSticker.mode.update_incursion_icons_added(owner)
	else
		SSticker.mode.update_incursion_icons_added(owner)

/datum/antagonist/incursion/remove_innate_effects(mob/living/mob_override)
	SSticker.mode.update_incursion_icons_removed(owner)

/datum/antagonist/incursion/proc/finalize_incursion()
	equip()
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/tatoralert.ogg', 100, FALSE, pressure_affected = FALSE)

/datum/antagonist/incursion/admin_add(datum/mind/new_owner,mob/admin)
	//show list of possible brothers
	var/list/candidates = list()
	for(var/mob/living/L in GLOB.alive_mob_list)
		if(!L.mind || L.mind == new_owner || !can_be_owned(L.mind))
			continue
		candidates[L.mind.name] = L.mind

	if(SSticker.mode.incursion_team)
		new_owner.add_antag_datum(/datum/antagonist/incursion, SSticker.mode.incursion_team)
	else
		SSticker.mode.incursion_team = new
		SSticker.mode.incursion_team.add_member(new_owner)
		SSticker.mode.incursion_team.forge_team_objectives()
		new_owner.add_antag_datum(/datum/antagonist/incursion, SSticker.mode.incursion_team)
		message_admins("New incursion team created by [key_name_admin(admin)]")
	message_admins("[key_name_admin(admin)] made [key_name_admin(new_owner)] and [key_name_admin(new_owner.current)] into blood brothers.")
	log_admin("[key_name(admin)] made [key_name(new_owner)] and [key_name(new_owner.current)] into incursion traitor team.")

/datum/antagonist/incursion/proc/equip(var/silent = FALSE)
	var/obj/item/uplink_loc = owner.equip_traitor("The Syndicate", FALSE, src, 15)
	var/datum/component/uplink/uplink = uplink_loc?.GetComponent(/datum/component/uplink)
	if(uplink)
		uplink_ref = WEAKREF(uplink)
	var/obj/item/implant/radio/syndicate/selfdestruct/syndio = new
	syndio.implant(owner.current)

/datum/team/incursion
	name = "syndicate incursion force"
	member_name = "incursion member"

/datum/team/incursion/is_solo()
	return FALSE

/datum/team/incursion/proc/check_incursion_victory()
	for(var/datum/objective/objective in objectives)
		if(!objective.check_completion())
			return FALSE
	return TRUE

/datum/team/incursion/roundend_report()
	var/list/parts = list()

	parts += "<span class='header'>The members of the Syndicate incursion were:</span>"
	for(var/datum/mind/M in members)
		parts += printplayer(M)
	var/win = TRUE
	var/objective_count = 1
	for(var/datum/objective/objective in objectives)
		if(objective.check_completion())
			parts += "<B>Objective #[objective_count]</B>: [objective.explanation_text] <span class='greentext'>Success!</span>"
		else
			parts += "<B>Objective #[objective_count]</B>: [objective.explanation_text] <span class='redtext'>Fail.</span>"
			win = FALSE
		objective_count++

	var/purchases = ""
	var/TC_uses = 0
	LAZYINITLIST(GLOB.uplink_purchase_logs_by_key)
	for(var/I in members)
		var/datum/mind/syndicate = I
		var/datum/uplink_purchase_log/H = GLOB.uplink_purchase_logs_by_key[syndicate.key]
		if(H)
			TC_uses += H.total_spent
			purchases += H.generate_render(show_key = FALSE)
	parts += "(Syndicates used [TC_uses] TC) [purchases]"

	if(win)
		parts += "<span class='greentext'>The Syndicate were successful with their operation!</span>"
	else
		parts += "<span class='redtext'>The Syndicate failed their incursion!</span>"

	return "<div class='panel redborder'>[parts.Join("<br>")]</div>"

/datum/team/incursion/proc/add_objective(datum/objective/O, needs_target = FALSE)
	O.team = src
	if(needs_target)
		O.find_target(dupe_search_range = list(src))
	O.update_explanation_text()
	objectives += O
	for(var/datum/mind/member in members)
		log_objective(member, O.explanation_text)

/datum/team/incursion/proc/forge_team_objectives(list/restricted_jobs)
	objectives = list()
	var/is_hijacker = GLOB.player_details.len >= 35 ? prob(15) : 0
	for(var/i = 1 to max(1, CONFIG_GET(number/incursion_objective_amount)))
		forge_single_objective(CLAMP((5 + !is_hijacker)-i, 1, 3), restricted_jobs)	//Hijack = 3, 2, 1, 1 no hijack = 3, 3, 2, 1
	if(is_hijacker)
		if(!(locate(/datum/objective/hijack) in objectives))
			add_objective(new/datum/objective/hijack)
	else if(!(locate(/datum/objective/escape/single) in objectives))
		add_objective(new/datum/objective/escape/single, FALSE)

/datum/team/incursion/proc/forge_single_objective(difficulty=1, list/restricted_jobs)
	difficulty = CLAMP(difficulty, 1, 3)
	switch(difficulty)
		if(3)
			if(LAZYLEN(active_ais()) && prob(25))	//25 %
				//Kill AI
				add_objective(new/datum/objective/destroy, TRUE)
			else if(prob(32))						//~26%
				//Kill head
				var/datum/objective/assassinate/killchosen = new
				var/list/current_heads = SSjob.get_all_heads()
				if(!current_heads.len)
					generate_traitor_kill_objective(restricted_jobs)
					return
				var/datum/mind/selected = pick(current_heads)
				if(selected.special_role)
					generate_traitor_kill_objective(restricted_jobs)
					return
				killchosen.set_target(selected)
				add_objective(killchosen, FALSE)
			else									//~50%
				//Kill traitor
				generate_traitor_kill_objective(restricted_jobs)
		if(2)
			if(prob(30))
				add_objective(new/datum/objective/steal, TRUE)
			else
				generate_traitor_kill_objective(restricted_jobs)
		if(1)
			if(prob(70))
				add_objective(new/datum/objective/steal, TRUE)
			else
				generate_traitor_kill_objective(restricted_jobs)

/datum/team/incursion/proc/generate_traitor_kill_objective(list/restricted_jobs)
	//Spawn someone as a traitor
	var/list/datum/mind/people = SSticker.mode.get_alive_non_antagonsist_players_for_role(ROLE_EXCOMM, restricted_jobs)
	if(!LAZYLEN(people))
		log_game("Not enough players for incursion role. [LAZYLEN(people)]")
		return
	var/datum/mind/target = SSticker.mode.antag_pick(people, ROLE_EXCOMM)
	if(!target)
		log_game("No mind selected.")
		return
	target.make_Traitor()
	to_chat(target, "<span class='userdanger'>You have been declared an ex-communicate of the syndicate and are being hunted down.</span>")
	to_chat(target, "<span class='warning'>You have stolen syndicate objective documents, complete the objectives to throw off the syndicate and sabotage their efforts.</span>")
	target.store_memory("You have been declared an ex-communicate of the syndicate and are being hunted down by a group of traitors. Be careful!")
	//Create objective
	var/datum/objective/assassinate/incursion/killchosen = new
	killchosen.set_target(target)
	add_objective(killchosen, FALSE)

/datum/team/incursion/antag_listing_name()
	return "[name]"

