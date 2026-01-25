//Both ERT and DS are handled by the same datums since they mostly differ in equipment in objective.
/datum/team/ert
	name = "Emergency Response Team"
	var/datum/objective/mission //main mission
	var/ert_frequency

/datum/team/ert/New(starting_members)
	. = ..()
	ert_frequency = get_free_team_frequency("cent")

/datum/antagonist/ert
	name = "Emergency Response Officer"
	var/datum/team/ert/ert_team
	var/leader = FALSE
	var/datum/outfit/outfit = /datum/outfit/centcom/ert/security
	var/datum/outfit/plasmaman_outfit = /datum/outfit/plasmaman/ert
	var/role = JOB_NAME_SECURITYOFFICER
	var/list/name_source
	var/random_names = TRUE
	can_elimination_hijack = ELIMINATION_PREVENT
	show_in_antagpanel = FALSE
	show_to_ghosts = TRUE
	antag_moodlet = /datum/mood_event/focused
	banning_key = ROLE_ERT
	required_living_playtime = 2

/datum/antagonist/ert/get_team()
	return ert_team

/datum/antagonist/ert/create_team(datum/team/ert/new_team)
	if(istype(new_team))
		ert_team = new_team

/datum/antagonist/ert/on_gain()
	if(random_names)
		update_name()
	forge_objectives()
	equipERT()
	owner.store_memory("Your team's shared tracking beacon frequency is [ert_team.ert_frequency].")
	. = ..()

/datum/antagonist/ert/greet()
	if(!ert_team)
		return

	to_chat(owner, "<B><font size=3 color=red>You are the [name].</font></B>")

	var/missiondesc = "Your squad is being sent on a mission to [station_name()] by Nanotrasen's Security Division."
	if(leader) //If Squad Leader
		missiondesc += " Lead your squad to ensure the completion of the mission. Board the shuttle when your team is ready."
	else
		missiondesc += " Follow orders given to you by your squad leader."

		missiondesc += " Avoid civilian casualties when possible."

	missiondesc += "<BR><B>Your Mission</B>: [ert_team.mission.explanation_text]"
	missiondesc += "<BR><b>Your Shared Tracking Frequency</b>: <i>[ert_team.ert_frequency]</i>"

	to_chat(owner, missiondesc)

/datum/antagonist/ert/proc/update_name()
	var/name = pick(name_source)
	if (!name)
		name = owner.current.client?.prefs.read_character_preference(/datum/preference/name/backup_human) || pick(GLOB.last_names)
	owner.current.fully_replace_character_name(owner.current.real_name, "[role] [name]")

/datum/antagonist/ert/proc/forge_objectives()
	if(ert_team)
		objectives |= ert_team.objectives

/datum/antagonist/ert/proc/equipERT()
	var/mob/living/carbon/human/H = owner.current
	if(!istype(H))
		return
	if(isplasmaman(H))
		H.equipOutfit(plasmaman_outfit)
		H.open_internals(H.get_item_for_held_index(2))
	H.equipOutfit(outfit)
	//Set the mod frequency
	var/obj/item/mod = H.get_item_by_slot(ITEM_SLOT_BACK)
	if(mod)
		var/datum/component/tracking_beacon/beacon = mod.GetComponent(/datum/component/tracking_beacon)
		if(beacon)
			beacon.set_frequency(ert_team.ert_frequency)

// The actual datums, i tried to sort it

// OFFICIAL
/datum/antagonist/ert/official
	name = JOB_CENTCOM_OFFICIAL
	show_name_in_check_antagonists = TRUE
	show_in_antagpanel = FALSE
	can_elimination_hijack = ELIMINATION_PREVENT
	var/datum/objective/mission
	show_to_ghosts = TRUE
	banning_key = ROLE_ERT
	random_names = FALSE
	outfit = /datum/outfit/centcom/centcom_official

/datum/antagonist/ert/official/greet()
	to_chat(owner, "<B><font size=20 color=red>You are a CentCom Official.</font></B>")
	if (ert_team)
		to_chat(owner, "Central Command is sending you to [station_name()] with the task: [ert_team.mission.explanation_text]")
	else
		to_chat(owner, "Central Command is sending you to [station_name()] with the task: [mission.explanation_text]")

