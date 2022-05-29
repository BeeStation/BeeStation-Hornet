//The hunters!!
/datum/antagonist/fugitive_hunter
	name = "Fugitive Hunter"
	roundend_category = "Fugitive"
	silent = TRUE //greet called by the spawn
	show_in_antagpanel = FALSE
	prevent_roundtype_conversion = FALSE
	var/datum/team/fugitive_hunters/hunter_team
	var/backstory = "error"

/datum/antagonist/fugitive_hunter/apply_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	update_fugitive_icons_added(M)

/datum/antagonist/fugitive_hunter/remove_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	update_fugitive_icons_removed(M)

/datum/antagonist/fugitive_hunter/on_gain()
	forge_objectives()
	. = ..()
	for(var/datum/objective/O in objectives)
		log_objective(owner, O.explanation_text)

/datum/antagonist/fugitive_hunter/proc/forge_objectives() //this isn't an actual objective because it's about round end rosters
	var/datum/objective/capture = new /datum/objective
	capture.owner = owner
	capture.explanation_text = "Capture the fugitives in the station and put them into the bluespace capture machine on your ship."
	objectives += capture

/datum/antagonist/fugitive_hunter/greet()
	switch(backstory)
		if("space cop")
			to_chat(owner, "<span class='boldannounce'>Justice has arrived. I am a member of the Spacepol!</span>")
			to_chat(owner, "<B>The criminals should be on the station, we have special huds implanted to recognize them.</B>")
			to_chat(owner, "<B>As we have lost pretty much all power over these damned lawless megacorporations, it's a mystery if their security will cooperate with us.</B>")
		if("russian")
			to_chat(src, "<span class='danger'>Ay blyat. I am a space-russian smuggler! We were mid-flight when our cargo was beamed off our ship!</span>")
			to_chat(src, "<span class='danger'>We were hailed by a man in a green uniform, promising the safe return of our goods in exchange for a favor:</span>")
			to_chat(src, "<span class='danger'>There is a local station housing fugitives that the man is after, he wants them returned; dead or alive.</span>")
			to_chat(src, "<span class='danger'>We will not be able to make ends meet without our cargo, so we must do as he says and capture them.</span>")

	to_chat(owner, "<span class='boldannounce'>You are not an antagonist in that you may kill whomever you please, but you can do anything to ensure the capture of the fugitives, even if that means going through the station.</span>")
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
		hunter_team.update_objectives()
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	hunter_team = new_team

/datum/antagonist/fugitive_hunter/get_team()
	return hunter_team

/datum/team/fugitive_hunters
	var/backstory = "error"

/datum/team/fugitive_hunters/proc/update_objectives(initial = FALSE)
	objectives = list()
	var/datum/objective/O = new()
	O.team = src
	objectives += O
	for(var/datum/mind/M in members)
		log_objective(M, O.explanation_text)

/datum/team/fugitive_hunters/proc/assemble_fugitive_results()
	var/list/fugitives_counted = list()
	var/list/fugitives_dead = list()
	var/list/fugitives_captured = list()
	for(var/datum/antagonist/fugitive/A in GLOB.antagonists)
		if(!A.owner)
			continue
		fugitives_counted += A
		if(A.owner.current.stat == DEAD)
			fugitives_dead += A
		if(A.is_captured)
			fugitives_captured += A
	. = list(fugitives_counted, fugitives_dead, fugitives_captured) //okay, check out how cool this is.

/datum/team/fugitive_hunters/proc/all_hunters_dead()
	var/dead_boys = 0
	for(var/I in members)
		var/datum/mind/hunter_mind = I
		if(!(ishuman(hunter_mind.current) || (hunter_mind.current.stat == DEAD)))
			dead_boys++
	return dead_boys >= members.len

/datum/team/fugitive_hunters/roundend_report() //shows the number of fugitives, but not if they won in case there is no security
	if(!members.len)
		return

	var/list/result = list()

	result += "<div class='panel redborder'>...And <B>[members.len]</B> [backstory]s tried to hunt them down!"

	for(var/datum/mind/M in members)
		result += "<b>[printplayer(M)]</b>"
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
