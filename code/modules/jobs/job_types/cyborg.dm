/datum/job/cyborg
	title = JOB_NAME_CYBORG
	flag = CYBORG
	auto_deadmin_role_flags = PREFTOGGLE_DEADMIN_POSITION_SILICON
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 0
	spawn_positions = 1
	supervisors = "your laws and the AI"	//Nodrak
	selection_color = "#ddffdd"
	minimal_player_age = 21
	exp_requirements = 120
	exp_type = EXP_TYPE_CREW
	random_spawns_possible = FALSE

	display_order = JOB_DISPLAY_ORDER_CYBORG
	departments = DEPARTMENT_BITFLAG_SILICON

/datum/job/cyborg/equip(mob/living/carbon/human/H, visualsOnly = FALSE, announce = TRUE, latejoin = FALSE, datum/outfit/outfit_override = null, client/preference_source = null)
	if(visualsOnly)
		CRASH("dynamic preview is unsupported")
	return H.Robotize(FALSE, latejoin)

/datum/job/cyborg/after_spawn(mob/living/silicon/robot/R, mob/M)
	R.updatename(M.client)
	R.gender = NEUTER

/datum/job/cyborg/radio_help_message(mob/M)
	to_chat(M, "<b>Prefix your message with :b to speak with other cyborgs and AI.</b>")
