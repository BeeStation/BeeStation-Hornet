//Perform debug checks to see if the data matches with the turfs.
//Expensive, so disable unless you find an issue with shuttles going out of
//sync.
//#define DEBUG_SYNC_CHECK

/datum/shuttle_data
	/// The name of the shuttle
	var/shuttle_name
	/// Port ID of the shuttle
	var/port_id
	///The AI Pilot flying this shuttle
	var/datum/shuttle_ai_pilot/ai_pilot = null
	/// List of engine heaters
	var/list/obj/machinery/shuttle/engine/registered_engines = list()
	/// Stored shield power
	var/shield_health = 0
	/// Calculate fuel consumption rate
	var/fuel_consumption
	/// Is this shuttle stealthed?
	var/stealth = FALSE
	/// The thrust of the shuttle
	/// Updates when engines run out of fuel, are dismantled or created
	var/thrust
	/// The mass of the shuttle
	/// Updated when the shuttle size is changed
	var/mass
	/// Detection radius
	var/detection_range = 1500
	/// Interidction range
	var/interdiction_range = 150
	///The maximum value of the ship integrity. This goes up as the ship is expanded/built upon and will not go down.
	var/max_ship_integrity
	///The current ship integrity value. If this gets too low, then the ship will explode.
	var/current_ship_integrity
	///The amount of integrity currently remaining before the ship explodes
	var/integrity_remaining
	///Is the shuttle doomed to explode?
	var/reactor_critical = FALSE
	///How much damage can the ship sustain before exploding?
	var/critical_proportion = SHIP_INTEGRITY_FACTOR_PLAYER
	///The faction instance of this shuttle
	var/datum/faction/faction
	///Fired upon these factions despite being allied with them. Any ships in that faction will fire upon this ship.
	///FACTIONS THAT WE ARE ROGUE TO, NOT FACTIONS THAT ARE ROGUE TO US. ADDING TO LIST LIST DECLARES THIS SHIP AS HOSTILE TO THAT FACTION
	///Note: This will have a butterfly effect and end in an all out war between ships which is pretty funny.
	///Example:
	/// - Player ship A fires on NPC trading ship
	/// - Player ship A declared rogue to NPC trading ships
	/// - Another NPC trading faction ship comes across player ship and fires upon it
	/// - That NPC trading ship is now declared hostile to the player ships faction.
	/// - The cycle continues.
	///Note: Doesn't take into account subtypes.
	var/list/rogue_factions = list()
	///Weapon systems
	var/list/obj/machinery/shuttle_weapon/shuttle_weapons = list()
	///List of registered turfs, so we can unregister them if needed
	var/list/turf/registered_turfs = list()
	///Communications manager
	var/datum/orbital_comms_manager/comms

/datum/shuttle_data/New(port_id)
	. = ..()
	//Setup the port ID
	src.port_id = port_id
	//Get the docking port
	var/obj/docking_port/mobile/attached_port = SSshuttle.getShuttle(port_id)
	shuttle_name = attached_port.name
	calculate_initial_stats()
	if (!faction)
		faction = new /datum/faction/independant

/datum/shuttle_data/Destroy(force, ...)
	unregister_turfs()
	. = ..()
	log_shuttle("Shuttle data [shuttle_name] ([port_id]) was deleted.")

/// Private
/// Calculates the initial stats of the shuttle
/datum/shuttle_data/proc/calculate_initial_stats()
	PRIVATE_PROC(TRUE)
	var/obj/docking_port/mobile/mobile_port = SSshuttle.getShuttle(port_id)
	mass = 5
	for(var/area/shuttle_area as() in mobile_port.shuttle_areas)
		//Check turfs
		for(var/turf/T in shuttle_area)
			if(!isspaceturf(T))
				mass ++
		//Handle shuttle engines
		for(var/obj/machinery/shuttle/engine/shuttle_engine in shuttle_area)
			register_thruster(shuttle_engine)
		//Handle shuttle weapons
		for(var/obj/machinery/shuttle_weapon/shuttle_weapon in shuttle_area)
			register_weapon_system(shuttle_weapon)
	//Calculate integrity
	recalculate_integrity()

//====================
// Integrity / Damage
//====================

