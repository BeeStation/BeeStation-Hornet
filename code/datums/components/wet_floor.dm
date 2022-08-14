/datum/component/wet_floor
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	can_transfer = TRUE
	var/wet_floor_bitflags = TURF_DRY
	var/lube_flags = NONE			//why do we have this?
	var/list/time_left_list			//In deciseconds.
	var/static/mutable_appearance/permafrost_overlay = mutable_appearance('icons/effects/water.dmi', "ice_floor")
	var/static/mutable_appearance/ice_overlay = mutable_appearance('icons/turf/overlays.dmi', "snowfloor")
	var/static/mutable_appearance/water_overlay = mutable_appearance('icons/effects/water.dmi', "wet_floor_static")
	var/static/mutable_appearance/generic_turf_overlay = mutable_appearance('icons/effects/water.dmi', "wet_static")
	var/current_overlay
	var/permanent = FALSE
	var/last_process = 0

/datum/component/wet_floor/InheritComponent(datum/newcomp, orig, strength, duration_minimum, duration_add, duration_maximum, _permanent)
	if(!newcomp)	//We are getting passed the arguments of a would-be new component, but not a new component
		add_wet(arglist(args.Copy(3)))
	else			//We are being passed in a full blown component
		var/datum/component/wet_floor/WF = newcomp			//Lets make an assumption
		if(WF.gc())						//See if it's even valid, still. Also does LAZYLEN and stuff for us.
			CRASH("Wet floor component tried to inherit another, but the other was able to garbage collect while being inherited! What a waste of time!")
		for(var/i in WF.time_left_list)
			add_wet(text2num(i), WF.time_left_list[i])

/datum/component/wet_floor/Initialize(strength, duration_minimum, duration_add, duration_maximum, _permanent = FALSE)
	if(!isopenturf(parent))
		return COMPONENT_INCOMPATIBLE
	add_wet(strength, duration_minimum, duration_add, duration_maximum)
	permanent = _permanent
	if(!permanent)
		START_PROCESSING(SSwet_floors, src)
	addtimer(CALLBACK(src, .proc/gc, TRUE), 1)		//GC after initialization.
	last_process = world.time

/datum/component/wet_floor/RegisterWithParent()
	RegisterSignal(parent, COMSIG_TURF_IS_WET, .proc/is_wet)
	RegisterSignal(parent, COMSIG_TURF_MAKE_DRY, .proc/dry)

/datum/component/wet_floor/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_TURF_IS_WET, COMSIG_TURF_MAKE_DRY))

/datum/component/wet_floor/Destroy()
	STOP_PROCESSING(SSwet_floors, src)
	var/turf/T = parent
	qdel(T.GetComponent(/datum/component/slippery))
	if(istype(T))		//If this is false there is so many things wrong with it.
		T.cut_overlay(current_overlay)
	else
		stack_trace("Warning: Wet floor component wasn't on a turf when being destroyed! This is really bad!")
	return ..()

/datum/component/wet_floor/proc/update_overlay()
	var/intended
	if(!istype(parent, /turf/open/floor))
		intended = generic_turf_overlay
	else
		if(wet_floor_bitflags& TURF_WET_PERMAFROST)
			intended = permafrost_overlay
		else if(wet_floor_bitflags& TURF_WET_ICE)
			intended = ice_overlay
		else
			intended = water_overlay
	if(current_overlay != intended)
		var/turf/T = parent
		T.cut_overlay(current_overlay)
		T.add_overlay(intended)
		current_overlay = intended

/datum/component/wet_floor/proc/AfterSlip(mob/living/L)
	if(wet_floor_bitflags & TURF_WET_LUBE)
		L.confused = max(L.confused, 8)

/datum/component/wet_floor/proc/update_flags()
	var/intensity = 0
	var/lube_priority = WET_LEVEL_WATER
	lube_flags = NONE
	var/my_flags = NONE // for better readability
	if(wet_floor_bitflags& TURF_WET_WATER)
		lube_priority = WET_LEVEL_WATER
		intensity = max(60, intensity)
		my_flags = WET_RESULT_DROPITEMS | WET_RESULT_KNOCKDOWN
		ENABLE_BITFIELD(lube_flags, my_flags)
	if(wet_floor_bitflags& TURF_WET_LUBE)
		lube_priority = WET_LEVEL_LUBE
		intensity = max(80, intensity)
		my_flags = WET_COMPONENT_GALOSHES_SLIP | WET_COMPONENT_WALK_SLIPS
		my_flags = WET_RESULT_DROPITEMS | WET_RESULT_SLIDES | WET_RESULT_KNOCKDOWN
		ENABLE_BITFIELD(lube_flags, my_flags)
	if(wet_floor_bitflags& TURF_WET_ICE)
		lube_priority = WET_LEVEL_ICE
		intensity = max(120, intensity)
		my_flags = WET_COMPONENT_GALOSHES_SLIP | WET_COMPONENT_WALK_SLIPS
		my_flags = WET_RESULT_DROPITEMS | WET_RESULT_SLIDES | WET_RESULT_KNOCKDOWN | WET_RESULT_STOP_PULLING
		ENABLE_BITFIELD(lube_flags, my_flags)
	if(wet_floor_bitflags& TURF_WET_PERMAFROST)
		lube_priority = WET_LEVEL_ICE
		intensity = max(120, intensity)
		my_flags = WET_COMPONENT_GALOSHES_SLIP | WET_COMPONENT_WALK_SLIPS
		my_flags = WET_RESULT_DROPITEMS | WET_RESULT_SLIDES | WET_RESULT_KNOCKDOWN | WET_RESULT_STOP_PULLING
		ENABLE_BITFIELD(lube_flags, my_flags)
	if(wet_floor_bitflags& TURF_WET_SUPERLUBE)
		lube_priority = WET_LEVEL_SUPERLUBE
		intensity = max(120, intensity)
		my_flags = WET_COMPONENT_GALOSHES_SLIP | WET_COMPONENT_WALK_SLIPS | WET_COMPONENT_CRAWL_SLIPS
		my_flags = WET_RESULT_DROPITEMS | WET_RESULT_SLIDES | WET_RESULT_KNOCKDOWN | WET_RESULT_STOP_PULLING
		ENABLE_BITFIELD(lube_flags, my_flags)
	// for better readability, first flags are for "components" how/when that slip works
	//                         secone flags are for "result" what that slip does to you

	lube_flags |= lube_priority
	if(!lube_flags)
		qdel(parent.GetComponent(/datum/component/slippery))
		return

	parent.LoadComponent(/datum/component/slippery, intensity, lube_flags, CALLBACK(src, .proc/AfterSlip))

