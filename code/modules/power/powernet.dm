////////////////////////////////////////////
// POWERNET DATUM
// each contiguous network of cables & nodes
/////////////////////////////////////
/datum/powernet
	var/number					// unique id
	var/list/cables = list()	// all cables & junctions
	var/list/nodes = list()		// all connected machines

	var/load = 0				// the current load on the powernet, increased by each machine at processing
	var/newavail = 0			// what available power was gathered last tick, then becomes...
	var/avail = 0				//...the current available power in the powernet
	var/viewavail = 0			// the available power as it appears on the power console (gradually updated)
	var/viewload = 0			// the load as it appears on the power console (gradually updated)
	var/netexcess = 0			// excess power on the powernet (typically avail-load)///////
	var/delayedload = 0			// load applied to powernet between power ticks.
	var/dirty = FALSE			// Is this powernet queued for a full reconsolidation in the powernet subsystem?

/datum/powernet/New()
	SSmachines.powernets += src
	// Unique index for this powernet
	number = ++SSmachines.unique_powernets

/datum/powernet/Destroy()
	//Go away references, you suck!
	for(var/obj/structure/cable/C in cables)
		cables -= C
		C.powernet = null
	for(var/obj/machinery/power/M in nodes)
		nodes -= M
		M.powernet = null

	SSmachines.powernets -= src
	return ..()

/datum/powernet/proc/is_empty()
	return !cables.len && !nodes.len

//remove a cable from the current powernet
//if the powernet is then empty, delete it
//Warning : this proc DON'T check if the cable exists
/datum/powernet/proc/remove_cable(obj/structure/cable/C)
	cables -= C
	C.powernet = null
	if(is_empty())//the powernet is now empty...
		qdel(src)///... delete it
	else
		// We need to revalidate the powernet's connectivity
		mark_dirty()

//add a cable to the current powernet
//Warning : this proc DON'T check if the cable exists
/datum/powernet/proc/add_cable(obj/structure/cable/C)
	if(C.powernet)// if C already has a powernet...
		if(C.powernet == src)
			return
		else
			C.powernet.remove_cable(C) //..remove it
	C.powernet = src
	cables += C

//remove a power machine from the current powernet
//if the powernet is then empty, delete it
//Warning : this proc DON'T check if the machine exists
/datum/powernet/proc/remove_machine(obj/machinery/power/M)
	nodes -=M
	M.powernet = null
	if(is_empty())//the powernet is now empty...
		qdel(src)///... delete it

//add a power machine to the current powernet
//Warning : this proc DON'T check if the machine exists
/datum/powernet/proc/add_machine(obj/machinery/power/M)
	if(M.powernet)// if M already has a powernet...
		if(M.powernet == src)
			return
		else
			M.disconnect_from_network()//..remove it
	M.powernet = src
	nodes[M] = M

//handles the power changes in the powernet
//called every ticks by the powernet controller
/datum/powernet/proc/reset()
	//see if there's a surplus of power remaining in the powernet and stores unused power in the SMES
	netexcess = avail - load

	if(netexcess > 100 && nodes && length(nodes))		// if there was excess power last cycle
		for(var/obj/machinery/power/smes/S in nodes)	// find the SMESes in the network
			S.restore()				// and restore some of the power that was used

	// update power consoles
	viewavail = round(0.8 * viewavail + 0.2 * avail)
	viewload = round(0.8 * viewload + 0.2 * load)

	// reset the powernet
	load = delayedload
	delayedload = 0
	avail = newavail
	newavail = 0

/datum/powernet/proc/get_electrocute_damage()
	if(avail >= 1000)
		return clamp(20 + round(avail/25000), 20, 195) + rand(-5,5)
	else
		return 0

/// Mark the powernet as dirty and needing cable recalulation.
/// This will queue it in the powernet propogation system, which will then fire
/// prior to machines ticking.
/datum/powernet/proc/mark_dirty()
	SSmachines.queue_recalculation(src)

/obj/structure/cable/var/_last_repropogation_update

/// Repropogate the cables on the network, and make sure that all points along our
/// cables are reachable from any other point in the cable.
/datum/powernet/proc/repropogate_cables()
	var/list/powernet_id_array = list()
	// We need a unique propogation identifier to be able to determine if the cable
	// was queued by this propogation run
	var/unique_propogation_identifier = ++SSmachines.unique_powernets
	for (var/i in 1 to length(cables))
		// We already belong
		var/obj/structure/cable/processing_wire = cables[i]
		if (powernet_id_array[processing_wire] != null)
			continue
		var/datum/powernet/new_powernet = i == 1 ? src : new /datum/powernet
		var/list/to_process = list(processing_wire)
		processing_wire._last_repropogation_update = unique_propogation_identifier
		// Process all nodes that can be reached
		while (length(to_process))
			processing_wire = to_process[to_process.len]
			to_process.len--
			powernet_id_array[processing_wire] = new_powernet
			// Process adjacent nodes
			for (var/obj/structure/cable/linked_cable as anything in processing_wire.connected)
				if (linked_cable._last_repropogation_update != unique_propogation_identifier)
					linked_cable._last_repropogation_update = unique_propogation_identifier
					to_process += linked_cable
	for (var/obj/structure/cable/processing_wire as() in powernet_id_array)
		var/datum/powernet/new_powernet = powernet_id_array[processing_wire]
		new_powernet.add_cable(processing_wire)
		// Get connected machines
		if (!processing_wire.has_power_node)
			continue
		for (var/obj/machinery/power/powered_machine in processing_wire.loc)
			if (!powered_machine.anchored)
				continue
			if (!powered_machine.connect_to_network())
				powered_machine.disconnect_from_network()