/// Perform a full recalculation of ship integrity
/datum/shuttle_data/proc/debug_integrity()
	//Reset ship integrity to 0
	. = 0
	//Get the docking port
	var/obj/docking_port/mobile/M = SSshuttle.getShuttle(port_id)
	//Perform calculations
	for(var/turf/T in M.return_turfs())
		//Ignore non-shuttle turfs
		if (!islist(T.baseturfs) || !T.baseturfs.Find(/turf/baseturf_skipover/shuttle))
			continue
		if(!iswallturf(T) && !isfloorturf(T))
			continue
		//Check the type
		if (iswallturf(T))
			if(istype(T, /turf/closed/wall/r_wall))
				. += 15
			else
				. += 10
			continue
		//2 points if the floor isn't raw plating
		if (!isplatingturf(T))
			. += 5

/// Perform a full recalculation of ship integrity
/datum/shuttle_data/proc/recalculate_integrity()
	//Reset turfs
	unregister_turfs()
	//Reset ship integrity to 0
	max_ship_integrity = 0
	mass = 5
	//Get the docking port
	var/obj/docking_port/mobile/M = SSshuttle.getShuttle(port_id)
	//Perform calculations
	for(var/turf/T in M.return_turfs())
		//Ignore non-shuttle turfs
		if (!islist(T.baseturfs) || !T.baseturfs.Find(/turf/baseturf_skipover/shuttle))
			continue
		if(!isspaceturf(T))
			mass ++
		RegisterSignal(T, COMSIG_TURF_CHANGE, PROC_REF(shuttle_turf_changed))
		RegisterSignal(T, COMSIG_TURF_AFTER_SHUTTLE_MOVE, PROC_REF(shuttle_turf_moved))
		registered_turfs += T
		//Register these turfs too!
		if(!iswallturf(T) && !isfloorturf(T))
			continue
		//Check the type
		if (iswallturf(T))
			if(istype(T, /turf/closed/wall/r_wall))
				max_ship_integrity += 15
			else
				max_ship_integrity += 10
			continue
		//If floor turf
		//2 points if the floor isn't raw plating
		if (!isplatingturf(T))
			max_ship_integrity += 5
	//Finished calculating
	log_shuttle("Recalculated shuttle health for [shuttle_name] ([port_id]). Shuttle now has an integrity rating of [max_ship_integrity]")
	//Integrity remaining will always be max health, as this is our reference point
	integrity_remaining = max_ship_integrity
	current_ship_integrity = max_ship_integrity
	update_integrity()

/datum/shuttle_data/proc/unregister_turfs()
	for(var/T in registered_turfs)
		UnregisterSignal(T, COMSIG_TURF_CHANGE)
		UnregisterSignal(T, COMSIG_TURF_AFTER_SHUTTLE_MOVE)
	mass = 5
	registered_turfs.Cut()

///Call after updating the value of current_ship_integrity
/datum/shuttle_data/proc/update_integrity()
	if(reactor_critical)
		current_ship_integrity = 0
		integrity_remaining = 0
		return
	max_ship_integrity = max(current_ship_integrity, max_ship_integrity)
	integrity_remaining = current_ship_integrity - (max_ship_integrity * critical_proportion)
	log_shuttle("Shuttle [shuttle_name] ([port_id]) now has [current_ship_integrity]/[max_ship_integrity] integrity ([integrity_remaining] until destruction.)")
	//Calculate destruction
	if(integrity_remaining <= 0)
		var/obj/docking_port/mobile/M = SSshuttle.getShuttle(port_id)
		message_admins("Shuttle [shuttle_name] ([port_id]) has been destroyed at [ADMIN_FLW(M)]")
		log_shuttle_attack("Shuttle [shuttle_name] ([port_id]) has been destroyed at [COORD(M)]")
		//You are dead
		reactor_critical = TRUE
		current_ship_integrity = 0
		integrity_remaining = 0
		unregister_turfs()
		//Strand the shuttle
		var/datum/orbital_object/shuttle/located_shuttle = SSorbits.assoc_shuttles[port_id]
		if (located_shuttle)
			located_shuttle.strand_shuttle()
		//Unregister all turfs
		for(var/area/A in M.shuttle_areas)
			for(var/obj/machinery/light/L in A)
				L.force_emergency_mode = TRUE
				L.update()
		//Play an alarm to anyone / any observers on the shuttle
		for(var/client/C as() in GLOB.clients)
			var/mob/client_mob = C.mob
			var/area/shuttle/A = get_area(client_mob)
			if(istype(A) && A.mobile_port == M)
				SEND_SOUND(C, 'sound/machines/alarm.ogg')
				to_chat(C, "<span class='danger'>You hear a rumbling from the ship's reactor, it sounds like it's about to implode...</span>")
		//Cause the big boom
		addtimer(CALLBACK(src, PROC_REF(destroy_ship), M), 140)

