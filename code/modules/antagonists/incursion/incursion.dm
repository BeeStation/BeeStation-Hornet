/datum/antagonist/incursion
	name = "Syndicate Incursion Member"
	antagpanel_category = "Incursion"
	job_rank = ROLE_INCURSION
	var/special_role = ROLE_INCURSION
	var/datum/team/incursion/team
	antag_moodlet = /datum/mood_event/focused
	can_hijack = HIJACK_HIJACKER

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
	objectives += team.objectives
	for(var/datum/objective/O in team.objectives)
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
	to_chat(owner.current, "<span class='alertsyndie'>You are a member of a Syndicate incursion.</span>")
	to_chat(owner.current, "You are in a large undercover team determined to bring the fall of Nanotrasen.")
	owner.announce_objectives()

/datum/antagonist/incursion/proc/finalize_incursion()
	SSticker.mode.update_incursion_icons_added(owner)
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/tatoralert.ogg', 100, FALSE, pressure_affected = FALSE)
	equip()

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
	log_admin("[key_name(admin)] made [key_name(new_owner)] and [key_name(new_owner.current)] into blood brothers.")

/datum/antagonist/incursion/proc/equip(var/silent = FALSE)
	owner.equip_traitor("The Syndicate", silent, src)
	for(var/obj/item/radio/headset/H in owner.current.get_contents())
		H.syndie = TRUE

/datum/team/incursion
	name = "syndicate incursion force"
	member_name = "incursion member"

/datum/team/incursion/is_solo()
	return FALSE

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

/datum/team/incursion/proc/forge_team_objectives()
	objectives = list()
	var/is_hijacker = prob(30)
	for(var/i = 1 to max(1, CONFIG_GET(number/incursion_objective_amount)))
		forge_single_objective(CLAMP((4 + !is_hijacker)-i, 1, 3))	//Hijack = 3, 2, 1, 1 no hijack = 3, 3, 2, 1
	if(is_hijacker)
		if(!(locate(/datum/objective/hijack) in objectives))
			add_objective(new/datum/objective/hijack)
	else if(!(locate(/datum/objective/escape/single) in objectives))
		add_objective(new/datum/objective/escape/single, FALSE)

/datum/team/incursion/proc/forge_single_objective(difficulty=1)
	difficulty = CLAMP(difficulty, 1, 3)
	switch(difficulty)
		if(3)
			if(LAZYLEN(active_ais()) && prob(40))
				//Kill AI
				add_objective(new/datum/objective/destroy, TRUE)
			else if(prob(40))
				//Kill head
				var/datum/objective/assassinate/killchosen = new
				var/current_heads = SSjob.get_all_heads()
				var/datum/mind/selected = pick(current_heads)
				killchosen.target = selected
				add_objective(killchosen, FALSE)
			else
				//Kill traitor
				generate_traitor_kill_objective()
		if(2)
			if(prob(30))
				add_objective(new/datum/objective/maroon, TRUE)
			else
				add_objective(new/datum/objective/assassinate, TRUE)
		if(1)
			if(prob(60))
				add_objective(new/datum/objective/steal, TRUE)
			else
				add_objective(new/datum/objective/assassinate, TRUE)

/datum/team/incursion/proc/generate_traitor_kill_objective()
	//Spawn someone as a traitor
	var/datum/mind/target = SSticker.mode.antag_pick(SSticker.mode.get_players_for_role(ROLE_INCURSION), ROLE_INCURSION)
	if(!target)
		return
	target.make_Traitor()
	to_chat(target, "<span class='userdanger'>You have been declared an ex-communicate of the syndicate and are being hunted down.</span>")
	to_chat(target, "<span class='warning'>You have stolen syndicate objective documents, complete the objectives to throw off the syndicate and sabotage their efforts.</span>")
	//Create objective
	var/datum/objective/assassinate/incursion/killchosen = new
	killchosen.target = target
	add_objective(killchosen, FALSE)

/datum/team/incursion/antag_listing_name()
	return "[name]"


