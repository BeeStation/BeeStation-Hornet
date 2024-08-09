/datum/job/cyborg
	title = JOB_NAME_CYBORG
	description = "Follow your AI's interpretation of your laws above all else, or your own interpretation if not connected to an AI. Choose one of many modules with different tools, ask robotics for maintenance and upgrades."
	department_for_prefs = DEPT_BITFLAG_SILICON
	department_head_for_prefs = JOB_NAME_AI
	auto_deadmin_role_flags = DEADMIN_POSITION_SILICON
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1
	supervisors = "your laws and the AI"	//Nodrak
	spawn_type = /mob/living/silicon/robot
	selection_color = "#ddffdd"
	minimal_player_age = 21
	exp_requirements = 120
	exp_type = EXP_TYPE_CREW
	random_spawns_possible = FALSE

	display_order = JOB_DISPLAY_ORDER_CYBORG
	departments = DEPT_BITFLAG_SILICON
	job_flags = JOB_NEW_PLAYER_JOINABLE | JOB_EQUIP_RANK

/datum/job/cyborg/get_access() // no point of calling parent proc
	return list()

/datum/job/cyborg/equip(mob/living/carbon/human/H, visualsOnly = FALSE, announce = TRUE, latejoin = FALSE, datum/outfit/outfit_override = null, client/preference_source)
	if(!iscyborg(H))
		return
	H.gender = NEUTER
	var/mob/living/silicon/robot/robot_spawn = H
	robot_spawn.notify_ai(NEW_BORG)

/datum/job/cyborg/radio_help_message(mob/M)
	to_chat(M, "<b>Prefix your message with :b to speak with other cyborgs and AI.</b>")
