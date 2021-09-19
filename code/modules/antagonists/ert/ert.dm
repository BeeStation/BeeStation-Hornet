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
	var/datum/outfit/outfit = /datum/outfit/ert/security
	var/datum/outfit/plasmaman_outfit = /datum/outfit/plasmaman/ert
	var/role = "Security Officer"
	var/list/name_source
	var/random_names = TRUE
	can_elimination_hijack = ELIMINATION_PREVENT
	show_in_antagpanel = FALSE
	show_to_ghosts = TRUE
	antag_moodlet = /datum/mood_event/focused

/datum/antagonist/ert/on_gain()
	if(random_names)
		update_name()
	forge_objectives()
	equipERT()
	owner.store_memory("Your team's shared tracking beacon frequency is [ert_team.ert_frequency].")
	. = ..()

/datum/antagonist/ert/get_team()
	return ert_team

/datum/antagonist/ert/New()
	. = ..()
	name_source = GLOB.last_names

/datum/antagonist/ert/proc/update_name()
	owner.current.fully_replace_character_name(owner.current.real_name,"[role] [pick(name_source)]")

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

/datum/antagonist/ert/security // kinda handled by the base template but here for completion

/datum/antagonist/ert/security/red
	outfit = /datum/outfit/ert/security/alert

/datum/antagonist/ert/engineer
	role = "Engineer"
	outfit = /datum/outfit/ert/engineer

/datum/antagonist/ert/engineer/red
	outfit = /datum/outfit/ert/engineer/alert

/datum/antagonist/ert/medic
	role = "Medical Officer"
	outfit = /datum/outfit/ert/medic

/datum/antagonist/ert/medic/red
	outfit = /datum/outfit/ert/medic/alert

/datum/antagonist/ert/commander
	role = "Commander"
	outfit = /datum/outfit/ert/commander

/datum/antagonist/ert/commander/red
	outfit = /datum/outfit/ert/commander/alert

/datum/antagonist/ert/deathsquad
	name = "Deathsquad Trooper"
	outfit = /datum/outfit/death_commando
	role = "Trooper"
	plasmaman_outfit = /datum/outfit/plasmaman/death_commando

/datum/antagonist/ert/medic/inquisitor
	outfit = /datum/outfit/ert/medic/inquisitor

/datum/antagonist/ert/medic/inquisitor/on_gain()
	. = ..()
	owner.holy_role = HOLY_ROLE_PRIEST

/datum/antagonist/ert/security/inquisitor
	outfit = /datum/outfit/ert/security/inquisitor

/datum/antagonist/ert/security/inquisitor/on_gain()
	. = ..()
	owner.holy_role = HOLY_ROLE_PRIEST

/datum/antagonist/ert/chaplain
	role = "Chaplain"
	outfit = /datum/outfit/ert/chaplain

/datum/antagonist/ert/chaplain/inquisitor
	outfit = /datum/outfit/ert/chaplain/inquisitor

/datum/antagonist/ert/chaplain/on_gain()
	. = ..()
	owner.holy_role = HOLY_ROLE_PRIEST

/datum/antagonist/ert/commander/inquisitor
	outfit = /datum/outfit/ert/commander/inquisitor

/datum/antagonist/ert/commander/inquisitor/on_gain()
	. = ..()
	owner.holy_role = HOLY_ROLE_PRIEST

/datum/antagonist/ert/janitor
	role = "Janitor"
	outfit = /datum/outfit/ert/janitor

/datum/antagonist/ert/janitor/heavy
	role = "Heavy Duty Janitor"
	outfit = /datum/outfit/ert/janitor/heavy

/datum/antagonist/ert/deathsquad/leader
	name = "Deathsquad Officer"
	outfit = /datum/outfit/death_commando/officer
	role = "Officer"

/datum/antagonist/ert/intern
	name = "CentCom Intern"
	outfit = /datum/outfit/centcom_intern
	random_names = FALSE
	role = "Intern"
	plasmaman_outfit = /datum/outfit/plasmaman/intern

/datum/antagonist/ert/intern/leader
	name = "CentCom Head Intern"
	outfit = /datum/outfit/centcom_intern/leader
	role = "Head Intern"

/datum/antagonist/ert/doomguy
	name = "The Juggernaut"
	outfit = /datum/outfit/death_commando/doomguy
	random_names = FALSE
	role = "The Juggernaut"

/datum/antagonist/ert/clown
	name = "Comedy Response Officer"
	outfit = /datum/outfit/centcom_clown
	role = "Prankster"
	plasmaman_outfit = /datum/outfit/plasmaman/honk

/datum/antagonist/ert/clown/honk
	name = "HONK Squad Trooper"
	outfit = /datum/outfit/centcom_clown/honk_squad
	role = "HONKER"
	plasmaman_outfit = /datum/outfit/plasmaman/honk_squad

/datum/antagonist/ert/create_team(datum/team/ert/new_team)
	if(istype(new_team))
		ert_team = new_team

/datum/antagonist/ert/proc/forge_objectives()
	if(ert_team)
		objectives |= ert_team.objectives

/datum/antagonist/ert/proc/equipERT()
	var/mob/living/carbon/human/H = owner.current
	if(!istype(H))
		return
	if(isplasmaman(H))
		H.equipOutfit(plasmaman_outfit)
		H.internal = H.get_item_for_held_index(2)
		H.update_internals_hud_icon(1)
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

		missiondesc += "Avoid civilian casualites when possible."

	missiondesc += "<BR><B>Your Mission</B> : [ert_team.mission.explanation_text]"
	missiondesc += "<BR><b>Your Shared Tracking Frequency</b> : <i>[ert_team.ert_frequency]</i>"

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
