GLOBAL_LIST_INIT(bluespace_debug_verbs, list(
	/client/proc/spawn_ship
))

/client/proc/enable_exploration_verbs()
	set category = "Debug"
	set name = "Bluespace Exploration Verbs - Enable"
	if(!check_rights(R_DEBUG))
		return
	verbs -= /client/proc/enable_exploration_verbs
	verbs.Add(/client/proc/disable_exploration_verbs, GLOB.bluespace_debug_verbs)

/client/proc/disable_exploration_verbs()
	set category = "Debug"
	set name = "Bluespace Exploration Verbs - Disable"
	if(!check_rights(R_DEBUG))
		return
	verbs += /client/proc/enable_exploration_verbs
	verbs.Remove(/client/proc/disable_exploration_verbs, GLOB.bluespace_debug_verbs)

/client/proc/spawn_ship()
	set category = "Bluespace Exploration"
	set name = "Spawn Hostile Ship"
	if(!check_rights(R_DEBUG))
		return
	//Pick a ship to spawn
	var/ships = SSbluespace_exploration.spawnable_ships
	if(!LAZYLEN(ships))
		return
	var/selected = input(usr, "What ship?", "Ship Spawn") as null|anything in ships
	var/z_level = input(usr, "What Z-level?", "Ship Spawn") as null|num
	if(selected && z_level)
		SSbluespace_exploration.spawn_and_register_shuttle(SSbluespace_exploration.spawnable_ships[selected], z_level)
		message_admins("[key_name_admin(usr)] spawned a hostile ship ([selected] - [SSbluespace_exploration.spawnable_ships[selected]]) on z-level [z_level]")
