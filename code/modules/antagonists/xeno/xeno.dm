/datum/team/xeno
	name = "Xenomorphs"

//Simply lists them.
/datum/team/xeno/roundend_report()
	var/list/parts = list()
	var/success = SSshuttle.emergency.is_hijacked_by_xenos()
	parts += span_header("The [name] [success ? "have [span_greentext("succeeded!")]" : "have [span_redtext("failed!")]"]\n")
	parts += "<b>[success ? "The Queen has left the station alive and the colony will continue to spread!" : "The remnants of the colony will wither in isolation"]</b>"
	parts += "The [name] were:"
	parts += printplayerlist(members)
	return "<div class='panel redborder'>[parts.Join("<br>")]</div>"

/datum/antagonist/xeno
	name = "Xenomorph"
	banning_key = ROLE_ALIEN
	show_in_antagpanel = FALSE
	show_to_ghosts = TRUE
	// TODO: ui_name = "AntagInfoXeno"
	required_living_playtime = 4
	antag_hud_name = "xenomorph"
	var/datum/team/xeno/xeno_team

/datum/antagonist/xeno/create_team(datum/team/xeno/new_team)
	if(!new_team)
		for(var/datum/antagonist/xeno/X in GLOB.antagonists)
			if(!X.owner || !X.xeno_team)
				continue
			xeno_team = X.xeno_team
			return
		xeno_team = new
	else
		if(!istype(new_team))
			CRASH("Wrong xeno team type provided to create_team")
		xeno_team = new_team

/datum/antagonist/xeno/get_team()
	return xeno_team

/datum/antagonist/xeno/apply_innate_effects(mob/living/mob_override)
	add_team_hud(mob_override || owner.current)

//XENO
/mob/living/carbon/alien/mind_initialize()
	..()
	if(!mind.has_antag_datum(/datum/antagonist/xeno))
		mind.add_antag_datum(/datum/antagonist/xeno)

/mob/living/carbon/alien/on_wabbajacked(mob/living/new_mob)
	. = ..()
	if(!mind)
		return
	if(isalien(new_mob))
		return
	mind.remove_antag_datum(/datum/antagonist/xeno)
	mind.special_role = null
