/datum/antagonist/official
	name = "CentCom Official"
	show_name_in_check_antagonists = TRUE
	show_in_antagpanel = FALSE
	can_elimination_hijack = ELIMINATION_PREVENT
	var/datum/objective/mission
	var/datum/team/ert/ert_team
	show_to_ghosts = TRUE

/datum/antagonist/official/greet()
	to_chat(owner, "<B><font size=3 color=red>You are a CentCom Official.</font></B>")
	if (ert_team)
		to_chat(owner, "Central Command is sending you to [station_name()] with the task: [ert_team.mission.explanation_text]")
	else
		to_chat(owner, "Central Command is sending you to [station_name()] with the task: [mission.explanation_text]")

/datum/antagonist/official/proc/equip_official()
	var/mob/living/carbon/human/H = owner.current
	if(!istype(H))
		return
	if(isplasmaman(H))
		H.equipOutfit(/datum/outfit/plasmaman/official)
		H.internal = H.get_item_for_held_index(2)
		H.update_internals_hud_icon(1)
	H.equipOutfit(/datum/outfit/centcom_official)
	if(CONFIG_GET(flag/enforce_human_authority))
		H.set_species(/datum/species/human)

/datum/antagonist/official/create_team(datum/team/new_team)
	if(istype(new_team))
		ert_team = new_team

/datum/antagonist/official/proc/forge_objectives()
	if (ert_team)
		objectives |= ert_team.objectives
	else if (!mission)
		var/datum/objective/missionobj = new
		missionobj.owner = owner
		missionobj.explanation_text = "Conduct a routine performance review of [station_name()] and its Captain."
		missionobj.completed = 1
		mission = missionobj
		objectives |= mission


/datum/antagonist/official/on_gain()
	forge_objectives()
	. = ..()
	equip_official()
