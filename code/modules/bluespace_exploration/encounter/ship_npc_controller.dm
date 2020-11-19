/datum/ship_datum/npc
	var/list/weapon_systems = list()

	var/list/hostile_ships = list()

	var/datum/ship_datum/target = null	//Our current target

	//AI controller types
	var/battle_mode = BATTLE_POLICY_SUSTAINED

	//If not hostile, will not attack until attacked first
	var/hostile = TRUE

	//AI actions
	var/wants_to_flee = FALSE

	//Mobs on the ship
	var/list/mobs

/datum/ship_datum/npc/New()
	. = ..()
	locate_weapons()

/datum/ship_datum/npc/update_ship()
	. = ..()
	if(!LAZYLEN(.) || critical)
		return
	//Don't do anything if the mobs are dead
	if(!check_mobs_alive())
		return
	find_target()
	update_flee()
	update_weapons()

/datum/ship_datum/npc/proc/find_target()
	//Shoot at ships that are in hostile factions
	var/obj/our_port = SSshuttle.getShuttle(mobile_port_id)
	for(var/ship_key in SSbluespace_exploration.tracked_ships)
		var/datum/ship_datum/ship = SSbluespace_exploration.tracked_ships[ship_key]
		if(ship == src)
			continue
		var/obj/shuttle_port = SSshuttle.getShuttle(ship_key)
		if(!shuttle_port || !our_port || shuttle_port.z != our_port.z)
			continue
		if(ship in hostile_ships)
			continue
		if(check_faction_alignment(ship_faction, ship.ship_faction) == FACTION_STATUS_HOSTILE)
			hostile_ships += ship
	//Pick a target to shoot at, if we aren't already blasting
	if(target && (target in SSbluespace_exploration.tracked_ships))
		return
	if(LAZYLEN(hostile_ships))
		target = pick(hostile_ships)
		locate_weapons()	//Reset weapons when we find a new target, in case new ones have been build

/datum/ship_datum/npc/proc/update_flee()
	if(integrity_remaining / (max(max_ship_integrity, 1) * SHIP_INTEGRITY_FACTOR) < battle_mode)
		wants_to_flee = TRUE

/datum/ship_datum/npc/proc/update_weapons()
	var/has_active_weapons = FALSE
	for(var/obj/machinery/shuttle_weapon/weapon in weapon_systems)
		if(!weapon)
			weapon_systems -= weapon
			continue
		has_active_weapons = TRUE
		if(weapon.next_shot_world_time < world.time)
			if(target)
				var/obj/docking_port/mobile/port = SSshuttle.getShuttle(target.mobile_port_id)
				if(!port)
					break
				var/list/turfs = port.return_turfs()
				weapon.fire(pick(turfs))
	if(!has_active_weapons && battle_mode)
		wants_to_flee = TRUE

/datum/ship_datum/npc/proc/locate_weapons()
	weapon_systems = list()
	var/obj/docking_port/mobile/M = SSshuttle.getShuttle(mobile_port_id, FALSE)
	if(!M)
		return
	for(var/turf/T in M.return_turfs())
		for(var/obj/machinery/shuttle_weapon/weapon in T)
			weapon_systems |= weapon
	if(!LAZYLEN(weapon_systems))
		message_admins("failed to locate weapons on ship")

/datum/ship_datum/npc/proc/check_mobs_alive()
	if(!islist(mobs))
		locate_mobs()
	for(var/mob/living/L in mobs)
		if(!QDELETED(L) && !L.stat)
			return TRUE
	return FALSE

/datum/ship_datum/npc/proc/locate_mobs()
	mobs = list()
	var/obj/docking_port/mobile/M = SSshuttle.getShuttle(mobile_port_id, FALSE)
	if(!M)
		return
	for(var/turf/T in M.return_turfs())
		for(var/mob/living/L in T)
			mobs += L
