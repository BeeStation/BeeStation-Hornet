/obj/structure/disposalpipe/var/_traversed = 0

/datum/unit_test/map_test/check_disposals
	var/failure_reason
	var/is_sorting_network
	var/run_id = 1
	var/list/blocked_report_strings = list()

// Find all entries into the disposal system
/datum/unit_test/map_test/check_disposals/collect_targets(list/turfs)
	var/located = list()
	for (var/turf/check_turf in turfs)
		var/found = locate(/obj/machinery/disposal) in check_turf
		if (found)
			located += found
	return located

// Make sure that we can end up in the correct location
/datum/unit_test/map_test/check_disposals/check_target(obj/machinery/disposal/target)
	var/list/failures = list()
	failure_reason = null
	is_sorting_network = null
	if (!target.trunk)
		return "[target.name] not attached to a trunk at [COORD(target)]."
	// Create a terrible disposal holder object
	var/obj/structure/disposalholder/holder = new()
	traverse_loop(holder, target.trunk, TRUE)
	if (failure_reason)
		failures += failure_reason
		failure_reason = null
	// This is fine, we probably are a bin that leads to space or something
	if (!is_sorting_network)
		return failures
	holder.last_pipe = null
	holder.current_pipe = null
	failure_reason = null
	// Since we have filters, lets make sure this is a proper, fully connected and fully functioning loop
	// We should be able to enter the loop at any point from an input gate to get to our destination
	var/i = 0
	var/failure_string = ""
	for (var/sort_code in GLOB.TAGGERLOCATIONS)
		i++
		if (sort_code in GLOB.disabled_tagger_locations)
			continue
		holder = new /obj/structure/disposalholder()
		holder.destinationTag = i
		var/atom/destination = traverse_loop(holder, target.trunk, TRUE)
		if (failure_reason)
			failures += failure_reason
			failure_reason = null
			continue
		var/arrived = FALSE
		for (var/valid_destination in GLOB.tagger_destination_areas[sort_code])
			if (istype(get_area(destination), valid_destination))
				arrived = TRUE
				break
		if (!arrived)
			failures += "Disposal track starting at [COORD(target)] does not end up in the correct destination. Expected [sort_code] ([i]), got [get_area(destination)] at [COORD(destination)]. [is_sorting_network]"
			failure_string += "-[sort_code]-"
	if (failure_string)
		if (failure_string in blocked_report_strings)
			failures = "Disposal track starting at [COORD(target)] also fails to reach the following locations: [failure_string]"
		else
			blocked_report_strings += failure_string
	return failures

/datum/unit_test/map_test/check_disposals/proc/traverse_loop(obj/structure/disposalholder/holder, obj/structure/disposalpipe/start, allow_inputs)
	// Increment run ID
	run_id++
	// First check to ensure that we end up somewhere
	var/obj/structure/disposalpipe/current = start
	holder.current_pipe = current
	holder.dir = current.dir || SOUTH
	var/has_looped = FALSE
	while (current)
		// Account for disposals shitcode
		holder.dir = istype(current, /obj/structure/disposalpipe/trunk) ? (current.dir || SOUTH) : current.nextdir(holder)
		var/turf/T = get_step(current, holder.dir)
		current = holder.findpipe(T)
		// End detection
		if (current == null)
			failure_reason = "Disposal network starting at [COORD(start)] has a pipe with no output at [COORD(T)] but should lead to an outlet. Holder was traversing [dir2text(holder.dir)] and was last at [COORD(holder.current_pipe)]. Sort code was [holder.destinationTag]."
			return
		holder.last_pipe = holder.current_pipe
		holder.current_pipe = current
		// If we have re-entered the loop at the unsorting pip, increment run ID as we will have a different behaviour next time we loop around
		if (!has_looped && !holder.unsorted)
			run_id ++
			has_looped = TRUE
		// Found a valid ending
		if (locate(/obj/structure/disposaloutlet) in T)
			return locate(/obj/structure/disposaloutlet) in T
		// Detect ending back at an input
		if (locate(/obj/machinery/disposal) in T)
			if (!allow_inputs)
				failure_reason = "Disposal loop starting at [COORD(start)] leads to an input node at [COORD(T)] but should lead to an outlet.  Holder was traversing [dir2text(holder.dir)] and was last at [COORD(holder.last_pipe)]. Sort code was [holder.destinationTag]."
			return current
		if (!is_sorting_network && locate(/obj/structure/disposalpipe/sorting) in T)
			is_sorting_network = "This network requires sorting all mail correctly as it contains a sorting pipe at [COORD(T)]."
		// Loop detection
		if (current._traversed == run_id)
			failure_reason = "Disposal network starting at [COORD(start)] contains a loop at [COORD(T)] which is not allowed. Holder was traversing [dir2text(holder.dir)] and was last at [COORD(holder.last_pipe)]. Sort code was [holder.destinationTag]."
			return
		current._traversed = run_id
