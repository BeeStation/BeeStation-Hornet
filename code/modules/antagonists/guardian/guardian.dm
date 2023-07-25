// why does this exist? simply so guardians show up on roundend screen.

/datum/antagonist/guardian
	name = "Guardian"
	show_in_antagpanel = FALSE
	var/datum/guardian_stats/stats
	var/datum/mind/summoner
	banning_key = ROLE_HOLOPARASITE

/datum/antagonist/guardian/roundend_report()
	var/list/parts = list()
	parts += ..()
	if(summoner)
		parts += "<B>SUMMONER</B>: [summoner.name]"
	if(stats)
		parts += "<b>DAMAGE:</b> [level_to_grade(stats.damage)]"
		parts += "<b>DEFENSE:</b> [level_to_grade(stats.defense)]"
		parts += "<b>SPEED:</b> [level_to_grade(stats.speed)]"
		parts += "<b>POTENTIAL:</b> [level_to_grade(stats.potential)]"
		parts += "<b>RANGE:</b> [level_to_grade(stats.range)]"
		if(stats.ability)
			parts += "<b>SPECIAL ABILITY:</b> [stats.ability.name]"
		for(var/datum/guardian_ability/minor/M in stats.minor_abilities)
			parts += "<b>MINOR ABILITY:</b> [M.name]"
	return parts.Join("<br>")

/datum/antagonist/guardian/antag_panel_data()
	var/mob/living/simple_animal/hostile/guardian/G = owner.current
	return "<B>Summoner: [G.summoner.name]/([ckey(G.summoner.key)])</B>"

/datum/antagonist/guardian/get_antag_name() // good to recognise whose holoparasite is
	return "Guardian of [summoner.name]"
