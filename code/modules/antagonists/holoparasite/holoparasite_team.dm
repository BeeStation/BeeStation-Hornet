/datum/team/holoparasites
	name = "holoparasites"
	member_name = "holoparasite"
	var/datum/holoparasite_holder/holder
	var/blackbox_recorded = FALSE

/datum/team/holoparasites/New(starting_members, datum/holoparasite_holder/holder)
	. = ..()
	if(!holder)
		CRASH("Attempted to create holoparasite team without holder")
	if(holder.team)
		CRASH("Attempted to create duplicate holoparasite team for the holder of [key_name(holder.owner)]")
	src.holder = holder
	holder.team = src
	objectives += new /datum/objective/holoparasite(holder.owner, src)

/datum/team/holoparasites/get_team_name()
	return "Holoparasites of [holder.owner.name]"

/datum/team/holoparasites/roundend_report()
	// bleh I don't like doing this here, but there's no other place to do it without adding new signals, and I've added WAY too many signals already...
	record_to_blackbox()

	var/list/parts = list()

	parts += "<span class='header'>[holder.owner.name] had the following holoparasite[is_solo() ? "" : "s"]:</span>"
	parts += print_all_holoparas()

	return "<div class='panel redborder'>[parts.Join("<br>")]</div>"

/datum/team/holoparasites/proc/print_holopara(datum/mind/holopara_mind)
	if(!holopara_mind)
		return
	if(!holopara_mind.current || !istype(holopara_mind.current, /mob/living/simple_animal/hostile/holoparasite))
		return
	var/list/parts = list()
	var/mob/living/simple_animal/hostile/holoparasite/holoparasite = holopara_mind.current
	parts += "<b>[holopara_mind.key]</b> was <b>[holoparasite.color_name]</b>, the <b>[holoparasite.theme.name]</b>"
	if(holoparasite.stats)
		var/datum/holoparasite_stats/stats = holoparasite.stats
		parts += "<b>Damage:</b> [stats.damage]/5"
		parts += "<b>Defense:</b> [stats.defense]/5"
		parts += "<b>Speed:</b> [stats.speed]/5"
		parts += "<b>Potential:</b> [stats.potential]/5"
		parts += "<b>Range:</b> [stats.range]/5"
		parts += "<b>Weapon:</b> [stats.weapon.name]"
		if(stats.ability)
			parts += "<b>Special Ability:</b> [stats.ability.name]"
		for(var/datum/holoparasite_ability/lesser/ability as anything in stats.lesser_abilities)
			parts += "<b>Minor Ability:</b> [ability.name]"
	return parts.Join("<br>")

/datum/team/holoparasites/proc/print_all_holoparas()
	var/list/parts = list()

	parts += "<ul class='playerlist'>"
	for(var/datum/mind/mind in members)
		parts += "<li>[print_holopara(mind)]</li>"
	parts += "</ul>"
	return parts.Join()

/datum/team/holoparasites/proc/record_to_blackbox()
	if(blackbox_recorded)
		return
	blackbox_recorded = TRUE
	var/list/info = list(
		"stat" = "dead",
		"crit" = FALSE,
		"escaped" = holder.owner.force_escaped,
		"objectives" = list(
			"greentext" = TRUE,
			"total" = 0,
			"complete" = 0
		)
	)
	var/list/datum/objective/owner_objectives = holder.owner.get_all_antag_objectives()
	if(length(owner_objectives))
		for(var/datum/objective/objective as anything in owner_objectives)
			info["objectives"]["total"]++
			if(objective.check_completion())
				info["objectives"]["complete"]++
			else
				info["objectives"]["greentext"] = FALSE
	if(!QDELETED(holder.owner.current))
		var/mob/living/summoner = holder.owner.current
		var/turf/summoner_turf = get_turf(summoner)
		info["escaped"] = holder.owner.force_escaped || summoner_turf.onCentCom() || summoner_turf.onSyndieBase()
		if(summoner.stat != DEAD)
			info["stat"] = "alive"
			info["crit"] = summoner.InCritical()
	SSblackbox.record_feedback("associative", "holoparasite_user_roundend_stat", 1, info)
	SSblackbox.record_feedback("tally", "holoparasites_per_summoner", 1, length(members))

/datum/objective/holoparasite
	name = "protect holoparasite summoner"
	explanation_text = "Protect and serve your summoner."

/datum/objective/holoparasite/New(datum/mind/summoner, datum/team/holoparasites/holopara_team)
	if(!summoner)
		CRASH("Attempted to create holoparasite objective without summoner!")
	if(!holopara_team)
		CRASH("Attempted to create holoparasite objective without team!")
	target = summoner
	team = holopara_team
	update_explanation_text()

/datum/objective/holoparasite/update_explanation_text()
	explanation_text = "Protect and serve [target.name], your summoner."

/datum/objective/holoparasite/check_completion()
	return considered_alive(target, enforce_human = FALSE)
