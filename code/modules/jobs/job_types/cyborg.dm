/datum/job/cyborg
	jkey = JOB_KEY_CYBORG
	jtitle = JOB_TITLE_CYBORG
	job_bitflags = JOB_BITFLAG_SELECTABLE | JOB_BITFLAG_MANAGE_LOCKED
	auto_deadmin_role_flags = PREFTOGGLE_DEADMIN_POSITION_SILICON
	faction = "station"
	total_positions = 1
	spawn_positions = 1
	selection_color = "#ddffdd"
	minimal_player_age = 21
	exp_requirements = 120
	exp_type = EXP_TYPE_CREW
	random_spawns_possible = FALSE

	display_order = JOB_DISPLAY_ORDER_CYBORG
	departments = DEPT_BITFLAG_SILICON

/datum/job/cyborg/notify_your_supervisor()
	return "your laws, and AI (if you're enslaved to them)"

/datum/job/cyborg/equip(mob/living/carbon/human/H, visualsOnly = FALSE, announce = TRUE, latejoin = FALSE, datum/outfit/outfit_override = null, client/preference_source = null)
	if(visualsOnly)
		CRASH("dynamic preview is unsupported")
	return H.Robotize(FALSE, latejoin)

/datum/job/cyborg/after_spawn(mob/living/silicon/robot/R, mob/M)
	R.updatename(M.client)
	R.gender = NEUTER

/datum/job/cyborg/radio_help_message(mob/M)
	to_chat(M, "<b>Prefix your message with :b to speak with other cyborgs and AI.</b>")
