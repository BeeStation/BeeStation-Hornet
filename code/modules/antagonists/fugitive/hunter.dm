/datum/antagonist/fugitive_hunter
	name = "Fugitive Hunter"
	roundend_category = "Fugitive"
	job_rank = ROLE_FUGITIVE_HUNTER
	show_in_antagpanel = TRUE
	antagpanel_category = "Fugitive Hunters"
	show_to_ghosts = TRUE
	prevent_roundtype_conversion = FALSE
	count_against_dynamic_roll_chance = FALSE
	var/datum/team/fugitive_hunters/hunter_team
	var/datum/fugitive_type/hunter/backstory

/datum/antagonist/fugitive_hunter/apply_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	update_fugitive_icons_added(M)

/datum/antagonist/fugitive_hunter/remove_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	update_fugitive_icons_removed(M)

/datum/antagonist/fugitive_hunter/on_gain()
	for(var/datum/objective/O in hunter_team.objectives)
		objectives += O
		log_objective(owner, O.explanation_text)
	return ..()

/datum/antagonist/fugitive_hunter/greet()
	to_chat(owner, backstory.greet_message)
	to_chat(owner, "<span class='boldannounce'>You should not be killing anyone you please, but you can do anything to ensure the capture of the fugitives, even if that means going through the station.</span>")
	owner.announce_objectives()

/datum/antagonist/fugitive_hunter/create_team(datum/team/fugitive_hunters/new_team)
	if(!new_team)
		for(var/datum/antagonist/fugitive_hunter/H in GLOB.antagonists)
			if(!H.owner)
				continue
			if(H.hunter_team)
				hunter_team = H.hunter_team
				return
		hunter_team = new /datum/team/fugitive_hunters
		hunter_team.backstory = backstory
		hunter_team.forge_team_objectives()
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	hunter_team = new_team

/datum/antagonist/fugitive_hunter/get_team()
	return hunter_team


/datum/objective/capture_fugitive
	name = "Capture Fugitive"

/datum/objective/capture_fugitive/update_explanation_text()
	if(target)
		explanation_text = "Capture [target.name] (ideally, alive) in the fugitive capture device aboard the hunter shuttle."
	else
		explanation_text = "Free Objective"

/datum/objective/capture_fugitive/check_completion()
	var/datum/antagonist/fugitive/A = target.has_antag_datum(/datum/antagonist/fugitive)
	if(istype(A) && A.is_captured)
		return TRUE
	return explanation_text == "Free Objective" || ..()

/datum/objective/capture_fugitive/on_target_cryo()
	qdel(src)

/datum/team/fugitive_hunters
	name = "Fugitive Hunters"
	member_name = "hunter"
	var/datum/fugitive_type/hunter/backstory

/datum/team/fugitive_hunters/proc/forge_team_objectives()
	for(var/datum/antagonist/fugitive/A in GLOB.antagonists)
		if(!A.owner)
			continue
		var/datum/objective/capture_fugitive/capture = new()
		capture.team = src
		capture.set_target(A.owner)
		capture.update_explanation_text()
		objectives += capture

/datum/team/fugitive_hunters/proc/assemble_fugitive_results()
	var/list/fugitives_counted = list()
	var/list/fugitives_dead = list()
	var/list/fugitives_captured = list()
	for(var/datum/objective/capture_fugitive/O in objectives)
		var/datum/mind/T = O.target
		if(!T)
			continue
		var/datum/antagonist/fugitive/A = T.has_antag_datum(/datum/antagonist/fugitive)
		if(!A)
			continue
		fugitives_counted += A
		if(!A.living_on_capture)
			fugitives_dead += A
		if(A.is_captured)
			fugitives_captured += A
	return list(fugitives_counted, fugitives_dead, fugitives_captured)

/datum/team/fugitive_hunters/proc/all_hunters_dead()
	var/dead_boys = 0
	for(var/datum/mind/hunter_mind in members)
		if(!(ishuman(hunter_mind.current) || (hunter_mind.current.stat == DEAD)))
			dead_boys++
	return dead_boys >= members.len

/datum/team/fugitive_hunters/proc/get_result()
	var/list/fugitive_results = assemble_fugitive_results()
	var/list/fugitives_counted = fugitive_results[1]
	var/list/fugitives_dead = fugitive_results[2]
	var/list/fugitives_captured = fugitive_results[3]
	var/hunters_dead = all_hunters_dead()
	//this gets a little confusing so follow the comments if it helps
	if(!fugitives_counted.len)
		return
	if(fugitives_captured.len)//any captured
		if(fugitives_captured.len == fugitives_counted.len)//if the hunters captured all the fugitives, there's a couple special wins
			if(!fugitives_dead)//specifically all of the fugitives alive
				return FUGITIVE_RESULT_BADASS_HUNTER
			else if(hunters_dead)//specifically all of the hunters died (while capturing all the fugitives)
				return FUGITIVE_RESULT_POSTMORTEM_HUNTER
			else//no special conditional wins, so just the normal major victory
				return FUGITIVE_RESULT_MAJOR_HUNTER
		else if(!hunters_dead)//so some amount captured, and the hunters survived.
			return FUGITIVE_RESULT_HUNTER_VICTORY
		else//so some amount captured, but NO survivors.
			return FUGITIVE_RESULT_MINOR_HUNTER
	else//from here on out, hunters lost because they did not capture any fugitive dead or alive. there are different levels of getting beat though:
		if(!fugitives_dead)//all fugitives survived
			return FUGITIVE_RESULT_MAJOR_FUGITIVE
		else if(fugitives_dead < fugitives_counted)//at least ANY fugitive lived
			return FUGITIVE_RESULT_FUGITIVE_VICTORY
		else if(!hunters_dead)//all fugitives died, but none were taken in by the hunters. minor win
			return FUGITIVE_RESULT_MINOR_FUGITIVE
		else//all fugitives died, all hunters died, nobody brought back. seems weird to not give fugitives a victory if they managed to kill the hunters but literally no progress to either goal should lead to a nobody wins situation
			return FUGITIVE_RESULT_STALEMATE

