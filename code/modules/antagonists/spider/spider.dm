/datum/team/spiders
	name = "Spiders"
	var/mob/master = null
	var/directive = null
	// Team huds
	var/static/list/team_huds = list()
	var/static/list/possible_colors = list("#db00db", "#7e007e", "#d80000", "#6200ff")

// Sets up our antag hud if we have a specific master
/datum/team/spiders/proc/Initialize(spider_master)
	master = spider_master
	if(spider_master && length(possible_colors))
		team_huds[spider_master] = pick_n_take(possible_colors)

// Spiders are listed on the roundend report, along with their master and directives if applicable
/datum/team/spiders/roundend_report()
	var/list/parts = list()
	if(master)
		parts += "<span class='header'>[master]'s [name] were:</span>"
	else
		parts += "<span class='header'>The [name] were:</span>"
	parts += printplayerlist(members)
	parts += "Their directive was: [directive]"
	return "<div class='panel redborder'>[parts.Join("<br>")]</div>"

/datum/antagonist/spider
	name = "Spider"
	job_rank = ROLE_SPIDER
	show_in_antagpanel = FALSE
	prevent_roundtype_conversion = FALSE
	show_to_ghosts = TRUE
	var/datum/team/spiders/spider_team

// Team handling, for when we have a bunch of different spiders with different directives.
/datum/antagonist/spider/create_team(datum/team/spiders/new_team)
	if(!new_team)
		spider_team = new()
	else
		if(!istype(new_team))
			CRASH("Wrong spider team type provided to create_team")
		spider_team = new_team

/datum/antagonist/spider/get_team()
	return spider_team

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
