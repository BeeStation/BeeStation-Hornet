//This element facilitates reaction to atmos changes when a tile is inactive.
//It adds the object to a list on SSair to be processed for so long as the object wants to be processed
//And removes it as soon as the object is no longer interested
//Don't put it on things that tend to clump into one spot, you will cause lag spikes.
/datum/element/atmos_sensitive
	element_flags = ELEMENT_DETACH

/datum/element/atmos_sensitive/Attach(datum/target, mapload)
	if(!isatom(target)) //How
		return ELEMENT_INCOMPATIBLE
	var/atom/to_track = target
	if(to_track.loc)
		to_track.RegisterSignal(to_track.loc, COMSIG_TURF_EXPOSE, TYPE_PROC_REF(/atom, check_atmos_process))
	RegisterSignal(to_track, COMSIG_MOVABLE_MOVED, PROC_REF(react_to_move))

	if(!mapload && isopenturf(to_track.loc))
		to_track.atmos_conditions_changed() //Make sure you're properly registered

	return ..()

/datum/element/atmos_sensitive/Detach(atom/source)
	if(source.loc)
		UnregisterSignal(source.loc, COMSIG_TURF_EXPOSE)
	UnregisterSignal(source, COMSIG_MOVABLE_MOVED)
	if(source.flags_1 & ATMOS_IS_PROCESSING_1)
		source.atmos_end()
		SSair.atom_process -= source
		source.flags_1 &= ~ATMOS_IS_PROCESSING_1
	return ..()

/datum/element/atmos_sensitive/proc/react_to_move(atom/source, atom/movable/oldloc, direction, forced)
	SIGNAL_HANDLER

	if(oldloc)
		source.UnregisterSignal(oldloc, COMSIG_TURF_EXPOSE)
	if(source.loc)
		source.RegisterSignal(source.loc, COMSIG_TURF_EXPOSE, TYPE_PROC_REF(/atom, check_atmos_process))
	source.atmos_conditions_changed() //Make sure you're properly registered

/atom/proc/check_atmos_process(datum/source, datum/gas_mixture/air, exposed_temperature)
	SIGNAL_HANDLER
	if(should_atmos_process(air, exposed_temperature))
		if(flags_1 & ATMOS_IS_PROCESSING_1)
			return
		SSair.atom_process += src
		flags_1 |= ATMOS_IS_PROCESSING_1
	else if(flags_1 & ATMOS_IS_PROCESSING_1)
		atmos_end()
		SSair.atom_process -= src
		flags_1 &= ~ATMOS_IS_PROCESSING_1

/atom/proc/process_exposure()
	var/turf/open/spot = loc
	if(!isopenturf(loc))
		//If you end up in a locker or a wall reconsider your life decisions
		atmos_end()
		SSair.atom_process -= src
		flags_1 &= ~ATMOS_IS_PROCESSING_1
		return
	if(!should_atmos_process(spot.air, spot.air.temperature)) //Things can change without a tile becoming active
		atmos_end()
		SSair.atom_process -= src
		flags_1 &= ~ATMOS_IS_PROCESSING_1
		return
	atmos_expose(spot.air, spot.air.temperature)

/turf/open/process_exposure()
	if(!should_atmos_process(air, air.temperature))
		atmos_end()
		SSair.atom_process -= src
		flags_1 &= ~ATMOS_IS_PROCESSING_1
		return
	atmos_expose(air, air.temperature)

///We use this proc to check if we should start processing an item, or continue processing it. Returns true/false as expected
/atom/proc/should_atmos_process(datum/gas_mixture/air, exposed_temperature)
	return FALSE

///This is your process() proc
/atom/proc/atmos_expose(datum/gas_mixture/air, exposed_temperature)
	return

///What to do when our requirements are no longer met
/atom/proc/atmos_end()
	return
