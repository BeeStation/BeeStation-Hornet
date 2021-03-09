GLOBAL_LIST_INIT(bluespace_debug_verbs, list(
	/client/proc/spawn_ship,
	/client/proc/check_bluespace_levels,
	/client/proc/check_level_free,
	/client/proc/make_all_weapons_accurate,
	/client/proc/reset_all_weapons_accurate
))

/client/proc/enable_exploration_verbs()
	set category = "Debug"
	set name = "Bluespace Exploration Verbs - Enable"
	if(!check_rights(R_DEBUG))
		return

	remove_verb(/client/proc/enable_exploration_verbs)
	add_verb(/client/proc/disable_exploration_verbs)
	add_verb(GLOB.bluespace_debug_verbs)

/client/proc/disable_exploration_verbs()
	set category = "Debug"
	set name = "Bluespace Exploration Verbs - Disable"
	if(!check_rights(R_DEBUG))
		return
	add_verb(/client/proc/enable_exploration_verbs)
	remove_verb(/client/proc/disable_exploration_verbs)
	remove_verb(GLOB.bluespace_debug_verbs)

/client/proc/spawn_ship()
	set category = "Bluespace Exploration"
	set name = "Spawn NPC Ship"
	if(!check_rights(R_DEBUG))
		return
	//Pick a ship to spawn
	var/ships = SSbluespace_exploration.spawnable_ships
	if(!LAZYLEN(ships))
		return
	var/selected = input(usr, "What ship?", "Ship Spawn") as null|anything in ships
	var/z_level = input(usr, "What Z-level?", "Ship Spawn") as null|num
	if(selected && z_level)
		var/datum/map_template/shuttle/ship/S = SSbluespace_exploration.spawnable_ships[selected]
		if(!istype(S))
			message_admins("Incorrect ship type!")
		SSbluespace_exploration.spawn_and_register_shuttle(S, z_level)
		message_admins("[key_name_admin(usr)] spawned a hostile ship ([S] - [S.type]) on z-level [z_level]")
		log_admin("[key_name_admin(usr)] spawned a hostile ship ([S] - [S.type]) on z-level [z_level]")

/client/proc/check_level_free()
	set category = "Bluespace Exploration"
	set name = "Check Free BS Levels"
	if(!check_rights(R_DEBUG))
		return
	SSbluespace_exploration.check_free_levels()
	check_bluespace_levels()

/client/proc/check_bluespace_levels()
	set category = "Bluespace Exploration"
	set name = "Check Bluespace Exploration"
	if(!check_rights(R_DEBUG))
		return
	to_chat(src, "==== BLUESPACE EXPLORATION OVERVIEW ====")
	to_chat(src, "Subsystem Status: [SSbluespace_exploration.generating ? "GENERATING IN PROGRESS" : "Not Generating"]")
	to_chat(src, "Ship Queue Size: [SSbluespace_exploration.ship_traffic_queue.len]")
	to_chat(src, "Z-Level Wipe Queue Size: [SSbluespace_exploration.z_level_queue.len]")
	for(var/datum/space_level/level in SSbluespace_exploration.bluespace_systems)
		var/in_use = SSbluespace_exploration.bluespace_systems[level]
		var/status = "Invalid state"
		switch(in_use)
			if(BS_LEVEL_IDLE)
				status = "Idle"
			if(BS_LEVEL_GENERATING)
				status = "Generating"
			if(BS_LEVEL_USED)
				status = "In Use"
			if(BS_LEVEL_QUEUED)
				status = "Queued"
		to_chat(src, "Z-Level: [level.z_value] ([level.name]): [status]")

/client/proc/make_all_weapons_accurate()
	set category = "Bluespace Exploration"
	set name = "Make all weapons accurate"
	if(!check_rights(R_DEBUG))
		return
	message_admins("[ADMIN_LOOKUPFLW(usr)] made all weapons accurate for some reason")
	log_admin("[ADMIN_LOOKUP(usr)] made all weapons accurate for some reason")
	for(var/id in SSbluespace_exploration.shuttle_weapons)
		var/obj/machinery/shuttle_weapon/weapon = SSbluespace_exploration.shuttle_weapons[id]
		weapon.miss_chance = 0
		weapon.hit_chance = 100

//For fixing when you for some reason press this
/client/proc/reset_all_weapons_accurate()
	set category = "Bluespace Exploration"
	set name = "Reset all weapons accurate"
	if(!check_rights(R_DEBUG))
		return
	message_admins("[ADMIN_LOOKUPFLW(usr)] reset all weapons accurate")
	log_admin("[ADMIN_LOOKUP(usr)] reset all weapons accurate")
	for(var/id in SSbluespace_exploration.shuttle_weapons)
		var/obj/machinery/shuttle_weapon/weapon = SSbluespace_exploration.shuttle_weapons[id]
		weapon.miss_chance = initial(weapon.miss_chance)
		weapon.hit_chance = initial(weapon.hit_chance)