/datum/antagonist/ert/official/forge_objectives()
	if (ert_team)
		return ..()
	if(mission)
		return
	var/datum/objective/missionobj = new ()
	missionobj.owner = owner
	missionobj.explanation_text = "Conduct a routine performance review of [station_name()] and its Captain."
	missionobj.completed = TRUE
	mission = missionobj
	objectives |= mission

// ERT TEAM

// GENERALIST:
// Commander
/datum/antagonist/ert/commander/blue
	role = JOB_ERT_COMMANDER
	outfit = /datum/outfit/centcom/ert/commander

/datum/antagonist/ert/commander/amber
	role = JOB_ERT_COMMANDER
	outfit = /datum/outfit/centcom/ert/commander/amber

/datum/antagonist/ert/commander/red
	role = JOB_ERT_COMMANDER
	outfit = /datum/outfit/centcom/ert/commander/amber/red

/datum/antagonist/ert/commander/inquisition
	role = JOB_ERT_COMMANDER
	outfit = /datum/outfit/centcom/ert/commander/inquisitor

/datum/antagonist/ert/commander/inquisition/on_gain()
	. = ..()
	owner.holy_role = HOLY_ROLE_PRIEST

// Security
/datum/antagonist/ert/security/blue
	role = JOB_ERT_OFFICER
	outfit = /datum/outfit/centcom/ert/security

/datum/antagonist/ert/security/amber
	role = JOB_ERT_OFFICER
	outfit = /datum/outfit/centcom/ert/security/amber

/datum/antagonist/ert/security/red
	role = JOB_ERT_OFFICER
	outfit = /datum/outfit/centcom/ert/security/amber/red

/datum/antagonist/ert/security/inquisition
	role = JOB_ERT_OFFICER
	outfit = /datum/outfit/centcom/ert/security/inquisitor

/datum/antagonist/ert/security/inquisition/on_gain()
	. = ..()
	owner.holy_role = HOLY_ROLE_PRIEST

// Engineers
/datum/antagonist/ert/engineer/blue
	role = JOB_ERT_ENGINEER
	outfit = /datum/outfit/centcom/ert/engineer

/datum/antagonist/ert/engineer/amber
	role = JOB_ERT_ENGINEER
	outfit = /datum/outfit/centcom/ert/engineer/amber

/datum/antagonist/ert/engineer/red
	role = JOB_ERT_ENGINEER
	outfit = /datum/outfit/centcom/ert/engineer/amber/red

/datum/antagonist/ert/engineer/inquisition
	role = JOB_ERT_ENGINEER
	outfit = /datum/outfit/centcom/ert/engineer/inquisitor

/datum/antagonist/ert/engineer/inquisition/on_gain()
	. = ..()
	owner.holy_role = HOLY_ROLE_PRIEST

// Medics
/datum/antagonist/ert/medic/blue
	role = JOB_ERT_MEDICAL_DOCTOR
	outfit = /datum/outfit/centcom/ert/medic

/datum/antagonist/ert/medic/amber
	role = JOB_ERT_MEDICAL_DOCTOR
	outfit = /datum/outfit/centcom/ert/medic/amber

/datum/antagonist/ert/medic/red
	role = JOB_ERT_MEDICAL_DOCTOR
	outfit = /datum/outfit/centcom/ert/medic/amber/red

/datum/antagonist/ert/medic/inquisition
	role = JOB_ERT_MEDICAL_DOCTOR
	outfit = /datum/outfit/centcom/ert/medic/inquisitor

/datum/antagonist/ert/medic/inquisition/on_gain()
	. = ..()
	owner.holy_role = HOLY_ROLE_PRIEST

// Deathsquad
/datum/antagonist/ert/deathsquad
	name = "Death Commando"
	outfit = /datum/outfit/centcom/ert/death_commando
	role = "Commando"
	plasmaman_outfit = /datum/outfit/plasmaman/death_commando

/datum/antagonist/ert/deathsquad/officer
	name = "Deathsquad Officer"
	outfit = /datum/outfit/centcom/ert/death_commando/officer
	role = "Officer"

/datum/antagonist/ert/deathsquad/New()
	. = ..()
	name_source = GLOB.commando_names

/datum/antagonist/ert/deathsquad/apply_innate_effects(mob/living/mob_override)
	ADD_TRAIT(owner, TRAIT_DISK_VERIFIER, DEATHSQUAD_TRAIT)

/datum/antagonist/ert/deathsquad/remove_innate_effects(mob/living/mob_override)
	REMOVE_TRAIT(owner, TRAIT_DISK_VERIFIER, DEATHSQUAD_TRAIT)

