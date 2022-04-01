/datum/team/metagangers
	name = "Metagangers"

/datum/antagonist/metaganger
	name = "Metaganger"
	job_rank = ROLE_LAVALAND
	show_in_antagpanel = FALSE
	show_to_ghosts = TRUE
	prevent_roundtype_conversion = FALSE
	antagpanel_category = "Metagangers"
	delay_roundend = FALSE
	var/datum/team/metagangers/ashie_team

/datum/antagonist/metaganger/create_team(datum/team/team)
	if(team)
		ashie_team = team
		objectives |= ashie_team.objectives
	else
		ashie_team = new
		ashie_team.objectives += new /datum/objective/piggyback

/datum/antagonist/metaganger/get_team()
	return ashie_team

/datum/antagonist/metaganger/on_gain()
	. = ..()
	var/obj/item/implant/radio/syndicate/selfdestruct/metagang/syndio = new
	syndio.implant(owner.current)
	to_chat(owner, "<span class='userdanger'>You are the Metaganger!</span>")

/datum/objective/piggyback
	name = "piggyback"
	explanation_text = "At the end of the round, be piggybacking someone or on someone's back."
	team_explanation_text = "At the end of the round, be piggybacking someone or on someone's back."

/datum/objective/escape/check_completion()
	if(istype(owner.current.buckled, /mob/living/carbon/human))
		return TRUE
	return FALSE
