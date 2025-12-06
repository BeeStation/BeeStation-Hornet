/datum/team/spiders
	name = "Spiders"
	var/mob/master = null
	var/directive = null
	// Team huds
	var/static/list/team_huds = list()
	var/static/list/possible_colors = list("#db00db", "#7e007e", "#d80000", "#6200ff")

// Sets up our antag hud if we have a specific master
/datum/team/spiders/New(starting_members, mob/spider_master)
	. = ..()
	master = spider_master
	if(spider_master)
		RegisterSignal(spider_master, COMSIG_QDELETING, PROC_REF(handle_master_qdel))
		if(length(possible_colors))
			team_huds[spider_master] = pick_n_take(possible_colors)

// Alerts spiders in the event of a directive change. This shouldn't happen that often.
/datum/team/spiders/proc/update_directives(new_directive)
	if(!new_directive)
		return
	directive = new_directive
	var/list/datum/antagonist/spider/spiders = get_team_antags()
	for(var/datum/antagonist/spider/spider in spiders)
		to_chat(spider.owner, span_spiderlarge("Your directives have been updated!"))
		to_chat(spider.owner, span_spiderlarge("New directive: [directive]"))
		spider.owner.store_memory("<b>Directive: [directive]</b>")
		spider.update_static_data(spider.owner?.current)

/datum/team/spiders/proc/handle_master_qdel()
	SIGNAL_HANDLER
	master = null

// Spiders are listed on the roundend report, along with their master and directives if applicable
/datum/team/spiders/roundend_report()
	var/list/parts = list()
	if(master)
		parts += span_header("[master]'s [name] were:")
	else
		parts += span_header("The [name] were:")
	parts += printplayerlist(members)
	parts += "Their directive was: [directive]"
	return "<div class='panel redborder'>[parts.Join("<br>")]</div>"

/datum/antagonist/spider
	name = "Spider"
	banning_key = ROLE_SPIDER
	show_in_antagpanel = FALSE
	prevent_roundtype_conversion = FALSE
	show_to_ghosts = TRUE
	ui_name = "AntagInfoSpider"
	required_living_playtime = 0
	var/datum/team/spiders/spider_team

/datum/antagonist/spider/create_team(datum/team/spiders/new_team)
	if(!new_team)
		for(var/datum/antagonist/spider/spooder in GLOB.antagonists)
			if(!spooder.owner || !spooder.spider_team)
				continue
			spider_team = spooder.spider_team //if we can find any existing team, use that one
			return
		spider_team = new //otherwise we make a new team
	else
		if(!istype(new_team))
			CRASH("Wrong spider team type provided to create_team")
		spider_team = new_team
	update_static_data(owner?.current)

/datum/antagonist/spider/proc/set_spider_team(datum/team/spiders/new_team)
	var/datum/team/spiders/old_team = spider_team
	spider_team = new_team
	spider_team.add_member(owner)
	old_team.remove_member(owner)

	// Alert our spider to its directives
	if(spider_team.directive)
		to_chat(owner, span_spiderlarge("You were left a directive! Follow it at all costs."))
		to_chat(owner, span_spiderlarge("<b>[spider_team.directive]</b>"))
		owner.store_memory("<b>Directive: [spider_team.directive]</b>")
	else
		to_chat(owner, span_spider("You do not have a directive. You'll need to set one before laying eggs."))
	if(spider_team.master)
		to_chat(owner, span_spider("Your master is: [spider_team.master]. Follow their orders when they do not conflict with your directives."))
		owner.store_memory("<b>Your master is: [spider_team.master]</b>")

	if(!length(old_team.get_team_antags()))
		qdel(old_team)
	update_static_data(owner?.current)

/datum/antagonist/spider/ui_static_data(mob/user)
	return list(
		"directive" = spider_team.directive,
		"master" = spider_team.master ? (spider_team.master.mind?.name || spider_team.master.real_name || spider_team.master.name) : null,
		"color" = spider_team.master ? (spider_team.team_huds[spider_team.master] || "purple") : "purple",
		"type" = initial(owner.current.name)
	)

/datum/antagonist/spider/get_team()
	return spider_team

// Handles spider icons for teams.
/datum/antagonist/spider/proc/update_spider_icons_added(mob/living/M)
	var/datum/atom_hud/antag/spider/spiderhud = GLOB.huds[ANTAG_HUD_SPIDER]
	spiderhud.join_hud(M)
	set_antag_hud(M, "spider")
	var/image/holder = M.hud_list[ANTAG_HUD]
	if(spider_team.team_huds[spider_team.master])
		holder.color = spider_team.team_huds[spider_team.master]

/datum/antagonist/spider/proc/update_spider_icons_removed(mob/living/M)
	var/datum/atom_hud/antag/spiderhud = GLOB.huds[ANTAG_HUD_SPIDER]
	spiderhud.leave_hud(M)
	set_antag_hud(M, null)

/datum/antagonist/spider/apply_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	update_spider_icons_added(M)

/datum/antagonist/spider/remove_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	update_spider_icons_removed(M)

/datum/atom_hud/antag/spider
	icon_color = "#4d004d"

// Handles spider greetings. Directives are handled in set_team.
/datum/antagonist/spider/greet()
	to_chat(owner, span_notice("You are a spider!"))
	owner.current.client?.tgui_panel?.give_antagonist_popup("Spider",
		"Follow your assigned directives and expand your brood.")
