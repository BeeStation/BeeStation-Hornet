SUBSYSTEM_DEF(garbage_timer)
	name = "Garbage Timer"
	priority = FIRE_PRIORITY_GARBAGE_TIMER
	wait = 0.2 SECONDS
	flags = SS_POST_FIRE_TIMING|SS_BACKGROUND|SS_NO_INIT
	runlevels = RUNLEVELS_DEFAULT | RUNLEVEL_LOBBY
	init_order = INIT_ORDER_GARBAGE_TIMER

	var/list/time_assoc_qdel_targets = list()
	/// this makes time assoc list kinda sorted because it's risky to sort the assoc list.
	var/list/time_active_list = list()
	/// If a list has a new value before trying fire, try sorting.
	/// since qdel_in() can exist multiple instances, it's dangerous to do that in the proc
	var/need_sort = FALSE

/datum/controller/subsystem/garbage_timer/stat_entry(msg)
	msg += "L:[length(time_assoc_qdel_targets)]|"
	if(length(time_assoc_qdel_targets))
		msg += "T:"
		for(var/each_time_key in time_assoc_qdel_targets)
			var/list/each_entry = time_assoc_qdel_targets[each_time_key]
			msg += "\[[each_time_key]:[length(each_entry)]\]"
	. = ..(msg)

/datum/controller/subsystem/garbage_timer/Recover()
	time_assoc_qdel_targets = SSgarbage_timer.time_assoc_qdel_targets

/datum/controller/subsystem/garbage_timer/fire()
	if(!length(time_assoc_qdel_targets)) // nothing to do
		return

	fire_checks_qdels()

/// checks if an item should be delete.
/datum/controller/subsystem/garbage_timer/proc/fire_checks_qdels()
	if(need_sort)
		need_sort = FALSE
		time_active_list = sort_times(time_active_list)
	for(var/each_time_key in time_active_list)
		if(time_active_list[each_time_key] > world.time)
			break
		var/list/each_entry = time_assoc_qdel_targets[each_time_key]
		while(length(each_entry)) // fun fact: length(LIST) is faster than LIST.len
			var/datum/qdel_target = each_entry[length(each_entry)]
			if(!QDELETED(qdel_target)) // qdeleted already?
				qdel(qdel_target)
			each_entry.len-- // fun fact: this removes the last item from the list. convenient.
			if(MC_TICK_CHECK)
				break
		if(!length(each_entry))
			time_assoc_qdel_targets -= each_time_key
			time_active_list -= each_time_key

/datum/controller/subsystem/garbage_timer/proc/qdel_in(item, timer)
	var/timer_key = "[timer + world.time]"
	if(!time_assoc_qdel_targets[timer_key])
		time_assoc_qdel_targets[timer_key] = list(item)
		time_active_list[timer_key] = timer + world.time

		// checks if a list needs sorting.
		if(length(time_active_list) > 1)
			for(var/idx in 1 to length(time_active_list)-1)
				if(time_active_list[time_active_list[idx]] > time_active_list[time_active_list[idx+1]])
					need_sort = TRUE
					break
		return timer_key

	time_assoc_qdel_targets[timer_key] += item
	return timer_key

/datum/controller/subsystem/garbage_timer/proc/qdel_timer_cancel(datum/item, time_key)
	if(QDELETED(item))
		return

	if(!time_key)
		for(var/each in time_assoc_qdel_targets)
			var/list/each_entry = time_assoc_qdel_targets[each]
			var/index = each_entry.Find(item)
			if(index)
				each_entry.Remove(index)
				return
	else
		var/list/specified_entry = time_assoc_qdel_targets[time_key]
		var/index = specified_entry.Find(item)
		if(index)
			specified_entry.Remove(index)
			return
