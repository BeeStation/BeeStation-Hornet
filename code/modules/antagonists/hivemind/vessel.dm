

/datum/antagonist/hivevessel
	name = "Awoken Vessel"
	job_rank = ROLE_BRAINWASHED
	roundend_category = "awoken vessels"
	show_in_antagpanel = TRUE
	antagpanel_category = "Other"
	show_name_in_check_antagonists = TRUE


/mob/living/proc/is_wokevessel()
	return mind?.has_antag_datum(/datum/antagonist/hivevessel)


/datum/antagonist/hivevessel/apply_innate_effects()
	handle_clown_mutation(owner.current, "Our newfound powers allow us to overcome our clownish nature, allowing us to wield weapons with impunity.")
	var/datum/atom_hud/antag/hud = GLOB.huds[ANTAG_HUD_HIVE]
	hud.join_hud(owner.current)
	set_antag_hud(owner.current, "hivevessel")

/datum/antagonist/hivevessel/remove_innate_effects()
	handle_clown_mutation(owner.current, removing=FALSE)
	var/datum/atom_hud/antag/hud = GLOB.huds[ANTAG_HUD_HIVE]
	hud.leave_hud(owner.current)
	set_antag_hud(owner.current, null)

/datum/antagonist/hivevessel/greet()
	to_chat(owner, "<span class='assimilator'>Your mind is suddenly opened, as you see the pinnacle of evolution...</span>")
	to_chat(owner, "<big><span class='warning'><b>Follow your objectives, at any cost!</b></span></big>")
	var/i = 1
	for(var/X in objectives)
		var/datum/objective/O = X
		to_chat(owner, "<b>[i].</b> [O.explanation_text]")
		i++

/datum/antagonist/hivevessel/farewell()
	to_chat(owner, "<span class='assimilator'>Your mind closes up once more...</span>")
	to_chat(owner, "<big><span class='warning'><b>You feel the weight of your objectives disappear! You no longer have to obey them.</b></span></big>")

/datum/antagonist/hivevessel/roundend_report()
	if(!owner)
		CRASH("antagonist datum without owner")

	var/list/report = list()
	report += printplayer(owner)
	if(objectives.len)
		report += printobjectives(objectives)
	return report.Join("<br>")
