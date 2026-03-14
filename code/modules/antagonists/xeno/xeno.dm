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
	antagpanel_category = ANTAG_GROUP_XENOS
	prevent_roundtype_conversion = FALSE
	show_to_ghosts = TRUE
	// TODO: ui_name = "AntagInfoXeno"
	required_living_playtime = 4
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
	. = ..()
	//Give traitor appearance on hud (If they are not an antag already)
	var/datum/atom_hud/antag/traitorhud = GLOB.huds[ANTAG_HUD_XENOMORPH]
	traitorhud.join_hud(owner.current)
	if(!owner.antag_hud_icon_state)
		set_antag_hud(owner.current, "xenomorph")

/datum/antagonist/xeno/remove_innate_effects(mob/living/mob_override)
	. = ..()
	//Clear the hud if they haven't become something else and had the hud overwritten
	var/datum/atom_hud/antag/traitorhud = GLOB.huds[ANTAG_HUD_XENOMORPH]
	traitorhud.leave_hud(owner.current)
	if(owner.antag_hud_icon_state == "xenomorph")
		set_antag_hud(owner.current, null)

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