/datum/antagonist/ert/deathsquad/greet()
	if(!ert_team)
		return

	to_chat(owner, "<B><font size=3 color=red>You are the [name].</font></B>")

	var/missiondesc = "Your squad is being sent on a mission to [station_name()] by Nanotrasen's Security Division."
	if(leader) //If Squad Leader
		missiondesc += " Lead your squad to ensure the completion of the mission. Board the shuttle when your team is ready."
	else
		missiondesc += " Follow orders given to you by your squad leader."

	missiondesc += "<BR><B>Your Mission</B> : [ert_team.mission.explanation_text]"
	to_chat(owner,missiondesc)

//SPECIALISTS:
/datum/antagonist/ert/janitor
	role = JOB_NAME_JANITOR
	outfit = /datum/outfit/centcom/ert/janitor

/datum/antagonist/ert/janitor/heavy
	role = "Heavy Duty Janitor"
	outfit = /datum/outfit/centcom/ert/janitor/heavy

/datum/antagonist/ert/janitor/kudzu
	role = "Flora Exterminator"
	outfit = /datum/outfit/centcom/ert/janitor/kudzu

// NON ERT
/datum/antagonist/ert/intern
	name = "CentCom Intern"
	outfit = /datum/outfit/centcom/centcom_intern
	random_names = FALSE
	role = "Intern"
	plasmaman_outfit = /datum/outfit/plasmaman/intern

/datum/antagonist/ert/intern/leader
	name = "CentCom Head Intern"
	outfit = /datum/outfit/centcom/centcom_intern/leader
	random_names = FALSE
	role = "Head Intern"

/datum/antagonist/ert/intern/unarmed
	outfit = /datum/outfit/centcom/centcom_intern/unarmed

/datum/antagonist/ert/intern/leader/unarmed
	outfit = /datum/outfit/centcom/centcom_intern/leader/unarmed

/datum/antagonist/ert/lawyer
	name = "CentCom Attorney"
	outfit = /datum/outfit/centcom/centcom_attorney
	role = "Attorney"
	plasmaman_outfit = /datum/outfit/plasmaman/centcom_attorney

/datum/antagonist/ert/clown
	name = "Comedy Response Officer"
	outfit = /datum/outfit/centcom/centcom_clown
	role = "Prankster"
	plasmaman_outfit = /datum/outfit/plasmaman/honk

/datum/antagonist/ert/clown/New()
	. = ..()
	name_source = GLOB.clown_names

/datum/antagonist/ert/clown/greet()
	if(!ert_team)
		return

	to_chat(owner, "<B><font size=3 color=red>You are the [name].</font></B>")

	var/missiondesc = "Your squad is being sent on a mission to [station_name()] by Nanotrasen's Comedy Division."
	if(leader) //If Squad Leader
		missiondesc += " You are the worst clown here. As such, you were able to stop slipping the admiral for long enough to be given command. Good luck, honk!"
	else
		missiondesc += " Follow orders given to you by your squad leader, or ignore them if it's funnier."

		missiondesc += " Slip as many civilians as possible."

	missiondesc += "<BR><B>Your Mission</B> : [ert_team.mission.explanation_text]"
	to_chat(owner,missiondesc)

//////////////////////////////////////////
/////////////// BOUNTY HUNTERS ///////////
//////////////////////////////////////////

/datum/antagonist/ert/bounty
	outfit = /datum/outfit/bounty

/datum/antagonist/ert/bounty/operative
	outfit = /datum/outfit/bounty/operative

/datum/antagonist/ert/bounty/gunner
	outfit = /datum/outfit/bounty/gunner

/datum/antagonist/ert/bounty/technician
	outfit = /datum/outfit/bounty/technician

/datum/antagonist/ert/bounty/greet()
	if(!ert_team)
		return

	to_chat(owner, "<B><font size=3 color=red>You are the [name].</font></B>")

	var/missiondesc = "Your services are required for a mission on [station_name()] by Nanotrasen's Central Command."
	if(leader) //If Squad Leader
		missiondesc += " You are the most experienced hunter here. As such, you are expected to take point in this rag-tag group of misfits."
	else
		missiondesc += " Follow orders given by your leader, or betray them to avoid having to split the payout."

	missiondesc += "<BR><B>Your Contract</B> : [ert_team.mission.explanation_text]"
	to_chat(owner,missiondesc)
