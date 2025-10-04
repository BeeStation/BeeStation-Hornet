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

/datum/antagonist/ert/on_gain()
	if(random_names)
		update_name()
	forge_objectives()
	equipERT()
	owner.store_memory("Your team's shared tracking beacon frequency is [ert_team.ert_frequency].")
	. = ..()

/datum/antagonist/ert/get_team()
	return ert_team

/datum/antagonist/ert/proc/update_name()
	var/name = pick(name_source)
	if (!name)
		name = owner.current.client?.prefs.read_character_preference(/datum/preference/name/backup_human) || pick(GLOB.last_names)
	owner.current.fully_replace_character_name(owner.current.real_name, "[role] [name]")

/datum/antagonist/ert/deathsquad/New()
	. = ..()
	name_source = GLOB.commando_names

/datum/antagonist/ert/clown/New()
	. = ..()
	name_source = GLOB.clown_names

/datum/antagonist/ert/deathsquad/apply_innate_effects(mob/living/mob_override)
	ADD_TRAIT(owner, TRAIT_DISK_VERIFIER, DEATHSQUAD_TRAIT)

/datum/antagonist/ert/deathsquad/remove_innate_effects(mob/living/mob_override)
	REMOVE_TRAIT(owner, TRAIT_DISK_VERIFIER, DEATHSQUAD_TRAIT)

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
	to_chat(owner, "<B><font size=3 color=red>You are a CentCom Official.</font></B>")
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

/datum/antagonist/ert/security // kinda handled by the base template but here for completion

/datum/antagonist/ert/security/red
	outfit = /datum/outfit/centcom/ert/security/alert

/datum/antagonist/ert/engineer
	role = "Engineer"
	outfit = /datum/outfit/centcom/ert/engineer

/datum/antagonist/ert/engineer/red
	outfit = /datum/outfit/centcom/ert/engineer/alert

/datum/antagonist/ert/medic
	role = JOB_CENTCOM_MEDICAL_DOCTOR
	outfit = /datum/outfit/centcom/ert/medic

/datum/antagonist/ert/medic/red
	outfit = /datum/outfit/centcom/ert/medic/alert

/datum/antagonist/ert/commander
	role = "Commander"
	outfit = /datum/outfit/centcom/ert/commander

/datum/antagonist/ert/commander/red
	outfit = /datum/outfit/centcom/ert/commander/alert

/datum/antagonist/ert/deathsquad
	name = "Deathsquad Trooper"
	outfit = /datum/outfit/centcom/death_commando
	role = "Trooper"
	plasmaman_outfit = /datum/outfit/plasmaman/death_commando

/datum/antagonist/ert/medic/inquisitor
	outfit = /datum/outfit/centcom/ert/medic/inquisitor

/datum/antagonist/ert/medic/inquisitor/on_gain()
	. = ..()
	owner.holy_role = HOLY_ROLE_PRIEST

/datum/antagonist/ert/security/inquisitor
	outfit = /datum/outfit/centcom/ert/security/inquisitor

/datum/antagonist/ert/security/inquisitor/on_gain()
	. = ..()
	owner.holy_role = HOLY_ROLE_PRIEST

/datum/antagonist/ert/chaplain
	role = JOB_NAME_CHAPLAIN
	outfit = /datum/outfit/centcom/ert/chaplain

/datum/antagonist/ert/chaplain/inquisitor
	outfit = /datum/outfit/centcom/ert/chaplain/inquisitor

/datum/antagonist/ert/chaplain/on_gain()
	. = ..()
	owner.holy_role = HOLY_ROLE_PRIEST

/datum/antagonist/ert/commander/inquisitor
	outfit = /datum/outfit/centcom/ert/commander/inquisitor

/datum/antagonist/ert/commander/inquisitor/on_gain()
	. = ..()
	owner.holy_role = HOLY_ROLE_PRIEST

/datum/antagonist/ert/janitor
	role = JOB_NAME_JANITOR
	outfit = /datum/outfit/centcom/ert/janitor

/datum/antagonist/ert/janitor/heavy
	role = "Heavy Duty Janitor"
	outfit = /datum/outfit/centcom/ert/janitor/heavy

/datum/antagonist/ert/kudzu
	role = "Weed Whacker"
	outfit = /datum/outfit/centcom/ert/kudzu

/datum/antagonist/ert/deathsquad/leader
	name = "Deathsquad Officer"
	outfit = /datum/outfit/centcom/death_commando/officer
	role = "Officer"

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

/datum/antagonist/ert/doomguy
	name = "The Juggernaut"
	outfit = /datum/outfit/centcom/death_commando/doomguy
	random_names = FALSE
	role = "The Juggernaut"

/datum/antagonist/ert/clown
	name = "Comedy Response Officer"
	outfit = /datum/outfit/centcom/centcom_clown
	role = "Prankster"
	plasmaman_outfit = /datum/outfit/plasmaman/honk

/datum/antagonist/ert/clown/honk
	name = "HONK Squad Trooper"
	outfit = /datum/outfit/centcom/centcom_clown/honk_squad
	role = "HONKER"
	plasmaman_outfit = /datum/outfit/plasmaman/honk_squad

/datum/antagonist/ert/create_team(datum/team/ert/new_team)
	if(istype(new_team))
		ert_team = new_team

/datum/antagonist/ert/bounty_armor
	role = "Armored Bounty Hunter"
	outfit = /datum/outfit/bounty/armor/ert

/datum/antagonist/ert/bounty_hook
	role = "Hookgun Bounty Hunter"
	outfit = /datum/outfit/bounty/hook/ert

/datum/antagonist/ert/bounty_synth
	role = "Synthetic Bounty Hunter"
	outfit = /datum/outfit/bounty/synth/ert

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
	//Set the suits frequency
	var/obj/item/I = H.get_item_by_slot(ITEM_SLOT_OCLOTHING)
	if(I)
		var/datum/component/tracking_beacon/beacon = I.GetComponent(/datum/component/tracking_beacon)
		if(beacon)
			beacon.set_frequency(ert_team.ert_frequency)


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

	to_chat(owner,missiondesc)

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

/datum/antagonist/ert/doomguy/greet()
	if(!ert_team)
		return

	to_chat(owner, "<B><font size=3 color=red>You are the Juggernaut, the latest in Nanotrasen's biologically-enhanced supersoldiers.</font></B>")

	var/missiondesc = "You are being sent on a mission to [station_name()] by the one of the highest ranking Nanotrasen officials around."
	if(leader) //If Squad Leader
		missiondesc += " Take stock of your equipment and teammates (if any) and board the transit shuttle when you are ready."
	else
		missiondesc += " Rip and tear."

	missiondesc += "<BR><B>Your Mission</B> : [ert_team.mission.explanation_text]"
	to_chat(owner,missiondesc)

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
