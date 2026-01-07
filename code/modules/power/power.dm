//////////////////////////////
// POWER MACHINERY BASE CLASS
//////////////////////////////

/////////////////////////////
// Definitions
/////////////////////////////

/obj/machinery/power
	name = null
	icon = 'icons/obj/power.dmi'
	anchored = TRUE
	obj_flags = CAN_BE_HIT | ON_BLUEPRINTS
	var/datum/powernet/powernet = null
	use_power = NO_POWER_USE
	idle_power_usage = 0
	active_power_usage = 0

/obj/machinery/power/Destroy()
	disconnect_from_network()
	return ..()

///////////////////////////////
// General procedures
//////////////////////////////

// common helper procs for all power machines
// All power generation handled in add_avail()
// Machines should use add_load(), surplus(), avail()
// Non-machines should use add_delayedload(), delayed_surplus(), newavail()

/obj/machinery/power/proc/add_avail(amount)
	if(powernet)
		powernet.newavail += amount
		return TRUE
	else
		return FALSE

/obj/machinery/power/proc/add_load(amount)
	if(powernet)
		powernet.load += amount

/obj/machinery/power/proc/surplus()
	if(!powernet)
		return 0
	return powernet.avail - powernet.load

/obj/machinery/power/proc/avail(amount)
	if(powernet)
		return amount ? powernet.avail >= amount : powernet.avail
	else
		return 0

/obj/machinery/power/proc/add_delayedload(amount)
	if(powernet)
		powernet.delayedload += amount

/obj/machinery/power/proc/delayed_surplus()
	if(powernet)
		return clamp(powernet.newavail - powernet.delayedload, 0, powernet.newavail)
	else
		return 0

/obj/machinery/power/proc/newavail()
	if(powernet)
		return powernet.newavail
	else
		return 0

/obj/machinery/power/proc/disconnect_terminal() // machines without a terminal will just return, no harm no fowl.
	return

// returns true if the area has power on given channel (or doesn't require power).
// defaults to power_channel
/obj/machinery/proc/powered(chan = power_channel)
	if(!use_power)
		return TRUE
	if(!loc)
		return FALSE
	if(machine_stat & (EMPED|OVERHEATED))
		return FALSE
	var/area/A = get_area(src)		// make sure it's in an area
	if(!A)
		return FALSE					// if not, then not powered
	return A.powered(chan)	// return power status of the area

// increment the power usage stats for an area
/obj/machinery/proc/use_power(amount, chan = power_channel)
	var/area/A = get_area(src) // make sure it's in an area
	A?.use_power(amount, chan)
	SEND_SIGNAL(src, COMSIG_MACHINERY_POWER_USED, amount, chan)

/**
  * An alternative to 'use_power', this proc directly costs the APC in direct charge, as opposed to being calculated periodically.
  * - Amount: How much power the APC's cell is to be costed.
  */
/obj/machinery/proc/directly_use_power(amount)
	var/area/A = get_area(src)
	var/obj/machinery/power/apc/local_apc
	if(!A)
		return FALSE
	local_apc = A.apc
	if(!local_apc)
		return FALSE
	if(!local_apc.cell)
		return FALSE
	local_apc.cell.use(amount)
	return TRUE

/**
  * Attempts to draw power directly from the APC's Powernet rather than the APC's battery. For high-draw machines, like the cell charger
  *
  * Checks the surplus power on the APC's powernet, and compares to the requested amount. If the requested amount is available, this proc
  * will add the amount to the APC's usage and return that amount. Otherwise, this proc will return FALSE.
  * If the take_any var arg is set to true, this proc will use and return any surplus that is under the requested amount, assuming that
  * the surplus is above zero.
  * Args:
  * - amount, the amount of power requested from the Powernet. In standard loosely-defined SS13 power units.
  * - take_any, a bool of whether any amount of power is acceptable, instead of all or nothing. Defaults to FALSE
 */
/obj/machinery/proc/use_power_from_net(amount, take_any = FALSE)
	if(amount <= 0) //just in case
		return FALSE
	var/area/home = get_area(src)

	if(!home)
		return FALSE //apparently space isn't an area
	if(!home.requires_power)
		return amount //Non-power eaters get free power, don't ask why
	if(!home.always_unpowered)
		return amount //Ruins get free power, don't ask why

	var/obj/machinery/power/apc/local_apc = home.apc
	if(!local_apc)
		return FALSE
	var/surplus = local_apc.surplus()
	if(surplus <= 0) //I don't know if powernet surplus can ever end up negative, but I'm just gonna failsafe it
		return FALSE
	if(surplus < amount)
		if(!take_any)
			return FALSE
		amount = surplus
	local_apc.add_load(amount)
	return amount

/obj/machinery/proc/addStaticPower(value, powerchannel)
	var/area/A = get_area(src)
	A?.addStaticPower(value, powerchannel)

/obj/machinery/proc/removeStaticPower(value, powerchannel)
	addStaticPower(-value, powerchannel)

