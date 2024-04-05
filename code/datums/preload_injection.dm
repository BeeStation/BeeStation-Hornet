/datum/preload_injection // basetype
/datum/preload_injection/proc/apply(atom/target)
	CRASH("preload_injection called parent apply(), but it's not a thing.")

//----------------------------------------------------------------------
// for init time save
// Instead of running the given value to atom, we'll run GLOB.preload_handler with injector path
GLOBAL_DATUM_INIT(preload_handler, /datum/preload_injection/master, new)
/datum/preload_injection/master
	var/static/list/cached_injectors = list()

/datum/preload_injection/master/apply(atom/target, actual_injector = null)
	var/datum/preload_injection/real_injector = actual_injector || target.preload_data
	if(cached_injectors[real_injector])
		real_injector = cached_injectors[real_injector]
	else
		real_injector = new real_injector
		cached_injectors[real_injector.type] = real_injector
	real_injector.apply(target)
//----------------------------------------------------------------------
// in case when you want to apply multiple injectors
/datum/preload_injection/multiple
	var/list/multiple_injectors

/datum/preload_injection/multiple/apply(atom/target)
	for(var/each_injector in multiple_injectors)
		GLOB.preload_handler.apply(target, each_injector)
//----------------------------------------------------------------------
// faction application
/datum/preload_injection/faction
	var/list/faction_to_add
	var/list/faction_to_force

/datum/preload_injection/faction/apply(mob/target)
	if(length(faction_to_force))
		target.faction = faction_to_force.Copy()
	if(length(faction_to_add))
		target.faction |= faction_to_add

/datum/preload_injection/faction/add_syndicate
	faction_to_add = list(FACTION_SYNDICATE)
/datum/preload_injection/faction/force_syndicate
	faction_to_force = list(FACTION_SYNDICATE)
