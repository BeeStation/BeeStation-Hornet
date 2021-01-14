/proc/brainwash(mob/living/L, directives)
	if(!L.mind)
		return
	if(!islist(directives))
		directives = list(directives)
	var/datum/mind/M = L.mind
	var/datum/antagonist/brainwashed/B = M.has_antag_datum(/datum/antagonist/brainwashed)
	if(B)
		for(var/O in directives)
			var/datum/objective/brainwashing/objective = new(O)
			B.objectives += objective
			log_objective(M, objective.explanation_text)
		B.greet()
	else
		B = new()
		for(var/O in directives)
			var/datum/objective/brainwashing/objective = new(O)
			B.objectives += objective
			log_objective(M, objective.explanation_text)
		M.add_antag_datum(B)

	var/begin_message = "<span class='deadsay'><b>[L]</b> has been brainwashed with the following objectives: "
	var/obj_message = english_list(directives)
	var/end_message = "</b>.</span>"
	var/rendered = begin_message + obj_message + end_message
	deadchat_broadcast(rendered, follow_target = L, turf_target = get_turf(L), message_type=DEADCHAT_REGULAR)

/datum/antagonist/brainwashed
	name = "Brainwashed Victim"
	job_rank = ROLE_BRAINWASHED
	roundend_category = "brainwashed victims"
	show_in_antagpanel = TRUE
	antagpanel_category = "Other"
	show_name_in_check_antagonists = TRUE

/datum/antagonist/brainwashed/greet()
	to_chat(owner, "<span class='warning'>Your mind reels as it begins focusing on a single purpose...</span>")
	to_chat(owner, "<big><span class='warning'><b>Follow the Directives, at any cost!</b></span></big>")
	var/i = 1
	for(var/X in objectives)
		var/datum/objective/O = X
		to_chat(owner, "<b>[i].</b> [O.explanation_text]")
		i++

/datum/antagonist/brainwashed/farewell()
	to_chat(owner, "<span class='warning'>Your mind suddenly clears...</span>")
	to_chat(owner, "<big><span class='warning'><b>You feel the weight of the Directives disappear! You no longer have to obey them.</b></span></big>")
	owner.announce_objectives()

/datum/antagonist/brainwashed/apply_innate_effects(mob/living/mob_override)
	. = ..()
	//Give traitor appearence on hud (If they are not an antag already)
	var/datum/atom_hud/antag/traitorhud = GLOB.huds[ANTAG_HUD_BRAINWASHED]
	traitorhud.join_hud(owner.current)
	if(!owner.antag_hud_icon_state)
		set_antag_hud(owner.current, "brainwash")

/datum/antagonist/brainwashed/remove_innate_effects(mob/living/mob_override)
	. = ..()
	//Clear the hud if they haven't become something else and had the hud overwritten
	var/datum/atom_hud/antag/traitorhud = GLOB.huds[ANTAG_HUD_BRAINWASHED]
	traitorhud.leave_hud(owner.current)
	if(owner.antag_hud_icon_state == "brainwash")
		set_antag_hud(owner.current, null)

/datum/antagonist/brainwashed/admin_add(datum/mind/new_owner,mob/admin)
	var/mob/living/carbon/C = new_owner.current
	if(!istype(C))
		return
	var/list/objectives = list()
	do
		var/objective = stripped_input(admin, "Add an objective, or leave empty to finish.", "Brainwashing", null, MAX_MESSAGE_LEN)
		if(objective)
			objectives += objective
			log_objective(C, objective, admin)
	while(alert(admin,"Add another objective?","More Brainwashing","Yes","No") == "Yes")

	if(alert(admin,"Confirm Brainwashing?","Are you sure?","Yes","No") == "No")
		return

	if(!LAZYLEN(objectives))
		return

	if(QDELETED(C))
		to_chat(admin, "Mob doesn't exist anymore")
		return

	brainwash(C, objectives)
	var/obj_list = english_list(objectives)
	message_admins("[key_name_admin(admin)] has brainwashed [key_name_admin(C)] with the following objectives: [obj_list].")
	log_admin("[key_name(admin)] has brainwashed [key_name(C)] with the following objectives: [obj_list].")

/datum/objective/brainwashing
	completed = TRUE
