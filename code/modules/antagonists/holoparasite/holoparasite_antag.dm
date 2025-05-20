/**
 * The holoparasite antagonist datum.
 * This allows holoparasites to show up on the round-end report and orbit menu,
 * in addition to providing them with their info UI.
 */
/datum/antagonist/holoparasite
	name = "Holoparasite"
	show_in_antagpanel = FALSE
	show_to_ghosts = TRUE
	ui_name = "AntagInfoHoloparasite"
	banning_key = ROLE_HOLOPARASITE
	required_living_playtime = 4
	var/datum/team/holoparasites/team
	var/datum/holoparasite_holder/holder
	var/datum/holoparasite_stats/stats
	var/datum/holoparasite_theme/theme

/datum/antagonist/holoparasite/New(datum/holoparasite_holder/_holder, datum/holoparasite_stats/_stats, datum/holoparasite_theme/_theme)
	..()
	holder = _holder
	stats = _stats
	theme = _theme

/datum/antagonist/holoparasite/on_gain()
	if(!holder || !istype(holder))
		CRASH("Invalid holoparasite holder passed to [type]")
	if(!stats || !istype(stats))
		CRASH("Invalid holoparasite stats passed to [type]")
	if(!theme)
		CRASH("Invalid holoparasite theme passed to [type]")
	theme = get_holoparasite_theme(theme)
	create_team()
	. = ..()
	team.add_member(owner)

/datum/antagonist/holoparasite/greet()
	. = ..()
	owner.current.client?.tgui_panel?.give_antagonist_popup(theme.name,
		"Protect your summoner and follow [holder.owner.current.p_their()] commands. Your existence is bound to their life, and you will die if [holder.owner.current.p_they()] die[holder.owner.current.p_s()].")

/datum/antagonist/holoparasite/can_be_owned(datum/mind/new_owner)
	. = ..()
	if(.)
		var/datum/mind/tested = new_owner || owner
		return istype(tested?.current, /mob/living/simple_animal/hostile/holoparasite)

/datum/antagonist/holoparasite/antag_panel_data()
	return "<b>Summoner</b>: [key_name(holder.owner)]<br>[stats.tldr()]"

/datum/antagonist/holoparasite/get_antag_name()
	return "[theme.name] of [holder.owner.name]"

/datum/antagonist/holoparasite/get_team()
	return team

/datum/antagonist/holoparasite/create_team(datum/team/holoparasites/new_team)
	if(new_team)
		if(!istype(new_team))
			stack_trace("Wrong team type passed to [type] initialization.")
		team = new_team
	else if(holder)
		team = holder.get_holoparasite_team()

/datum/antagonist/holoparasite/ui_data(mob/user)
	var/mob/living/simple_animal/hostile/holoparasite/holopara = owner.current
	if(!istype(holopara))
		CRASH("A non-holoparasite ([owner.current.type]) has a /datum/antagonist/holoparasite. What??")
	. = list(
		"summoner" = list(
			"name" = holder.owner.name
		),
		"stats" = list(
			"damage" = holopara.stats.damage,
			"defense" = holopara.stats.defense,
			"speed" = holopara.stats.speed,
			"potential" = holopara.stats.potential,
			"range" = holopara.stats.range
		)
	)
	if(length(holopara.notes))
		.["notes"] = holopara.notes
	if(length(holopara.battlecry))
		.["battlecry"] = holopara.battlecry
	var/objective_count = 1
	var/list/objectives
	var/list/antag_info
	for(var/datum/objective/objective as() in holder.owner.get_all_antag_objectives())
		var/objective_info = list(
			"count" = objective_count,
			"name" = objective.name,
			"explanation" = objective.explanation_text
		)
		LAZYADD(objectives, list(objective_info))
		objective_count++
	if(LAZYLEN(objectives))
		LAZYSET(antag_info, "objectives", objectives)
	var/list/extra_info
	if(length(holder.owner.special_role))
		.["summoner"]["special_role"] = holder.owner.special_role
	var/list/allies
	for(var/datum/antagonist/summoner_antag in holder.owner.antag_datums)
		if(istype(summoner_antag, /datum/antagonist/traitor))
			var/datum/antagonist/traitor/summoner_traitor = summoner_antag
			if(summoner_traitor.has_codewords)
				LAZYSET(extra_info, "Code Phrases", jointext(GLOB.syndicate_code_phrase, ", "))
				extra_info["Code Responses"] = jointext(GLOB.syndicate_code_response, ", ")
		var/datum/team/summoner_team = summoner_antag.get_team()
		if(summoner_team)
			var/list/team_info
			var/team_name = summoner_team.get_team_name()
			for(var/datum/mind/team_member in summoner_team.members)
				// Skip over our summoner and any of their holoparasites (including ourselves)
				if(team_member == holder.owner || (team_member in team.members))
					continue
				LAZYOR(team_info, team_member.name)
			if(LAZYLEN(team_info))
				LAZYSET(allies, team_name, team_info)
	if(LAZYLEN(allies))
		LAZYSET(antag_info, "allies", allies)
	if(LAZYLEN(extra_info))
		LAZYSET(antag_info, "extra_info", extra_info)
	if(LAZYLEN(antag_info))
		.["summoner"]["antag_info"] = antag_info

