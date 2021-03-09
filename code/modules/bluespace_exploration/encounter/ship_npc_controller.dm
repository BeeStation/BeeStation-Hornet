/datum/ship_datum/npc
	var/list/weapon_systems

	var/list/hostile_ships

	var/datum/ship_datum/target = null	//Our current target

	//AI controller types
	var/battle_mode = BATTLE_POLICY_SUSTAINED

	//If not hostile, will not attack until attacked first
	var/hostile = TRUE

	//AI actions
	var/wants_to_flee = FALSE

	//Mobs on the ship
	var/list/mobs

	//NPC ships aren't going to be bluespace by default.
	bluespace = FALSE

/datum/ship_datum/npc/New()
	. = ..()
	hostile_ships = list()
	weapon_systems = list()
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
		//Dont shoot ourselves
		if(ship == src)
			continue
		var/obj/shuttle_port = SSshuttle.getShuttle(ship_key)
		//Dont shoot nulls
		if(!shuttle_port || !our_port || shuttle_port.z != our_port.z)
			continue
		//Dont something already hostile to use
		if(ship in hostile_ships)
			continue
		//Dont shoot enemies in another realm
		if(our_port.z != shuttle_port.z)
			continue
		var/datum/our_faction = ship_faction
		if(check_faction_alignment(ship_faction, ship.ship_faction) == FACTION_STATUS_HOSTILE || (our_faction.type in ship.rogue_factions))
			hostile_ships += ship
	//Pick a target to shoot at, if we aren't already blasting
	if(target && (target in SSbluespace_exploration.tracked_ships))
		return
	if(LAZYLEN(hostile_ships))
		target = pick(hostile_ships)
		log_shuttle("NPC shuttle [ship_name] found target [target.ship_name]")
		locate_weapons()	//Reset weapons when we find a new target, in case new ones have been build

/datum/ship_datum/npc/proc/update_flee()
	if(integrity_remaining / (max(max_ship_integrity, 1) * SHIP_INTEGRITY_FACTOR) < battle_mode)
		wants_to_flee = TRUE

/datum/ship_datum/npc/proc/update_weapons()
	var/has_active_weapons = FALSE
	for(var/obj/machinery/shuttle_weapon/weapon as() in weapon_systems)
		if(QDELETED(weapon))
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
				//Handle declaring ships rogue
				var/datum/ship_datum/our_ship = SSbluespace_exploration.tracked_ships[mobile_port_id]
				var/datum/ship_datum/their_ship = SSbluespace_exploration.tracked_ships[target.mobile_port_id]
				if(our_ship && their_ship)
					SSbluespace_exploration.after_ship_attacked(our_ship, their_ship)
				else
					log_shuttle("after_ship_attacked unable to call: [our_ship ? "our ship was valid" : "our ship was null"] ([mobile_port_id]) and/but [their_ship ? "their ship was valid" : "their ship was null"] ([target.mobile_port_id])")
	if(!has_active_weapons && battle_mode)
		wants_to_flee = TRUE

/datum/ship_datum/npc/proc/locate_weapons()
	weapon_systems = list()
	var/obj/docking_port/mobile/M = SSshuttle.getShuttle(mobile_port_id, FALSE)
	if(!M)
		return
	for(var/turf/T as() in M.return_turfs())
		var/obj/machinery/shuttle_weapon/weapon = locate() in T
		if(weapon)
			weapon_systems += weapon

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
