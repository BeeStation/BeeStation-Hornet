/// Brainwash a mob, adding objectives to an existing brainwash if it already exists.
/proc/brainwash(mob/living/victim, list/directives, source)
	. = list()
	if(!victim.mind)
		return
	if(!islist(directives))
		directives = list(directives)
	var/datum/mind/victim_mind = victim.mind
	var/datum/antagonist/brainwashed/brainwash = victim_mind.has_antag_datum(/datum/antagonist/brainwashed)
	if(brainwash)
		for(var/directive in directives)
			var/datum/objective/brainwashing/objective = new(directive)
			if(source)
				objective.source = source
			brainwash.objectives += objective
			. += WEAKREF(objective)
			log_objective(victim_mind, objective.explanation_text)
		brainwash.greet()
	else
		brainwash = new()
		for(var/directive in directives)
			var/datum/objective/brainwashing/objective = new(directive)
			if(source)
				objective.source = source
			brainwash.objectives += objective
			. += WEAKREF(objective)
			log_objective(victim_mind, objective.explanation_text)
		victim_mind.add_antag_datum(brainwash)

	var/source_message = source ? " by [source]" : ""
	var/begin_message = (" has been brainwashed with the following objective[length(directives) > 1 ? "s" : ""][source_message]: ")
	var/obj_message = english_list(directives)
	var/rendered = begin_message + obj_message
	if(!(rendered[length(rendered)] in list(",",":",";",".","?","!","\'","-")))
		rendered += "." //Good punctuation is important :)
	deadchat_broadcast(rendered, "<b>[victim]</b>", follow_target = victim, turf_target = get_turf(victim), message_type=DEADCHAT_ANNOUNCEMENT)
	victim.log_message(rendered, LOG_ATTACK, color="#960000")

/// Removes objectives from someone's brainwash.
/proc/unbrainwash(mob/living/victim, list/directives)
	var/datum/antagonist/brainwashed/brainwash = victim?.mind?.has_antag_datum(/datum/antagonist/brainwashed)
	if(!brainwash)
		return FALSE
	if(directives)
		if(!isnull(directives) && !islist(directives))
			directives = list(directives)
		var/list/removed_objectives = list()
		for(var/D in directives)
			var/datum/objective/directive
			if(istype(D, /datum/weakref))
				var/datum/weakref/directive_weakref = D
				directive = directive_weakref.resolve()
			else if(istype(D, /datum/objective))
				directive = D
			if(!directive || !istype(directive))
				continue
			brainwash.objectives -= directive
			removed_objectives += directive
		log_admin("[key_name(victim)] had the following brainwashing objective[length(removed_objectives) > 1 ? "s" : ""] removed: [english_list(removed_objectives)].")
		if(LAZYLEN(brainwash.objectives))
			to_chat(victim, "<big>[span_warning("<b>[length(removed_objectives) > 1 ? "Some" : "One"] of your Directives fade away! You only have to obey the remaining Directives now.</b>")]</big>")
			victim.mind.announce_objectives()
		else
			victim.mind.remove_antag_datum(/datum/antagonist/brainwashed)
		QDEL_LIST(removed_objectives)
	else
		log_admin("[key_name(victim)] had all of their brainwashing objectives removed: [english_list(brainwash.objectives)].")
		QDEL_LIST(brainwash.objectives)
		victim.mind.remove_antag_datum(/datum/antagonist/brainwashed)

/datum/antagonist/brainwashed
	name = "Brainwashed Victim"
	banning_key = ROLE_BRAINWASHED
	roundend_category = "brainwashed victims"
	show_in_antagpanel = TRUE
	antagpanel_category = "Other"
	show_name_in_check_antagonists = TRUE
	ui_name = "AntagInfoBrainwashed"
	required_living_playtime = 0

/datum/antagonist/brainwashed/on_gain()
	owner.current.log_message("has been brainwashed!", LOG_ATTACK, color="#960000")
	. = ..()

/datum/antagonist/brainwashed/on_removal()
	owner.current.log_message("is no longer brainwashed!", LOG_ATTACK, color="#960000")
	return ..()

/datum/antagonist/brainwashed/greet()
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/brainwash.ogg', vol = 100, vary = FALSE, channel = CHANNEL_ANTAG_GREETING, pressure_affected = FALSE, use_reverb = FALSE)
	to_chat(owner, span_warning("Your mind reels as it begins focusing on a single purpose..."))
	to_chat(owner, "<big>[span_warning("<b>Follow the Directives, at any cost!</b>")]</big>")
	var/i = 1
	for(var/X in objectives)
		var/datum/objective/O = X
		to_chat(owner, "<b>[i].</b> [O.explanation_text]")
		i++
	owner.current.client?.tgui_panel?.give_antagonist_popup("Brainwashed",
		"You have been brainwashed!\n\
		Ensure you follow your directive, no matter the cost.")

/datum/antagonist/brainwashed/farewell()
	to_chat(owner, span_warning("Your mind suddenly clears..."))
	to_chat(owner, "<big>[span_warning("<b>You feel the weight of the Directives disappear! You no longer have to obey them.</b>")]</big>")
	owner.announce_objectives()

/datum/antagonist/brainwashed/apply_innate_effects(mob/living/mob_override)
	. = ..()
	//Give traitor appearance on hud (If they are not an antag already)
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
	var/objective_count = 1
	do
		var/objective = tgui_input_text(admin, "Add a brainwashing objective:", "Objective #[objective_count]:")
		if(!objective)
			to_chat(admin, span_warning("No objective entered."))
		if(objective)
			objectives += objective
			objective_count++
			log_objective(C, objective, admin)
	while(tgui_alert(admin, "Add another objective?", "More Brainwashing", list("Yes", "No")) == "Yes")

	if(tgui_alert(admin, "Confirm Brainwashing?", "Are you sure?", list("Yes", "No")) != "Yes")
		to_chat(admin, "Brainwashing cancelled.")
		return

	if(!LAZYLEN(objectives))
		return

	if(QDELETED(C))
		to_chat(admin, "Mob doesn't exist anymore")
		return

	brainwash(C, objectives, "adminbus")
	var/obj_list = english_list(objectives)
	message_admins("[key_name_admin(admin)] has brainwashed [key_name_admin(C)] with the following objectives: [obj_list].")
	log_admin("[key_name(admin)] has brainwashed [key_name(C)] with the following objectives: [obj_list].")

/datum/objective/brainwashing
	completed = TRUE
	var/source
