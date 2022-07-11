/datum/shuttle_ai_pilot/npc
	//You can't turn on the NPC driving the ship. (bet :smirk:)
	overridable = FALSE
	/// Target orbital body of the autopilot.
	var/datum/orbital_object/shuttleTarget = null
	/// The hostile ships that are nearby
	var/list/hostile_ships = list()
	/// The target we are currently fighting
	var/datum/shuttle_data/target = null
	/// The amount of health we can lose before attempting to flee
	var/integrity_flee_limit = BATTLE_POLICY_CAREFUL
	/// If we are a non-hostile ship, we won't attack unless attacked first
	var/hostile = TRUE
	/// The amount of mobs on the ship piloting it
	var/pilot_mobs = 0
	/// The last thought of this shuttle
	var/last_thought

/datum/shuttle_ai_pilot/npc/New()
	. = ..()
	//Check if we need to start processing
	if (!SSorbits.assoc_shuttles[shuttle_data.port_id])
		START_PROCESSING(SSorbits, src)

/datum/shuttle_ai_pilot/npc/handle_ai_combat_action()
	if(shuttle_data.reactor_critical || !pilot_mobs)
		last_thought = "I am dead."
		return
	//If we have no weapons, flee
	if(!length(shuttle_data.shuttle_weapons))
		last_thought = "I have no weapons and wish to flee."
		if(flee_combat(TRUE))
			return
	//If we are too damaged, flee
	if(shuttle_data.current_ship_integrity <= shuttle_data.max_ship_integrity * integrity_flee_limit)
		last_thought = "I need to get out of here, my ship is too damaged!"
		if(flee_combat(TRUE))
			return
	var/obj/docking_port/mobile/M = SSshuttle.getShuttle(shuttle_data.port_id)
	//If we don't have a target, find one
	if (!target)
		find_target()
	else
		var/obj/docking_port/mobile/hostile_docking_port = SSshuttle.getShuttle(target.port_id)
		if(hostile_docking_port.get_virtual_z_level() != M.get_virtual_z_level())
			lose_target()
			find_target()
	//We still have no target, lets just leave this area and continue with our other mission
	if(!target)
		last_thought = "There is nobody here, I need to continue with my previous mission."
		if(flee_combat(FALSE))
			return
	//If we have a target, fire at them
	last_thought = "I need to destroy \the [target.shuttle_name]."
	fire_on_target()

///Fire our weapons at the target
/datum/shuttle_ai_pilot/npc/proc/fire_on_target()
	var/obj/docking_port/mobile/target_port = SSshuttle.getShuttle(target.port_id)
	var/list/target_turfs = target_port.return_turfs()
	if(!target_port)
		return
	for (var/obj/machinery/shuttle_weapon/weapon as() in shuttle_data.shuttle_weapons)
		if(weapon.next_shot_world_time > world.time)
			continue
		var/turf/target_turf = pick(target_turfs)
		weapon.fire(target_turf)
		var/datum/shuttle_data/their_ship = SSorbits.get_shuttle_data(target.port_id)
		if(shuttle_data && their_ship)
			SSorbits.after_ship_attacked(shuttle_data, their_ship)
		else
			log_shuttle("after_ship_attacked unable to call: [shuttle_data ? "our ship was valid" : "our ship was null"] ([shuttle_data.port_id]) and/but [their_ship ? "their ship was valid" : "their ship was null"] ([target.port_id])")

///Attempt to launch the shuttle and leave combat
/datum/shuttle_ai_pilot/npc/proc/flee_combat(escape = FALSE)
	//Simulate pressing launch shuttle
	if(!shuttle_data.check_can_launch())
		return FALSE
	if(SSorbits.interdicted_shuttles.Find(shuttle_data.port_id))
		if(world.time < SSorbits.interdicted_shuttles[shuttle_data.port_id])
			return FALSE
	var/obj/docking_port/mobile/mobile_port = SSshuttle.getShuttle(shuttle_data.port_id)
	if(!mobile_port)
		return FALSE
	if(mobile_port.mode == SHUTTLE_RECHARGING)
		return FALSE
	if(mobile_port.mode != SHUTTLE_IDLE)
		return TRUE
	if(SSorbits.assoc_shuttles.Find(shuttle_data.port_id))
		. = TRUE
		CRASH("NPC is attempting to fly a shuttle that already has a shuttle object. [shuttle_data.port_id]")
	var/shuttleObject = mobile_port.enter_supercruise()
	if(!shuttleObject)
		return FALSE
	return TRUE


///Lose our current target
/datum/shuttle_ai_pilot/npc/proc/lose_target()
	SIGNAL_HANDLER
	if(!target)
		return
	UnregisterSignal(target, COMSIG_PARENT_QDELETING)
	target = null

///Find a new target
/datum/shuttle_ai_pilot/npc/proc/find_target()
	var/obj/docking_port/mobile/our_port = SSshuttle.getShuttle(shuttle_data.port_id)
	var/list/valid = list()
	//Locate all ships on this z-level
	for (var/shuttle_id in SSorbits.assoc_shuttles)
		var/obj/docking_port/mobile/target_port = SSshuttle.getShuttle(shuttle_id)
		//Check z-level
		if(target_port.get_virtual_z_level() != our_port.get_virtual_z_level())
			continue
		//Check factional aliegence (Can't spell that word)
		var/datum/shuttle_data/target_data = SSorbits.get_shuttle_data(shuttle_id)
		if(check_faction_alignment(shuttle_data.faction, target_data.faction) == FACTION_STATUS_HOSTILE || (shuttle_data.faction.type in target_data.rogue_factions))
			valid += target_data
	if(!length(valid))
		return
	target = pick(valid)
	//Now that we have found our target, register relevent signals to prevent hard del
	RegisterSignal(target, COMSIG_PARENT_QDELETING, .proc/lose_target)

///Called every shuttle tick, handles the action of the shuttle
/datum/shuttle_ai_pilot/npc/handle_ai_flight_action(datum/orbital_object/shuttle/shuttle)
	if(!pilot_mobs)
		return
	//Don't drive places if we have no target, just try to stay at our current location
	if (!shuttleTarget)
		last_thought = "I have nowhere to go, I'll just fly around."
		if(!shuttle.shuttleTargetPos)
			shuttle.shuttleTargetPos = new(shuttle.position.x, shuttle.position.y)
		else
			//Change our position randomly
			shuttle.shuttleTargetPos.x += rand(-100, 100)
			shuttle.shuttleTargetPos.y += rand(-100, 100)
		return
	//Drive to the requested location
	last_thought = "I am flying to my destination."
	if(!shuttle.shuttleTargetPos)
		shuttle.shuttleTargetPos = new(shuttleTarget.position.x, shuttleTarget.position.y)
	else
		shuttle.shuttleTargetPos.x = shuttleTarget.position.x
		shuttle.shuttleTargetPos.y = shuttleTarget.position.y

/datum/shuttle_ai_pilot/npc/proc/set_target_location(datum/orbital_object/_shuttleTarget)
	shuttleTarget = _shuttleTarget
	RegisterSignal(shuttleTarget, COMSIG_PARENT_QDELETING, .proc/target_deleted)

/datum/shuttle_ai_pilot/npc/proc/target_deleted(datum/source, force)
	UnregisterSignal(shuttleTarget, COMSIG_PARENT_QDELETING)
	shuttleTarget = null

/datum/shuttle_ai_pilot/npc/get_target_name()
	return shuttleTarget.name

/datum/shuttle_ai_pilot/npc/try_toggle()
	return FALSE

/datum/shuttle_ai_pilot/npc/is_active()
	return TRUE
