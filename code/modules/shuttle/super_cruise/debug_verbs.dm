GLOBAL_LIST_INIT(supercruise_debug_verbs, list(
	/client/proc/give_ship_ai,
	/client/proc/check_ship_thoughts,
	/client/proc/check_ship_status,
	/client/proc/set_ship_faction,
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

/client/proc/check_ship_status()
	set category = "Exploration Debug"
	set name = "Check Ship Status"

	if(!check_rights(R_DEBUG))
		return

	for(var/shuttle_id in SSorbits.assoc_shuttle_data)
		var/datum/shuttle_data/shuttle = SSorbits.get_shuttle_data(shuttle_id)
		if(shuttle.reactor_critical)
			to_chat(src, "[shuttle.port_id]: <font color='red'><b>Reactor Critical!</b></font>")
		else if(shuttle.current_ship_integrity < shuttle.max_ship_integrity)
			to_chat(src, "[shuttle.port_id]: <font color='yellow'><b>[shuttle.current_ship_integrity]/[shuttle.max_ship_integrity] (Explodes at [shuttle.max_ship_integrity * shuttle.critical_proportion])</b></font>")
		else
			to_chat(src, "[shuttle.port_id]: <font color='green'><b>[shuttle.current_ship_integrity]/[shuttle.max_ship_integrity] (Explodes at [shuttle.max_ship_integrity * shuttle.critical_proportion])</b></font>")

/client/proc/check_ship_thoughts()
	set category = "Exploration Debug"
	set name = "Check Ship Thoughts"

	if(!check_rights(R_DEBUG))
		return

	for(var/shuttle_id in SSorbits.assoc_shuttle_data)
		var/datum/shuttle_data/shuttle = SSorbits.get_shuttle_data(shuttle_id)
		if(!shuttle.ai_pilot)
			to_chat(src, "[shuttle.port_id]: <font color='red'><b>No AI pilot!</b></font>")
		else if(!istype(shuttle.ai_pilot, /datum/shuttle_ai_pilot/npc))
			to_chat(src, "[shuttle.port_id]: <font color='yellow'><b>Not controlled by an NPC pilot.</b></font>")
		else
			var/datum/shuttle_ai_pilot/npc/npc_pilot = shuttle.ai_pilot
			to_chat(src, "[shuttle.port_id]: <font color='green'><b>[npc_pilot.last_thought]</b></font>")

/client/proc/set_ship_faction()
	set category = "Exploration Debug"
	set name = "Set Ship Faction"

	if(!check_rights(R_DEBUG))
		return

	var/selected_ship = input(src, "Select a ship to modify the faction of", "Shuttle Faction", null) as null|anything in SSorbits.assoc_shuttle_data
	if(!selected_ship)
		return

	var/datum/faction/selected_faction = input(src, "Select a faction to modify the ship to", "Shuttle Faction", null) as null|anything in SSorbits.factions
	if(!selected_faction)
		return
	//Revolution
	var/datum/shuttle_data/selected_shuttle = SSorbits.assoc_shuttle_data[selected_ship]
	selected_shuttle.faction = new selected_faction()