/datum/antagonist/holoparasite/ui_static_data(mob/user)
	var/mob/living/simple_animal/hostile/holoparasite/holopara = owner.current
	if(!istype(holopara))
		CRASH("A non-holoparasite ([owner.current.type]) has a /datum/antagonist/holoparasite. What??")
	. = list(
		"name" = holopara.real_name,
		"themed_name" = theme.name,
		"accent_color" = holopara.accent_color,
		"abilities" = list(
			"weapon" = stats.weapon.ability_ui_data()
		)
	)
	if(stats.ability)
		.["abilities"]["major"] = stats.ability.ability_ui_data()
	var/list/lesser_abilities
	for(var/datum/holoparasite_ability/lesser/lesser_ability in stats.lesser_abilities)
		LAZYADD(lesser_abilities, list(lesser_ability.ability_ui_data()))
	if(LAZYLEN(lesser_abilities))
		.["abilities"]["lesser"] = lesser_abilities

/datum/antagonist/holoparasite/apply_innate_effects()
	. = ..()
	RegisterSignal(owner, COMSIG_HOLOPARA_SET_SUMMONER, PROC_REF(on_set_summoner))
	RegisterSignals(owner, list(COMSIG_HOLOPARA_SET_ACCENT_COLOR, COMSIG_HOLOPARA_SET_THEME), PROC_REF(do_update_static_data))
	RegisterSignals(stats, list(COMSIG_HOLOPARA_STATS_SET_MAJOR_ABILITY, COMSIG_HOLOPARA_STATS_ADD_LESSER_ABILITY, COMSIG_HOLOPARA_STATS_TAKE_LESSER_ABILITY, COMSIG_HOLOPARA_STATS_SET_WEAPON), PROC_REF(do_update_static_data))

/datum/antagonist/holoparasite/remove_innate_effects()
	. = ..()
	UnregisterSignal(owner, list(COMSIG_HOLOPARA_SET_SUMMONER, COMSIG_HOLOPARA_SET_ACCENT_COLOR, COMSIG_HOLOPARA_SET_THEME))
	UnregisterSignal(stats, list(COMSIG_HOLOPARA_STATS_SET_MAJOR_ABILITY, COMSIG_HOLOPARA_STATS_ADD_LESSER_ABILITY, COMSIG_HOLOPARA_STATS_TAKE_LESSER_ABILITY, COMSIG_HOLOPARA_STATS_SET_WEAPON))

/datum/antagonist/holoparasite/hijack_speed()
	. = ..()
	for(var/datum/antagonist/summoner_antag in holder.owner.antag_datums)
		. = max(., summoner_antag.hijack_speed())

/datum/antagonist/holoparasite/make_info_button()
	return // Holoparasite HUD has its own info button

/datum/antagonist/holoparasite/admin_add(datum/mind/new_owner, mob/admin)
	to_chat(admin, span_dangerbold("No. You're going to break things horribly (or if you're needing to do this for some reason - things have probably <i>already</i> broken horribly!)"))

/**
 * Change our stored summoner and updates static data when the holoparasite's summoner is changed.
 */
/datum/antagonist/holoparasite/proc/on_set_summoner(datum/_source, datum/mind/old_summoner, datum/mind/new_summoner)
	SIGNAL_HANDLER
	if(old_summoner)
		var/datum/holoparasite_holder/old_holder = old_summoner.holoparasite_holder
		old_holder?.remove_holoparasite(owner.current)
		team?.remove_member(owner)
	if(new_summoner)
		holder = new_summoner.holoparasite_holder()
		team = holder.get_holoparasite_team()
		holder.add_holoparasite(owner.current)
		team.add_member(owner)
	update_static_data(owner.current)

/**
 * Updates static data, to be called by signals.
 */
/datum/antagonist/holoparasite/proc/do_update_static_data()
	SIGNAL_HANDLER
	update_static_data(owner.current)
