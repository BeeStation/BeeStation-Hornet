/datum/job/expansion_director
	title = "Expansion Director"
	flag = EXPANSIONDIRECTOR
	auto_deadmin_role_flags = DEADMIN_POSITION_HEAD
	department_head = list("Captain")
	department_flag = MEDSCI
	head_announce = list("Exploration")
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain"
	selection_color = "#97FBEA"
	chat_color = "#AC71FA"
	exp_type = EXP_TYPE_CREW
	req_admin_notify = 1
	minimal_player_age = 7

	outfit = /datum/outfit/job/exploration_crew/leader

	access = list(ACCESS_RESEARCH, ACCESS_EVA, ACCESS_EXPLORATION)
	minimal_access = list(ACCESS_RESEARCH, ACCESS_EVA, ACCESS_EXPLORATION)
	paycheck = PAYCHECK_COMMAND
	paycheck_department = ACCOUNT_EXP

	display_order = JOB_DISPLAY_ORDER_EXPANSION_DIRECTOR
