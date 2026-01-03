SUBSYSTEM_DEF(machines)
	name = "Machines"
	dependencies = list(
		/datum/controller/subsystem/atoms,
	)
	flags = SS_KEEP_TIMING
	wait = 2 SECONDS
	var/list/processing = list()
	var/list/currentrun = list()
	var/list/powernets = list()
	var/list/dirty_powernets = list()
	var/dirty_index = 1
	var/dirty_stop_index
	var/unique_powernets = 0

/datum/controller/subsystem/machines/Initialize()
	makepowernets()
	fire()
	return SS_INIT_SUCCESS

/datum/controller/subsystem/machines/get_metrics()
	. = ..()
	var/list/cust = list()
	cust["processing"] = length(processing)
	cust["powernets"] = length(powernets)
	.["custom"] = cust

/datum/controller/subsystem/machines/proc/makepowernets()
	for(var/datum/powernet/power_network as anything in powernets)
		qdel(power_network)
	powernets.Cut()

	var/datum/powernet/new_powernet = new()
	for(var/obj/structure/cable/PC in GLOB.cable_list)
		new_powernet.add_cable(PC)
	new_powernet.repropogate_cables()
	new_powernet.dirty = FALSE
	dirty_powernets.len = 0

/datum/controller/subsystem/machines/stat_entry(msg)
	msg = "M:[length(processing)]|PN:[length(powernets)]"
	return ..()

/datum/controller/subsystem/machines/fire(resumed = FALSE)
	if (!resumed)
		for(var/datum/powernet/powernet as anything in powernets)
			powernet.reset() //reset the power state.
		src.currentrun = processing.Copy()
		dirty_index = 1
		dirty_stop_index = length(dirty_powernets)

	// Start processing dirty powernets
	while (dirty_powernets.len && dirty_index <= dirty_stop_index && dirty_index <= length(dirty_powernets))
		// Get the element to process
		var/datum/powernet/first_powernet = dirty_powernets[dirty_index]
		// Move the last element to our current position in the queue
		dirty_powernets[dirty_index] = dirty_powernets[length(dirty_powernets)]
		// Increment the dirty index, to point to the next element
		// If we needed to process the element we just moved to the start
		// then don't increment, so we process that element
		// Note that dirty powernets won't be processed in-order, but they
		// will always be processed by the end of the machines tick after the
		// one that they were added on.
		if (dirty_stop_index <= length(dirty_powernets))
			dirty_index ++
		// Shorten the queue without needing to propogate the entire list
		dirty_powernets.len--
		// Do processing
		first_powernet.dirty = FALSE
		first_powernet.repropogate_cables()
		// Explicitly doesn't use SPLIT_TICK because we need to recalibrate the powernets
		// before we calculate power consumption, otherwise machines not connected may
		// get 1 tick of bluespace power transfer.
		if (MC_TICK_CHECK)
			return

	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun

	while(currentrun.len)
		var/obj/machinery/thing = currentrun[currentrun.len]
		currentrun.len--
		if(QDELETED(thing) || thing.process(wait * 0.1) == PROCESS_KILL)
			processing -= thing
			thing.datum_flags &= ~DF_ISPROCESSING
		if (MC_TICK_CHECK)
			return

/datum/controller/subsystem/machines/proc/setup_template_powernets(list/cables)
	var/obj/structure/cable/PC
	var/datum/powernet/NewPN = new()
	for(var/A in 1 to cables.len)
		PC = cables[A]
		NewPN.add_cable(PC)
	NewPN.repropogate_cables()
	NewPN.dirty = FALSE
	dirty_powernets.len = 0

/datum/controller/subsystem/machines/Recover()
	if (istype(SSmachines.processing))
		processing = SSmachines.processing
	if (istype(SSmachines.powernets))
		powernets = SSmachines.powernets

/datum/controller/subsystem/machines/proc/queue_recalculation(datum/powernet/powernet)
	if (powernet.dirty)
		return
	dirty_powernets += powernet
	powernet.dirty = TRUE
