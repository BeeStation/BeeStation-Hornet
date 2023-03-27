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
	var/hostile = FALSE
	/// The amount of mobs on the ship piloting it
	var/pilot_mobs = 0
	/// The last thought of this shuttle
	var/last_thought
	/// The world time to leave this location at
	var/exit_world_time = 0
	/// The range that we want to be at
	/// Should be close enough for weaopns, but outside of interdiction range
	var/combat_range = 500

/// Locate mobs on the shuttle
/datum/shuttle_ai_pilot/npc/attach_to_shuttle(datum/shuttle_data/shuttle_data)
	. = ..()
	//Check if we need to start processing
	if (!SSorbits.assoc_shuttles[shuttle_data.port_id])
		START_PROCESSING(SSorbits, src)
	//Make our shuttle weaker
	shuttle_data.critical_proportion = SHIP_INTEGRITY_FACTOR_NPC
	//Locate any pilot mobs
	var/obj/docking_port/mobile/shuttle_port = SSshuttle.getShuttle(shuttle_data.port_id)
	for (var/area/A in shuttle_port.shuttle_areas)
		for (var/mob/living/L in A)
			//In case the mob becomes sentient
			L.flavor_text = "You are a crewmember aboard <b>[shuttle_port.name]</b>. Defend your ship and protect your assets (including prisoners). <br/>\
				Your ship's faction is: <b>[shuttle_data.faction.name]</b>.<br />\
				This role has no specific objectives, your goal is to create interesting stories: Not every conflict has to be resolved through instant murder, make some situations that are fun for other players!<br />\
				<font color='red'><b>This is a story role: Failure to properly roleplay will result in a ghost-role ban.</b></font><br /> \
				<font color='red'><b>Do not take actions to permanently remove a station crewmember from the round.</b></font><br />"
			pilot_mobs ++
			RegisterSignal(L, COMSIG_PARENT_QDELETING, .proc/on_mob_died_or_deleted)
			RegisterSignal(L, COMSIG_MOB_DEATH, .proc/on_mob_died_or_deleted)
			RegisterSignal(L, COMSIG_GLOB_MOB_LOGGED_IN, .proc/human_takeover)

/datum/shuttle_ai_pilot/npc/proc/human_takeover(datum/source, ...)
	pilot_mobs = 0
	shuttle_data.critical_proportion = SHIP_INTEGRITY_FACTOR_PLAYER

/datum/shuttle_ai_pilot/npc/proc/on_mob_died_or_deleted(datum/source, ...)
	if(!pilot_mobs)
		return
	pilot_mobs --
	UnregisterSignal(source, COMSIG_PARENT_QDELETING)
	UnregisterSignal(source, COMSIG_MOB_DEATH)
	UnregisterSignal(source, COMSIG_GLOB_MOB_LOGGED_IN)
	//Now that all mobs on the ship are dead, make it stronger again
	if(!pilot_mobs)
		shuttle_data.critical_proportion = SHIP_INTEGRITY_FACTOR_PLAYER

/datum/shuttle_ai_pilot/npc/handle_ai_combat_action()
	if(shuttle_data.reactor_critical || !pilot_mobs)
		if(!overridable)
			SEND_SIGNAL(shuttle_data, COMSIG_SHUTTLE_NPC_INCAPACITATED)
			last_thought = "I am dead."
			overridable = TRUE
		return
	//Attempt to leave the combat zone
	last_thought = "I wish so that I can get back into weapons range"
	flee_combat(TRUE)