/**
  * Called whenever the power settings of the containing area change
  *
  * by default, check equipment channel & set flag, can override if needed
  *
  * Returns TRUE if the NOPOWER flag was toggled
  */
/obj/machinery/proc/power_change()
	SIGNAL_HANDLER
	SHOULD_CALL_PARENT(TRUE)

	if(machine_stat & BROKEN)
		update_appearance()
		return
	if(powered(power_channel))
		if(machine_stat & NOPOWER)
			SEND_SIGNAL(src, COMSIG_MACHINERY_POWER_RESTORED)
			. = TRUE
		set_machine_stat(machine_stat & ~NOPOWER)
	else
		if(!(machine_stat & NOPOWER))
			SEND_SIGNAL(src, COMSIG_MACHINERY_POWER_LOST)
			. = TRUE
		set_machine_stat(machine_stat | NOPOWER)
	update_appearance()

// connect the machine to a powernet if a node cable is present on the turf
/obj/machinery/power/proc/connect_to_network(turf/turf = loc)
	var/turf/T = turf
	if(!T || !istype(T))
		return FALSE

	var/obj/structure/cable/C = T.get_cable_node() //check if we have a node cable on the machine turf, the first found is picked
	if(!C || !C.powernet)
		return FALSE

	C.powernet.add_machine(src)
	return TRUE

// remove and disconnect the machine from its current powernet
/obj/machinery/power/proc/disconnect_from_network()
	if(!powernet)
		return FALSE
	powernet.remove_machine(src)
	return TRUE

// attach a wire to a power machine - leads from the turf you are standing on
//almost never called, overwritten by all power machines but terminal and generator
/obj/machinery/power/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/coil = W
		var/turf/T = user.loc
		if(T.underfloor_accessibility < UNDERFLOOR_INTERACTABLE || !isfloorturf(T))
			return
		if(get_dist(src, user) > 1)
			return
		coil.place_turf(T, user)
	else
		return ..()


///////////////////////////////////////////
// Powernet handling helpers
//////////////////////////////////////////

//returns all the cables WITHOUT a powernet in neighbors turfs,
//pointing towards the turf the machine is located at
/obj/machinery/power/proc/get_connections()

	. = list()

	var/cdir
	var/turf/T

	for(var/card in GLOB.cardinals)
		T = get_step(loc,card)
		cdir = get_dir(T,loc)

		for(var/obj/structure/cable/C in T)
			if(C.powernet)
				continue
			if(C.d1 == cdir || C.d2 == cdir)
				. += C
	return .

//returns all the cables in neighbors turfs,
//pointing towards the turf the machine is located at
/obj/machinery/power/proc/get_marked_connections()

	. = list()

	var/cdir
	var/turf/T

	for(var/card in GLOB.cardinals)
		T = get_step(loc,card)
		cdir = get_dir(T,loc)

		for(var/obj/structure/cable/C in T)
			if(C.d1 == cdir || C.d2 == cdir)
				. += C
	return .

//returns all the NODES (O-X) cables WITHOUT a powernet in the turf the machine is located at
/obj/machinery/power/proc/get_indirect_connections()
	. = list()
	for(var/obj/structure/cable/C in loc)
		if(C.powernet)
			continue
		if(C.d1 == 0) // the cable is a node cable
			. += C
	return .

/obj/machinery/power/lateShuttleMove(turf/oldT, list/movement_force, move_dir)
	. = ..()
	disconnect_from_network()
	connect_to_network()

///////////////////////////////////////////
// GLOBAL PROCS for powernets handling
//////////////////////////////////////////


// returns a list of all power-related objects (nodes, cable, junctions) in turf,
// excluding source, that match the direction d
// if unmarked==1, only return those with no powernet
/proc/power_list(turf/T, source, d, unmarked=0, cable_only = 0)
	. = list()

	for(var/AM in T)
		if(AM == source)
			continue			//we don't want to return source

		if(!cable_only && istype(AM, /obj/machinery/power))
			var/obj/machinery/power/P = AM
			if(P.powernet == 0)
				continue		// exclude APCs which have powernet=0

			if(!unmarked || !P.powernet)		//if unmarked=1 we only return things with no powernet
				if(d == 0)
					. += P

		else if(istype(AM, /obj/structure/cable))
			var/obj/structure/cable/C = AM

			if(!unmarked || !C.powernet)
				if(C.d1 == d || C.d2 == d)
					. += C
	return .

//remove the old powernet and replace it with a new one throughout the network.
/proc/propagate_network(obj/O, datum/powernet/PN)
	var/list/worklist = list()
	var/list/found_machines = list()
	var/index = 1
	var/obj/P = null

	worklist+=O //start propagating from the passed object

	while(index<=worklist.len) //until we've exhausted all power objects
		P = worklist[index] //get the next power object found
		index++

		if( istype(P, /obj/structure/cable))
			var/obj/structure/cable/C = P
			if(C.powernet != PN) //add it to the powernet, if it isn't already there
				PN.add_cable(C)
			worklist |= C.get_connections() //get adjacents power objects, with or without a powernet

		else if(P.anchored && istype(P, /obj/machinery/power))
			found_machines |= P //we wait until the powernet is fully propagates to connect the machines

		else
			continue

	//now that the powernet is set, connect found machines to it
	for(var/obj/machinery/power/PM as() in found_machines)
		if(!PM.connect_to_network()) //couldn't find a node on its turf...
			PM.disconnect_from_network() //... so disconnect if already on a powernet


