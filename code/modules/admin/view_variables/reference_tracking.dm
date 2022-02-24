#ifdef REFERENCE_TRACKING

/datum/proc/find_references(skip_alert)
	running_find_references = type
	if(usr?.client)
		if(usr.client.running_find_references)
			log_reftracker("CANCELLED search for references to a [usr.client.running_find_references].")
			usr.client.running_find_references = null
			running_find_references = null
			//restart the garbage collector
			SSgarbage.can_fire = TRUE
			SSgarbage.next_fire = world.time + world.tick_lag
			return

		if(!skip_alert && alert("Running this will lock everything up for about 5 minutes.  Would you like to begin the search?", "Find References", "Yes", "No") != "Yes")
			running_find_references = null
			return

	//this keeps the garbage collector from failing to collect objects being searched for in here
	SSgarbage.can_fire = FALSE

	if(usr?.client)
		usr.client.running_find_references = type

	log_reftracker("Beginning search for references to a [type].")

	var/starting_time = world.time
	var/found_ref = FALSE

	//Time to search the whole game for our ref
	found_ref = DoSearchVar(GLOB, "GLOB", search_time = starting_time) || found_ref //globals
	log_reftracker("Finished searching globals")

	//Yes we do actually need to do this. The searcher refuses to read weird lists
	//And global.vars is a really weird list
	var/global_vars = list()
	for(var/key in global.vars)
		global_vars[key] = global.vars[key]

	found_ref = DoSearchVar(global_vars, "Native Global", search_time = starting_time) || found_ref
	log_reftracker("Finished searching native globals")

	for(var/datum/thing) //datums
		found_ref = DoSearchVar(thing, "Datums -> [thing.type]", search_time = starting_time) || found_ref
	log_reftracker("Finished searching datums")

	//Warning, attempting to search clients like this will cause crashes if done on live. Watch yourself
#ifndef REFERENCE_DOING_IT_LIVE
	for(var/client/thing) //clients
		found_ref = DoSearchVar(thing, "Clients -> [thing.type]", search_time = starting_time) || found_ref
	log_reftracker("Finished searching clients")
#endif

#ifdef REFERENCE_TRACKING_FAST
	if(found_ref)
		log_reftracker("Skipped searching atoms (other ref(s) found)")
	else
		for(var/datum/thing in world) //atoms (don't beleive its lies)
			found_ref = DoSearchVar(thing, "World -> [thing.type]", search_time = starting_time)
			if(found_ref)
				log_reftracker("Aborting atoms search (ref found)")
				break
		log_reftracker("Finished searching atoms")
#else
	for(var/datum/thing in world) //atoms (don't beleive its lies)
		found_ref = DoSearchVar(thing, "World -> [thing.type]", search_time = starting_time) || found_ref
	log_reftracker("Finished searching atoms")
#endif
	log_reftracker("Completed search for references to a [type]. [found_ref ? "Found reference(s)." : "No reference(s) found."]")

	if(usr?.client)
		usr.client.running_find_references = null
	running_find_references = null

	//restart the garbage collector
	SSgarbage.can_fire = TRUE
	SSgarbage.next_fire = world.time + world.tick_lag

/datum/proc/DoSearchVar(potential_container, container_name, recursive_limit = 64, search_time = world.time)
	. = FALSE
	#ifdef REFERENCE_TRACKING_DEBUG
	if(SSgarbage.should_save_refs && !found_refs)
		found_refs = list()
	#endif

	if(usr?.client && !usr.client.running_find_references)
		return

	if(!recursive_limit)
		log_reftracker("Recursion limit reached. [container_name]")
		return

	//Check each time you go down a layer. This makes it a bit slow, but it won't effect the rest of the game at all
	#ifndef FIND_REF_NO_CHECK_TICK
	CHECK_TICK
	#endif

	if(istype(potential_container, /datum))
		var/datum/datum_container = potential_container
		if(datum_container.last_find_references == search_time)
			return

		datum_container.last_find_references = search_time
		var/list/vars_list = datum_container.vars
		for(var/varname in vars_list)
			#ifndef FIND_REF_NO_CHECK_TICK
			CHECK_TICK
			#endif
			if (varname == "vars" || varname == "vis_locs") //Fun fact, vis_locs don't count for references
				continue
			var/variable = vars_list[varname]

			if(variable == src)
				#ifdef REFERENCE_TRACKING_DEBUG
				if(SSgarbage.should_save_refs)
					found_refs[varname] = TRUE
					continue //End early, don't want these logging
				#endif
				. = TRUE
				log_reftracker("Found [type] \ref[src] in [datum_container.type]'s \ref[datum_container] [varname] var. [container_name]")
				continue

			if(islist(variable))
				if(DoSearchVar(variable, "[container_name] \ref[datum_container] -> [varname] (list)", recursive_limit - 1, search_time))
					. = TRUE

	else if(islist(potential_container))
		var/normal = IS_NORMAL_LIST(potential_container)
		var/list/potential_cache = potential_container
		for(var/element_in_list in potential_cache)
			#ifndef FIND_REF_NO_CHECK_TICK
			CHECK_TICK
			#endif
			//Check normal entrys
			if(element_in_list == src)
				#ifdef REFERENCE_TRACKING_DEBUG
				if(SSgarbage.should_save_refs)
					found_refs[potential_cache] = TRUE
					continue //End early, don't want these logging
				#endif
				. = TRUE
				log_reftracker("Found [type] \ref[src] in list [container_name].")
				continue

			var/assoc_val = null
			if(!isnum(element_in_list) && normal)
				assoc_val = potential_cache[element_in_list]
			//Check assoc entrys
			if(assoc_val == src)
				#ifdef REFERENCE_TRACKING_DEBUG
				if(SSgarbage.should_save_refs)
					found_refs[potential_cache] = TRUE
					continue //End early, don't want these logging
				#endif
				log_reftracker("Found [type] \ref[src] in list [container_name]\[[element_in_list]\]")
				. = TRUE
				continue
			//We need to run both of these checks, since our object could be hiding in either of them
			//Check normal sublists
			if(islist(element_in_list))
				if(DoSearchVar(element_in_list, "[container_name] -> [element_in_list] (list)", recursive_limit - 1, search_time))
					. = TRUE
			//Check assoc sublists
			if(islist(assoc_val))
				if(DoSearchVar(potential_container[element_in_list], "[container_name]\[[element_in_list]\] -> [assoc_val] (list)", recursive_limit - 1, search_time))
					. = TRUE


/proc/qdel_and_find_ref_if_fail(datum/thing_to_del, force = FALSE)
	thing_to_del.qdel_and_find_ref_if_fail(force)

/datum/proc/qdel_and_find_ref_if_fail(force = FALSE)
	SSgarbage.reference_find_on_fail["\ref[src]"] = TRUE
	qdel(src, force)

#endif
