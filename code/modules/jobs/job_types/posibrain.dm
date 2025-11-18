GLOBAL_LIST_EMPTY(on_station_posis)

/datum/job/posibrain
	title = JOB_NAME_POSIBRAIN
	description = "Follow your AI's interpretation of your laws above all else, or your own interpretation if not connected to an AI. Choose one of many modules with different tools, ask robotics for maintenance and upgrades."
	department_for_prefs = DEPT_BITFLAG_SILICON
	department_head_for_prefs = JOB_NAME_AI
	auto_deadmin_role_flags = DEADMIN_POSITION_SILICON
	faction = "Station"
	total_positions = 0
	supervisors = "your laws" //No AI yet as you are just a cube
	selection_color = "#ddffdd"
	minimal_player_age = 21
	exp_requirements = 120
	exp_type = EXP_TYPE_CREW
	random_spawns_possible = FALSE

	display_order = JOB_DISPLAY_ORDER_CYBORG
	departments = DEPT_BITFLAG_SILICON

	show_in_prefs = FALSE //No reason to show in preferences

/datum/job/posibrain/equip(mob/living/carbon/human/H, visuals_only = FALSE, announce = TRUE, latejoin = FALSE, datum/outfit/outfit_override = null, client/preference_source = null)

	var/obj/item/mmi/posibrain/P = pick(GLOB.on_station_posis)

	//Never show number of current posis
	current_positions = 0

	if(!P.activate(H)) //If we failed to activate a posi, kick them back to the lobby.
		to_chat(H, span_warning("Failed to Late Join as a Posibrain. Look higher in chat for the reason."))
		return FALSE //Returning False is considered a failure, rather than null or a mob, which is a success.

	qdel(H)
	return P

/datum/job/posibrain/radio_help_message(mob/M)
	to_chat(M, "<b>Prefix your message with :b to speak with other cyborgs and AI.</b>")

/datum/job/posibrain/proc/check_add_posi_slot(obj/item/mmi/posibrain/pb)
	var/turf/currentturf = get_turf(pb)
	if( is_station_level(currentturf.z) )
		GLOB.on_station_posis |= pb

	//Update Job Quantities
	//We should never show a posibrain as a filled job, so just make number of current positions zero
	current_positions = 0
	total_positions = length(GLOB.on_station_posis)

/datum/job/posibrain/proc/remove_posi_slot(obj/item/mmi/posibrain/pb)
	GLOB.on_station_posis -= pb

	//Update Job Quantities
	//We should never show a posibrain as a filled job, so just make number of current positions zero
	current_positions = 0
	total_positions = length(GLOB.on_station_posis)
