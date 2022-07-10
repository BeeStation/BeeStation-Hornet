GLOBAL_LIST_INIT(supercruise_debug_verbs, list(
	/client/proc/give_ship_ai,
))

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
