/// * If time <= 0, use the old qdel method(addtimer thing). That's because global vars controller can not be initialized yet, but 0 timer is used in those cases.
/// * If time > 0, use the new qdel method(calling proc). This put the qdel target stuff into a list with time key index, so that we do qdel things quickly from SStimer.
#define QDEL_IN(item, time) (time > 0 ? _qdel_in(item, time) : addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(qdel), item), 0, TIMER_STOPPABLE))
#define QDEL_TIMER_CANCEL(item, time_key) qdel_timer_cancel(item, time_key)
#define QDEL_IN_CLIENT_TIME(item, time) addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(qdel), item), time, TIMER_STOPPABLE | TIMER_CLIENT_TIME)
#define QDEL_NULL(item) qdel(item); item = null
#define QDEL_LIST(L) if(L) { for(var/I in L) qdel(I); L.Cut(); }
#define QDEL_LIST_IN(L, time) addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(______qdel_list_wrapper), L), time, TIMER_STOPPABLE)
#define QDEL_LIST_ASSOC(L) if(L) { for(var/I in L) { qdel(L[I]); qdel(I); } L.Cut(); }
#define QDEL_LIST_ASSOC_VAL(L) if(L) { for(var/I in L) qdel(L[I]); L.Cut(); }

/proc/______qdel_list_wrapper(list/L) //the underscores are to encourage people not to use this directly.
	QDEL_LIST(L)

/*
	Codes below are to support massive timed qdel()
	the old `qdel_in()` was doing this directly:
		`addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(qdel), item), time, TIMER_STOPPABLE)`
	This means the code makes every time datum and schedule to qdel for every item.

	We don't have to do this. If qdel targets have the same schedule when to delete,
	just batching all qdel targets into a single timer is enough.

	This code does that.
*/
GLOBAL_LIST_EMPTY(qdel_timers) /// a list that stores a schedule to qdel, taking items to qdel.

/// puts an item into qdel_timer schedule.
/// * return value: "timer_key" is used to track a qdel-scheduled item is which timer group in.
/// If you don't have this key when you do `qdel_timer_cancel()`, cancelling qdel schedule will be slow.
/proc/_qdel_in(datum/D, time, force=FALSE, ...) // NOTE: do not call this proc directly. Use "QDEL_IN()" macro.
	var/timer_key = "[time + world.time]" // TODO: when Lummox makes numeric key for a list, change it.
	if(!GLOB.qdel_timers[timer_key])
		GLOB.qdel_timers[timer_key] = list()
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(_mass_qdel), timer_key), time, TIMER_STOPPABLE)

	GLOB.qdel_timers[timer_key] += D
	return timer_key

// Internal usage only. Timer subsystem will call it.
/proc/_mass_qdel(timer_key)
	for(var/datum/qdel_target in GLOB.qdel_timers[timer_key])
		if(!QDELETED(qdel_target))
			qdel(qdel_target)
	GLOB.qdel_timers -= timer_key
	return

/proc/qdel_timer_cancel(datum/item, timer_key)
	if(QDELETED(item))
		return

	if(!timer_key)
		stack_trace("qdel_timer_cancel() was called to [item] without any timer_key. This might not be good.")
		for(var/each in GLOB.qdel_timers)
			var/list/each_entry = GLOB.qdel_timers[each]
			var/index = each_entry.Find(item)
			if(index)
				each_entry.Remove(index)
				return
	else
		var/list/specified_entry = GLOB.qdel_timers[timer_key]
		if(!length(specified_entry))
			stack_trace("qdel_timer_cancel() was called to [item] with timer_key [timer_key], but there is no schedule with the key. This might not be good.")
			return
		var/index = specified_entry.Find(item)
		if(index)
			specified_entry.Remove(index)
			return
