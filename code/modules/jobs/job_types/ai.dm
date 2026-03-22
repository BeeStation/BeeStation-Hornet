/datum/job/ai
	title = JOB_NAME_AI
	description = "Follow your laws above all else, be the invisible eye that watches all."
	department_for_prefs = DEPT_NAME_SILICON
	department_head_for_prefs = JOB_NAME_AI
	auto_deadmin_role_flags = DEADMIN_POSITION_SILICON
	faction = "Station"
	total_positions = 1
	selection_color = "#ccffcc"
	supervisors = "your laws"
	req_admin_notify = TRUE
	minimal_player_age = 30
	exp_requirements = 600
	exp_type = EXP_TYPE_SILICON
	display_order = JOB_DISPLAY_ORDER_AI
	departments = DEPT_BITFLAG_SILICON
	random_spawns_possible = FALSE
	allow_bureaucratic_error = FALSE
	var/do_special_check = TRUE

/datum/job/ai/get_access() // no point of calling parent proc
	return list()

/datum/job/ai/equip(mob/living/carbon/human/H, visuals_only, announce, latejoin, datum/outfit/outfit_override, client/preference_source = null)
	if(visuals_only)
		CRASH("dynamic preview is unsupported")
	. = H.AIize(latejoin,preference_source)

/datum/job/ai/after_spawn(mob/H, mob/M, latejoin = FALSE, client/preference_source, on_dummy = FALSE)
	. = ..()
	if(latejoin)
		var/obj/structure/AIcore/latejoin_inactive/lateJoinCore
		for(var/obj/structure/AIcore/latejoin_inactive/P in GLOB.latejoin_ai_cores)
			if(P.is_available())
				lateJoinCore = P
				GLOB.latejoin_ai_cores -= P
				break
		if(lateJoinCore)
			lateJoinCore.available = FALSE
			H.forceMove(lateJoinCore.loc)
			qdel(lateJoinCore)
	var/mob/living/silicon/ai/AI = H
	if(M.client)
		AI.apply_pref_name(/datum/preference/name/ai, preference_source)			//If this runtimes oh well jobcode is fucked.
	AI.set_core_display_icon(null, preference_source)
	if(!M.client || on_dummy)
		return

	//we may have been created after our borg
	if(SSticker.current_state == GAME_STATE_SETTING_UP)
		for(var/mob/living/silicon/robot/R as anything in GLOB.cyborg_list)
			if(!R.connected_ai)
				R.TryConnectToAI()

	if(latejoin)
		announce(AI)

/datum/job/ai/override_latejoin_spawn()
	return TRUE

/datum/job/ai/special_check_latejoin(client/C)
	if(!do_special_check)
		return TRUE
	for(var/i in GLOB.latejoin_ai_cores)
		var/obj/structure/AIcore/latejoin_inactive/LAI = i
		if(istype(LAI))
			if(LAI.is_available())
				return TRUE
	return FALSE

/datum/job/ai/announce(mob/living/silicon/ai/AI)
	. = ..()
	SSticker.OnRoundstart(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(minor_announce), "[AI] has been downloaded to an empty bluespace-networked AI core at [AREACOORD(AI)]."))

/datum/job/ai/config_check()
	return CONFIG_GET(flag/allow_ai)