/datum/component/wet_floor/proc/dry(datum/source, target_wet_bitflags = ALL, immediate = FALSE, duration_decrease = INFINITY)
	SIGNAL_HANDLER

	for(var/i in time_left_list)
		if(text2num(i) & target_wet_bitflags)
			time_left_list[i] = max(0, time_left_list[i] - duration_decrease)
	if(immediate)
		check()

/datum/component/wet_floor/process()
	var/turf/open/T = parent
	var/diff = world.time - last_process
	var/decrease = 0
	var/t = T.GetTemperature()
	switch(t)
		if(-INFINITY to T0C)
			var/target_duration = time_left_list["[TURF_WET_WATER]"]
			add_wet(TURF_WET_ICE, target_duration, target_duration)			//Water freezes into ice!
			dry(null, TURF_WET_WATER)
		if(T0C to T0C + 100)
			decrease = ((T.air.return_temperature() - T0C) / SSwet_floors.temperature_coeff) * (diff / SSwet_floors.time_ratio)
		if(T0C + 100 to INFINITY)
			decrease = INFINITY
	decrease = max(0, decrease)
	if((is_wet() & TURF_WET_ICE) && t > T0C)		//Ice melts into water!
		for(var/obj/O in T.contents)
			if(O.obj_flags & FROZEN)
				O.make_unfrozen()
		var/target_duration = time_left_list["[TURF_WET_ICE]"]
		add_wet(TURF_WET_WATER, target_duration, target_duration)
		dry(null, TURF_WET_ICE)
	dry(null, ALL, FALSE, decrease)
	check()
	last_process = world.time

/datum/component/wet_floor/proc/update_wet_floor_bitflags()
	wet_floor_bitflags = NONE
	for(var/i in time_left_list)
		wet_floor_bitflags |= text2num(i)

/datum/component/wet_floor/proc/is_wet()
	SIGNAL_HANDLER

	. = 0
	for(var/i in time_left_list)
		. |= text2num(i)

/datum/component/wet_floor/PreTransfer()
	var/turf/O = parent
	O.cut_overlay(current_overlay)
	//That turf is no longer slippery, we're out of here
	//Slippery components don't transfer due to callbacks
	qdel(O.GetComponent(/datum/component/slippery))

/datum/component/wet_floor/PostTransfer()
	if(!isopenturf(parent))
		return COMPONENT_INCOMPATIBLE
	var/turf/T = parent
	T.add_overlay(current_overlay)
	//Make sure to add/update any slippery component on the new turf (update_flags calls LoadComponent)
	update_flags()

	//NB it's possible we get deleted after this, due to inherit

/datum/component/wet_floor/proc/add_wet(type, duration_minimum = 0, duration_add = 0, duration_maximum = MAXIMUM_WET_TIME, _permanent = FALSE)
	var/static/list/allowed_types = list(TURF_WET_WATER, TURF_WET_LUBE, TURF_WET_ICE, TURF_WET_PERMAFROST, TURF_WET_SUPERLUBE)
	if(duration_minimum <= 0 || !type)
		return FALSE
	if(type in allowed_types)
		return _do_add_wet(type, duration_minimum, duration_add, duration_maximum)
	else
		. = NONE
		for(var/i in allowed_types)
			if(!(type & i))
				continue
			. |= _do_add_wet(i, duration_minimum, duration_add, duration_maximum)
	if(_permanent)
		permanent = TRUE
		STOP_PROCESSING(SSwet_floors, src)

/datum/component/wet_floor/proc/_do_add_wet(type, duration_minimum, duration_add, duration_maximum)
	var/time = 0
	if(LAZYACCESS(time_left_list, "[type]"))
		time = CLAMP(LAZYACCESS(time_left_list, "[type]") + duration_add, duration_minimum, duration_maximum)
	else
		time = min(duration_minimum, duration_maximum)
	LAZYSET(time_left_list, "[type]", time)
	check(TRUE)
	return TRUE

/datum/component/wet_floor/proc/gc(on_init = FALSE)
	if(!LAZYLEN(time_left_list))
		if(on_init)
			var/turf/T = parent
			stack_trace("Warning: Wet floor component gc'd right after initialization! What a waste of time and CPU! Type = [T? T.type : "ERROR - NO PARENT"], Location = [istype(T)? AREACOORD(T) : "ERROR - INVALID PARENT"].")
		qdel(src)
		return TRUE
	return FALSE

/datum/component/wet_floor/proc/check(force_update = FALSE)
	var/changed = FALSE
	for(var/i in time_left_list)
		if(time_left_list[i] <= 0)
			time_left_list -= i
			changed = TRUE
	if(changed || force_update)
		update_wet_floor_bitflags()
		update_overlay()
		update_flags()
		gc()