/datum/shuttle_data/proc/destroy_ship(obj/docking_port/mobile/M)
	set waitfor = FALSE
	var/exploded = FALSE
	var/area/shuttle/area = get_area(M)
	var/obj/machinery/power/apc/apc = area.get_apc()
	//No more power
	if(apc)
		apc.set_broken()
	//No explosion, explode anyway
	//Prevents an exploit where you can make a tiny ship to maxcap the station
	var/turf/any_turf = pick(M.return_turfs())
	if(max_ship_integrity > 20 && !SSmapping.level_has_any_trait(any_turf.z, list(ZTRAIT_STATION)))
		if(!exploded)
			explosion(any_turf, 12, 15, 18, -1, FALSE)
	//Force delete the docking port
	//We totally know what we are doing
	M.delete_on_land = TRUE

///Called when a shuttle turf is changed, for better or for worse
/datum/shuttle_data/proc/shuttle_turf_changed(turf/source, path, list/new_baseturfs, flags, list/transferring_comps)
	//Only update if there are shuttle baseturfs here
	if (islist(source.baseturfs) && source.baseturfs.Find(/turf/baseturf_skipover/shuttle))
		if(!isspaceturf(source))
			mass --
		//Subtract the old integrity
		if (iswallturf(source))
			if(istype(source, /turf/closed/wall/r_wall))
				current_ship_integrity -= 15
			else
				current_ship_integrity -= 10
		else if(isfloorturf(source))
			//2 points if the floor isn't raw plating
			if (!isplatingturf(source))
				current_ship_integrity -= 5
	//Only update if there are still shuttle baseturfs here
	if ((new_baseturfs && islist(new_baseturfs) && new_baseturfs.Find(/turf/baseturf_skipover/shuttle))\
		|| (!new_baseturfs && islist(source.baseturfs) && source.baseturfs.Find(/turf/baseturf_skipover/shuttle)))
		if(!ispath(source, /turf/open/space))
			mass ++
		//Add the new integrity
		if (ispath(path, /turf/closed/wall))
			if(ispath(path, /turf/closed/wall/r_wall))
				current_ship_integrity += 15
			else
				current_ship_integrity += 10
		else if(ispath(path, /turf/open/floor))
			//2 points if the floor isn't raw plating
			if (!ispath(path, /turf/open/floor/plating))
				current_ship_integrity += 5
	//Update the integrity
	update_integrity()
#ifdef DEBUG_SYNC_CHECK
	//Spawn is awful, but this isn't on production code
	spawn(1)
		//Check
		var/debug_integrity = debug_integrity()
		if(debug_integrity != current_ship_integrity)
			message_admins("SHUTTLE INTEGRITY BECAME UNSYNCED AS A RESULT OF [source.type] CHANGING TO [path]. [current_ship_integrity] should be [debug_integrity]. SHUTTLE BEFORE: [islist(source.baseturfs) && source.baseturfs.Find(/turf/baseturf_skipover/shuttle)] SHUTTLE AFTER: [islist(new_baseturfs) && new_baseturfs.Find(/turf/baseturf_skipover/shuttle)]")
			current_ship_integrity = debug_integrity
#endif

///Called when a shuttle turf is changed, for better or for worse
/datum/shuttle_data/proc/shuttle_turf_moved(datum/source, turf/newturf)
	///We are no longer caring about this turf, find out where we went to
	UnregisterSignal(source, COMSIG_TURF_CHANGE, PROC_REF(shuttle_turf_changed))
	UnregisterSignal(source, COMSIG_TURF_AFTER_SHUTTLE_MOVE, PROC_REF(shuttle_turf_moved))
	registered_turfs -= source
	///Relocate
	RegisterSignal(newturf, COMSIG_TURF_CHANGE, PROC_REF(shuttle_turf_changed))
	RegisterSignal(newturf, COMSIG_TURF_AFTER_SHUTTLE_MOVE, PROC_REF(shuttle_turf_moved))
	registered_turfs += newturf

//====================
// Weapon Systems
//====================

/// Registers a weapon system
/datum/shuttle_data/proc/register_weapon_system(obj/machinery/shuttle_weapon/weapon)
	if(weapon in shuttle_weapons)
		return
	shuttle_weapons += weapon
	RegisterSignal(weapon, COMSIG_PARENT_QDELETING, PROC_REF(on_weapon_qdel))

