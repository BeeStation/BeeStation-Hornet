/datum/ship_datum/npc
	var/list/weapon_systems = list()

	var/datum/ship_datum/target = null	//Our current target

	//AI controller types
	var/battle_mode = BATTLE_POLICY_SUSTAINED

	//AI actions
	var/wants_to_flee = FALSE

/datum/ship_datum/npc/New()
	. = ..()
	locate_weapons()

/datum/ship_datum/npc/update_ship()
	. = ..()

	if(!LAZYLEN(.) || critical)
		return

	update_flee()
	update_weapons()

/datum/ship_datum/npc/proc/update_flee()
	if(integrity_remaining / total_integrity_remaining < battle_mode)
		wants_to_flee = TRUE

/datum/ship_datum/npc/proc/update_weapons()
	var/has_active_weapons = FALSE
	for(var/obj/machinery/shuttle_weapon/weapon in weapon_systems)
		if(!weapon)
			weapon_systems -= weapon
			continue
		has_active_weapons = TRUE
		if(weapon.next_shot_world_time < world.time)
			weapon.fire(weapon)
	if(!has_active_weapons && battle_mode)
		wants_to_flee = TRUE

/datum/ship_datum/npc/proc/locate_weapons()
	weapon_systems = list()
	var/obj/docking_port/mobile/M = SSshuttle.getShuttle(mobile_port_id, FALSE)
	for(var/turf/T in M.return_turfs())
		for(var/obj/machinery/shuttle_weapon/weapon in T)
			weapon_systems |= T