//Merge two powernets, the bigger (in cable length term) absorbing the other
/proc/merge_powernets(datum/powernet/net1, datum/powernet/net2)
	if(!net1 || !net2) //if one of the powernet doesn't exist, return
		return

	if(net1 == net2) //don't merge same powernets
		return

	//We assume net1 is larger. If net2 is in fact larger we are just going to make them switch places to reduce on code.
	if(net1.cables.len < net2.cables.len)	//net2 is larger than net1. Let's switch them around
		var/temp = net1
		net1 = net2
		net2 = temp

	//merge net2 into net1
	for(var/obj/structure/cable/Cable in net2.cables) //merge cables
		net1.add_cable(Cable)

	for(var/obj/machinery/power/Node in net2.nodes) //merge power machines
		if(!Node.connect_to_network())
			Node.disconnect_from_network() //if somehow we can't connect the machine to the new powernet, disconnect it from the old nonetheless

	return net1


/// Extracts the powernet and cell of the provided power source
/proc/get_powernet_info_from_source(power_source)
	var/area/source_area
	if(isarea(power_source))
		source_area = power_source
		power_source = source_area.apc
	else if (istype(power_source, /obj/structure/cable))
		var/obj/structure/cable/Cable = power_source
		power_source = Cable.powernet

	var/datum/powernet/PN
	var/obj/item/stock_parts/cell/cell

	if(istype(power_source, /datum/powernet))
		PN = power_source
	else if(istype(power_source, /obj/item/stock_parts/cell))
		cell = power_source
	else if(istype(power_source, /obj/machinery/power/apc))
		var/obj/machinery/power/apc/apc = power_source
		cell = apc.cell
		if (apc.terminal)
			PN = apc.terminal.powernet
	else
		return FALSE
	if (!cell && !PN)
		return

	return list("powernet" = PN, "cell" = cell)

//Determines how strong could be shock, deals damage to mob, uses power.
//M is a mob who touched wire/whatever
//power_source is a source of electricity, can be power cell, area, apc, cable, powernet or null
//source is an object caused electrocuting (airlock, grille, etc)
//siemens_coeff - layman's terms, conductivity
//dist_check - set to only shock mobs within 1 of source (vendors, airlocks, etc.)
//No animations will be performed by this proc.
/proc/electrocute_mob(mob/living/carbon/victim, power_source, obj/source, siemens_coeff = 1, dist_check = FALSE)
	if(!istype(victim) || ismecha(victim.loc))
		return FALSE //feckin mechs are dumb
	if(dist_check)
		if(!in_range(source, victim))
			return FALSE

	if(victim.wearing_shock_proof_gloves())
		SEND_SIGNAL(victim, COMSIG_LIVING_SHOCK_PREVENTED, power_source, source, siemens_coeff, dist_check)
		return FALSE //to avoid spamming with insulated glvoes on

	var/list/powernet_info = get_powernet_info_from_source(power_source)
	if (!powernet_info)
		return FALSE

	var/datum/powernet/PN = powernet_info["powernet"]
	var/obj/item/stock_parts/cell/cell = powernet_info["cell"]

	var/PN_damage = 0
	var/cell_damage = 0
	if (PN)
		PN_damage = PN.get_electrocute_damage()
	if (cell)
		cell_damage = cell.get_electrocute_damage()
	var/shock_damage = 0
	if (PN_damage >= cell_damage)
		power_source = PN
		shock_damage = PN_damage
	else
		power_source = cell
		shock_damage = cell_damage
	var/drained_hp = victim.electrocute_act(shock_damage, source, siemens_coeff) //zzzzzzap!
	log_combat(source, victim, "electrocuted")

	var/drained_energy = drained_hp*20

	if (isarea(power_source))
		var/area/source_area = power_source
		source_area.use_power(drained_energy)
	else if (istype(power_source, /datum/powernet))
		var/drained_power = drained_energy
		PN.delayedload += (min(drained_power, max(PN.newavail - PN.delayedload, 0)))
	else if (istype(power_source, /obj/item/stock_parts/cell))
		cell.use(drained_energy)
	return drained_energy

////////////////////////////////////////////////
// Misc.
///////////////////////////////////////////////


// return a knot cable (O-X) if one is present in the turf
// null if there's none
/turf/proc/get_cable_node()
	if(!can_have_cabling())
		return null
	for(var/obj/structure/cable/C in src)
		if(C.d1 == 0)
			return C
	return null
