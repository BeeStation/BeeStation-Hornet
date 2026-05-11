/datum/job/cyborg
	title = JOB_NAME_CYBORG
	description = "Follow your AI's interpretation of your laws above all else, or your own interpretation if not connected to an AI. Choose one of many modules with different tools, ask robotics for maintenance and upgrades."
	department_for_prefs = DEPARTMENT_NAME_SILICON
	department_head_for_prefs = JOB_NAME_AI
	auto_deadmin_role_flags = DEADMIN_POSITION_SILICON
	faction = FACTION_STATION
	total_positions = 1
	latejoin_allowed = FALSE
	supervisors = "your laws and the AI" //Nodrak
	selection_color = "#ddffdd"
	spawn_type = /mob/living/silicon/robot
	minimal_player_age = 21
	exp_requirements = 180
	exp_required_type = EXP_TYPE_CREW
	exp_granted_type = EXP_TYPE_CREW
	random_spawns_possible = FALSE

	display_order = JOB_DISPLAY_ORDER_CYBORG
	departments_list = list(
		/datum/department_group/silicon,
		)

	job_flags = JOB_NEW_PLAYER_JOINABLE | JOB_EQUIP_RANK | JOB_CANNOT_OPEN_SLOTS

/datum/job/cyborg/get_access() // no point of calling parent proc
	return list()

/datum/job/cyborg/after_spawn(mob/living/spawned, client/player_client)
	. = ..()
	if(!iscyborg(spawned))
		return
	spawned.gender = NEUTER
	var/mob/living/silicon/robot/robot_spawn = spawned
	robot_spawn.notify_ai(NEW_BORG)

/datum/job/cyborg/get_radio_information()
	return "<b>Prefix your message with :b to speak with other cyborgs and AI.</b>"
