GLOBAL_LIST_INIT(supercruise_debug_verbs, list(
	/client/proc/give_ship_ai,
	/client/proc/check_ship_thoughts,
))
GLOBAL_PROTECT(supercruise_debug_verbs)

/client/proc/enable_supercruise_verbs()
	set category = "Debug"
	set name = "Supercruise Verbs - Enable"

	if(!check_rights(R_DEBUG))
		return

	remove_verb(/client/proc/enable_supercruise_verbs)
	add_verb(/client/proc/disable_supercruise_verbs)
	add_verb(GLOB.supercruise_debug_verbs)

/client/proc/disable_supercruise_verbs()
	set category = "Debug"
	set name = "Supercruise Verbs - Disable"

	if(!check_rights(R_DEBUG))
		return

	add_verb(/client/proc/enable_supercruise_verbs)
	remove_verb(/client/proc/disable_supercruise_verbs)
	remove_verb(GLOB.supercruise_debug_verbs)

/client/proc/give_ship_ai()
	set category = "Exploration Debug"
	set name = "Grant Ship AI"

	if(!check_rights(R_DEBUG))
		return

	var/selected_ship = input(src, "Select a ship to grant AI to. (The ship must have at least 1 NPC mob on it.)", "Grant AI", null) as null|anything in SSorbits.assoc_shuttle_data
	if(!selected_ship)
		return
	//Awaken
	var/datum/shuttle_data/selected_shuttle = SSorbits.assoc_shuttle_data[selected_ship]
	selected_shuttle.set_pilot(new /datum/shuttle_ai_pilot/npc())

/client/proc/check_ship_thoughts()
	set category = "Exploration Debug"
	set name = "Check Ship Thoughts"

	if(!check_rights(R_DEBUG))
		return

	for(var/shuttle_id in SSorbits.assoc_shuttle_data)
		var/datum/shuttle_data/shuttle = SSorbits.get_shuttle_data(shuttle_id)
		if(!shuttle.ai_pilot)
			to_chat(src, "[shuttle.port_id]: <color='red'><b>No AI pilot!</b></color>")
		else if(!istype(shuttle.ai_pilot, /datum/shuttle_ai_pilot/npc))
			to_chat(src, "[shuttle.port_id]: <color='yellow'><b>Not controlled by an NPC pilot.</b></color>")
		else
			var/datum/shuttle_ai_pilot/npc/npc_pilot = shuttle.ai_pilot
			to_chat(src, "[shuttle.port_id]: <color='green'><b>[npc_pilot.last_thought]</b></color>")