/// Called when a weapon is deleted
/datum/shuttle_data/proc/on_weapon_qdel(obj/machinery/shuttle_weapon/weapon, force)
	shuttle_weapons -= weapon
	UnregisterSignal(weapon, COMSIG_PARENT_QDELETING)

//====================
// Fuel Consumption / Flight Processing
//====================

/datum/shuttle_data/proc/check_can_launch()
	//Check status of engines
	for(var/obj/machinery/shuttle/engine/shuttle_engine as() in registered_engines)
		shuttle_engine.update_engine()
	//Check thrust
	return thrust

//Consume fuel, check engine status
/datum/shuttle_data/proc/process_flight(thrust_amount = 0, delta_time)
	var/fuel_usage = thrust_amount * ORBITAL_UPDATE_RATE_SECONDS * 0.01 * delta_time
	for(var/obj/machinery/shuttle/engine/shuttle_engine as() in registered_engines)
		if(!shuttle_engine.thruster_active)
			continue
		shuttle_engine.fireEngine()
		shuttle_engine.consume_fuel(fuel_usage)

//Return true if shuttle can no longer fly
/datum/shuttle_data/proc/is_stranded()
	return !thrust

/datum/shuttle_data/proc/get_fuel()
	. = 0
	for(var/obj/machinery/shuttle/engine/shuttle_engine as() in registered_engines)
		if(!shuttle_engine.thruster_active)
			continue
		. += shuttle_engine.get_fuel_amount()

//====================
// Thrust handling
//====================

/// Called when a thruster is created on a shuttle
/datum/shuttle_data/proc/register_thruster(obj/machinery/shuttle/engine/source)
	if(source in registered_engines)
		return
	if(source.thruster_active)
		thrust += source.thrust
		fuel_consumption += source.fuel_use
	registered_engines += source
	RegisterSignal(source, COMSIG_PARENT_QDELETING, PROC_REF(on_thruster_qdel))
	RegisterSignal(source, COMSIG_SHUTTLE_ENGINE_STATUS_CHANGE, PROC_REF(on_thruster_state_change))

/// Called when a thruster is deleted
/datum/shuttle_data/proc/on_thruster_qdel(obj/machinery/shuttle/engine/source, force)
	if(source.thruster_active)
		fuel_consumption -= source.fuel_use
		thrust -= source.thrust
	registered_engines -= source
	UnregisterSignal(source, COMSIG_PARENT_QDELETING)
	UnregisterSignal(source, COMSIG_SHUTTLE_ENGINE_STATUS_CHANGE)

/// Called when a shuttle thruster changes state
/datum/shuttle_data/proc/on_thruster_state_change(obj/machinery/shuttle/engine/source, old_state, new_state)
	if(old_state == new_state)
		return
	if(new_state)
		//Shuttle was turned on
		thrust += source.thrust
		fuel_consumption += source.fuel_use
	else
		//Shuttle was turned off
		thrust -= source.thrust
		fuel_consumption -= source.fuel_use

/datum/shuttle_data/proc/get_thrust_force()
	return thrust / mass

//====================
// Shuttle Pilot
//====================

///public
///Sets the AI pilot of the shuttle to an AI pilot datum, handling
/datum/shuttle_data/proc/set_pilot(datum/shuttle_ai_pilot/pilot)
	if(ai_pilot)
		UnregisterSignal(ai_pilot, COMSIG_PARENT_QDELETING)
	ai_pilot = pilot
	ai_pilot.attach_to_shuttle(src)
	if(ai_pilot)
		RegisterSignal(ai_pilot, COMSIG_PARENT_QDELETING, PROC_REF(on_pilot_deleted))

///private
///Signal handler that handles dereferencing the ai_pilot when it is deleted
/datum/shuttle_data/proc/on_pilot_deleted(datum/source, force)
	PRIVATE_PROC(TRUE)
	UnregisterSignal(ai_pilot, COMSIG_PARENT_QDELETING)
	ai_pilot = null

///Public
///Attempts to override the current AI pilot
/datum/shuttle_data/proc/try_override_pilot(forced = FALSE)
	if(!ai_pilot)
		return TRUE
	if(!ai_pilot.overridable)
		return FALSE
	qdel(ai_pilot)
	var/datum/orbital_object/shuttle/shuttle_object = SSorbits.assoc_shuttles[port_id]
	if(shuttle_object)
		SEND_SIGNAL(shuttle_object, COMSIG_ORBITAL_BODY_MESSAGE, "Autopilot disengaged.")
	return TRUE