///Called every shuttle tick, handles the action of the shuttle
/datum/shuttle_ai_pilot/npc/handle_ai_flight_action(datum/orbital_object/shuttle/shuttle)
	if(!pilot_mobs)
		if(!overridable)
			SEND_SIGNAL(shuttle_data, COMSIG_SHUTTLE_NPC_INCAPACITATED)
			last_thought = "I am dead."
			overridable = TRUE
		return
	//If we are docking with something, undock
	if (shuttle.docking_target)
		shuttle.undock()
	//Check for hostile targets
	if(!target)
		find_target()
	var/datum/orbital_object/shuttle/target_shuttle
	//Lose the target
	if(target)
		target_shuttle = SSorbits.assoc_shuttles[target.port_id]
		if (!target_shuttle)
			lose_target()
		// Lose target if out of range
		if (target_shuttle.position.DistanceTo(shuttle.position) > shuttle_data.detection_range)
			lose_target()
	//No targets, just fly to where we want
	if (!target)
		//Drive to the requested location
		last_thought = "I am flying to my destination."
		//Don't drive places if we have no target, just try to stay at our current location
		if (!shuttleTarget)
			last_thought = "I have nowhere to go, I'll just fly around."
			if(!shuttle.shuttleTargetPos)
				shuttle.shuttleTargetPos = new(shuttle.position.GetX(), shuttle.position.GetY())
			else
				//Change our position randomly
				shuttle.shuttleTargetPos.AddSelf(new /datum/orbital_vector(rand(-100, 100), rand(-100, 100)))
		else
			//Fly to our target
			set_target_position(shuttle, shuttleTarget.position.GetX(), shuttleTarget.position.GetY())
	else
		//Attempt to attack target
		fire_on_target()
		//Combat movement
		var/delta_x = (shuttle.position.GetX() - target_shuttle.position.GetX())
		var/delta_y = (shuttle.position.GetY() - target_shuttle.position.GetY())
		var/length = sqrt(delta_x * delta_x + delta_y * delta_y)
		delta_x /= length
		delta_y /= length
		if (!length(shuttle_data.shuttle_weapons) || shuttle_data.current_ship_integrity < shuttle_data.max_ship_integrity * integrity_flee_limit)
			// If we have no weapons or are injured, attempt to get out of range of the enemy ship
			set_target_position(shuttle, target_shuttle.position.GetX() + delta_x * 5000, target_shuttle.position.GetY() + delta_y * 5000)
		else
			//Move closer to the enemy, but not close enough to be within interdiction range
			//Calculate position
			set_target_position(shuttle, target_shuttle.position.GetX() + delta_x * combat_range, target_shuttle.position.GetY() + delta_y * combat_range)

/datum/shuttle_ai_pilot/npc/proc/set_target_position(datum/orbital_object/shuttle/shuttle, x, y)
	if(!shuttle.shuttleTargetPos)
		shuttle.shuttleTargetPos = new(x, y)
	else
		shuttle.shuttleTargetPos.Set(x, y)

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
			their_ship.faction.on_attacked_by(shuttle_data.faction)
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
	var/datum/orbital_object/shuttle/our_shuttle = SSorbits.assoc_shuttles[shuttle_data.port_id]
	if(!our_shuttle)
		return
	var/list/valid = list()
	//Locate all ships on this z-level
	for (var/shuttle_id in SSorbits.assoc_shuttle_data)
		//Check factional aliegence (Can't spell that word)
		var/datum/shuttle_data/target_data = SSorbits.get_shuttle_data(shuttle_id)
		if(!(shuttle_data.faction.check_faction_alignment(target_data.faction) == FACTION_STATUS_HOSTILE || (shuttle_data.faction.type in target_data.rogue_factions)))
			continue
		var/datum/orbital_object/shuttle/target_shuttle = SSorbits.assoc_shuttles[target_data.port_id]
		//Target is not in supercruise
		if (!target_shuttle)
			continue
		//Target is not in radar range
		if (target_shuttle.position.DistanceTo(our_shuttle.position) > shuttle_data.detection_range)
			continue
		valid += target_data
	if(!length(valid))
		return
	target = pick(valid)
	//Now that we have found our target, register relevent signals to prevent hard del
	RegisterSignal(target, COMSIG_PARENT_QDELETING, .proc/lose_target)

/datum/shuttle_ai_pilot/npc/proc/set_target_location(datum/orbital_object/_shuttleTarget)
	if(shuttleTarget)
		UnregisterSignal(shuttleTarget, COMSIG_PARENT_QDELETING)
	shuttleTarget = _shuttleTarget
	if(shuttleTarget)
		RegisterSignal(shuttleTarget, COMSIG_PARENT_QDELETING, .proc/target_deleted)

/datum/shuttle_ai_pilot/npc/proc/target_deleted(datum/source, force)
	UnregisterSignal(shuttleTarget, COMSIG_PARENT_QDELETING)
	shuttleTarget = null

/datum/shuttle_ai_pilot/npc/get_target_name()
	return shuttleTarget?.name || "None"

/datum/shuttle_ai_pilot/npc/try_toggle()
	return FALSE

/datum/shuttle_ai_pilot/npc/is_active()
	return TRUE