/datum/team/fugitive_hunters/roundend_report() //shows the number of fugitives, but not if they won in case there is no security
	if(!members.len)
		return

	var/list/result = list()
	result += "<div class='panel redborder'>...And <b>[members.len]</b> [backstory.multiple_name] tried to hunt them down!<br />"
	result += "<span class='header'>[backstory.multiple_name] ([name]):</span>"
	result += "The [member_name]s were:"
	result += printplayerlist(members)

	if(objectives.len)
		result += "<span class='header'>Team had following objectives:</span>"
		var/objective_count = 1
		for(var/datum/objective/objective in objectives)
			if(objective.check_completion())
				result += "<B>Objective #[objective_count]</B>: [objective.explanation_text] <span class='greentext'>Success!</span>"
			else
				result += "<B>Objective #[objective_count]</B>: [objective.explanation_text] <span class='redtext'>Fail.</span>"
			objective_count++

	result += "<br />"

	switch(get_result())
		if(FUGITIVE_RESULT_BADASS_HUNTER)//use defines
			result += "<span class='greentext big'>Badass [backstory.name] Victory!</span>"
			result += "<b>The [backstory.multiple_name] managed to capture every fugitive, alive!</b>"
		if(FUGITIVE_RESULT_POSTMORTEM_HUNTER)
			result += "<span class='greentext big'>Postmortem [backstory.name] Victory!</span>"
			result += "<b>The [backstory.multiple_name] managed to capture every fugitive, but all of them died! Spooky!</b>"
		if(FUGITIVE_RESULT_MAJOR_HUNTER)
			result += "<span class='greentext big'>Major [backstory.name] Victory</span>"
			result += "<b>The [backstory.multiple_name] managed to capture every fugitive, dead or alive.</b>"
		if(FUGITIVE_RESULT_HUNTER_VICTORY)
			result += "<span class='greentext big'>[backstory.name] Victory</span>"
			result += "<b>The [backstory.multiple_name] managed to capture a fugitive, dead or alive.</b>"
		if(FUGITIVE_RESULT_MINOR_HUNTER)
			result += "<span class='greentext big'>Minor [backstory.name] Victory</span>"
			result += "<b>All the [backstory.multiple_name] died, but managed to capture a fugitive, dead or alive.</b>"
		if(FUGITIVE_RESULT_STALEMATE)
			result += "<span class='neutraltext big'>Bloody Stalemate</span>"
			result += "<b>Everyone died, and no fugitives were recovered!</b>"
		if(FUGITIVE_RESULT_MINOR_FUGITIVE)
			result += "<span class='redtext big'>Minor Fugitive Victory</span>"
			result += "<b>All the fugitives died, but none were recovered!</b>"
		if(FUGITIVE_RESULT_FUGITIVE_VICTORY)
			result += "<span class='redtext big'>Fugitive Victory</span>"
			result += "<b>A fugitive survived, and no bodies were recovered by the [backstory.multiple_name].</b>"
		if(FUGITIVE_RESULT_MAJOR_FUGITIVE)
			result += "<span class='redtext big'>Major Fugitive Victory</span>"
			result += "<b>All of the fugitives survived and avoided capture!</b>"
		else //get_result returned null- either bugged or no fugitives showed
			result += "<span class='neutraltext big'>Prank Call!</span>"
			result += "<b>[backstory.multiple_name] were called, yet there were no fugitives...?</b>"

	result += "</div>"

	return result.Join("<br>")

/datum/antagonist/fugitive_hunter/proc/update_fugitive_icons_added(var/mob/living/carbon/human/fugitive)
	var/datum/atom_hud/antag/fughud = GLOB.huds[ANTAG_HUD_FUGITIVE]
	fughud.join_hud(fugitive)
	set_antag_hud(fugitive, "fugitive_hunter")

/datum/antagonist/fugitive_hunter/proc/update_fugitive_icons_removed(var/mob/living/carbon/human/fugitive)
	var/datum/atom_hud/antag/fughud = GLOB.huds[ANTAG_HUD_FUGITIVE]
	fughud.leave_hud(fugitive)
	set_antag_hud(fugitive, null)
