GLOBAL_LIST_INIT(supercruise_debug_verbs, list(
	/client/proc/give_ship_ai,
	/client/proc/check_ship_thoughts,
	/client/proc/check_ship_status,
	/client/proc/set_ship_faction,
	/client/proc/highlight_registered_turfs,
	/client/proc/create_npc_ship,
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

	var/selected_ai = input(src, "Select an AI type to grant to this ship.", "Grant AI", null) as null|anything in typesof(/datum/shuttle_ai_pilot)
	if(!selected_ai)
		return

	//Awaken
	var/datum/shuttle_data/selected_shuttle = SSorbits.assoc_shuttle_data[selected_ship]
	selected_shuttle.set_pilot(new selected_ai())

	message_admins("[key_name_admin(src)] enabled the AI of [selected_ship].")
	log_shuttle("[key_name_admin(src)] enabled the AI of [selected_ship].")
	log_admin("[key_name_admin(src)] enabled the AI of [selected_ship].")

/client/proc/check_ship_status()
	set category = "Exploration Debug"
	set name = "Check Ship Status"

	if(!check_rights(R_DEBUG))
		return

	for(var/shuttle_id in SSorbits.assoc_shuttle_data)
		var/datum/shuttle_data/shuttle = SSorbits.get_shuttle_data(shuttle_id)
		var/debug_integrity = shuttle.debug_integrity()
		if(shuttle.reactor_critical)
			to_chat(src, "[shuttle.port_id]: <font color='red'><b>Reactor Critical!</b></font>")
		else if(debug_integrity != shuttle.current_ship_integrity)
			to_chat(src, "[shuttle.port_id]: <font color='red'><b>!! [shuttle.current_ship_integrity]/[shuttle.max_ship_integrity] (Explodes at [shuttle.max_ship_integrity * shuttle.critical_proportion]) {DEBUG INTEGRITY: [debug_integrity]} !!</b></font>")
		else if(shuttle.current_ship_integrity < shuttle.max_ship_integrity)
			to_chat(src, "[shuttle.port_id]: <font color='yellow'><b>[shuttle.current_ship_integrity]/[shuttle.max_ship_integrity] (Explodes at [shuttle.max_ship_integrity * shuttle.critical_proportion]) {DEBUG INTEGRITY: [debug_integrity]}</b></font>")
		else
			to_chat(src, "[shuttle.port_id]: <font color='green'><b>[shuttle.current_ship_integrity]/[shuttle.max_ship_integrity] (Explodes at [shuttle.max_ship_integrity * shuttle.critical_proportion]) {DEBUG INTEGRITY: [debug_integrity]}</b></font>")

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

	var/datum/faction/selected_faction = input(src, "Select a faction to modify the ship to", "Shuttle Faction", null) as null|anything in subtypesof(/datum/faction)
	if(!selected_faction)
		return
	//Revolution
	var/datum/shuttle_data/selected_shuttle = SSorbits.assoc_shuttle_data[selected_ship]
	selected_shuttle.faction = new selected_faction()

	message_admins("[key_name_admin(src)] changed the faction of [selected_ship] to [selected_faction].")
	log_shuttle("[key_name_admin(src)] changed the faction of [selected_ship] to [selected_faction].")
	log_admin("[key_name_admin(src)] changed the faction of [selected_ship] to [selected_faction].")

/client/proc/highlight_registered_turfs()
	set category = "Exploration Debug"
	set name = "Highlight Registered Turfs"

	if(!check_rights(R_DEBUG))
		return

	//Create an overlay for all registered turfs on shuttles
	for(var/shuttle_id in SSorbits.assoc_shuttle_data)
		var/datum/shuttle_data/shuttle_data = SSorbits.get_shuttle_data(shuttle_id)
		for(var/turf/T as() in shuttle_data.registered_turfs)
			var/image/I = image('icons/turf/overlays.dmi', T, "blueOverlay")
			I.plane = ABOVE_LIGHTING_PLANE
			images += I
			//Awful, awful code but this is a debug verb.
			//Do not copy this code, use timers instead
			spawn(20 SECONDS)
				images -= I
				qdel(I)

/client/proc/create_npc_ship()
	set category = "Exploration Debug"
	set name = "Spawn NPC Ship"

	if(!check_rights(R_DEBUG))
		return

	var/list/valid_maps = list()

	for(var/id in SSmapping.shuttle_templates)
		var/datum/map_template/shuttle/ship/map = SSmapping.shuttle_templates[id]
		if(!istype(map))
			continue
		valid_maps[id] = map

	var/selected = input(src, "Select the ship template to spawn", "Spawn NPC Ship", null) as null|anything in valid_maps
	var/datum/map_template/shuttle/ship/selected_ship = valid_maps[selected]
	if(!selected_ship)
		return

	var/selected_faction = input(src, "Select a faction", "Spawn NPC Ship", null) as null|anything in subtypesof(/datum/faction)
	if(!selected_faction)
		return

	var/selected_ai = input(src, "Select an AI type to grant to this ship", "Spawn NPC Ship", null) as null|anything in typesof(/datum/shuttle_ai_pilot)
	if(!selected_ai)
		return

	SSorbits.spawn_ship(selected_ship, new selected_faction(), new selected_ai())

	message_admins("[key_name_admin(src)] spawned an NPC ship.")
	log_shuttle("[key_name_admin(src)] spawned an NPC ship.")
	log_admin("[key_name_admin(src)] spawned an NPC ship.")
