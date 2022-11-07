/datum/team/spiders
	name = "Spiders"
	var/mob/master = null
	var/directive = null

//Simply lists them.
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

/datum/antagonist/spider/create_team(datum/team/spiders/new_team)
	if(!new_team)
		spider_team = new
	else
		if(!istype(new_team))
			CRASH("Wrong spider team type provided to create_team")
		spider_team = new_team

/datum/antagonist/spider/get_team()
	return spider_team
