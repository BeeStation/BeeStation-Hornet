SUBSYSTEM_DEF(garbage_timer)
	name = "Garbage Timer"
	priority = FIRE_PRIORITY_GARBAGE_TIMER
	wait = 0.2 SECONDS
	flags = SS_POST_FIRE_TIMING|SS_BACKGROUND|SS_NO_INIT
	runlevels = RUNLEVELS_DEFAULT | RUNLEVEL_LOBBY
	init_order = INIT_ORDER_GARBAGE_TIMER

	var/list/time_assoc_qdel_targets = list()

	/// For every interval, we'll run a proc to check "list/items_quite_later" if it has an item has imminent timer
	var/slow_fire_interval = 20

	/// Kinda works like a signal. If a queue is changed while subsystem is running, stops the subsystem.
	var/interrupt = FALSE

/datum/controller/subsystem/garbage_timer/stat_entry(msg)
	msg += "L:[time_assoc_qdel_targets.len]|"
	if(time_assoc_qdel_targets.len)
		msg += "T:"
		for(var/each_time_key in time_assoc_qdel_targets)
			var/list/each_entry = time_assoc_qdel_targets[each_time_key]
			msg += "\[[each_time_key]:[each_entry.len]\]"
	. = ..(msg)

/datum/controller/subsystem/garbage_timer/Recover()
	time_assoc_qdel_targets = SSgarbage_timer.time_assoc_qdel_targets

/datum/controller/subsystem/garbage_timer/fire()
	if(!time_assoc_qdel_targets.len) // nothing to do
		return

	fire_checks_qdels()

/// checks if an item should be delete.
/datum/controller/subsystem/garbage_timer/proc/fire_checks_qdels()
	for(var/each_time_key in time_assoc_qdel_targets)
		if(text2num(each_time_key) > world.time)
			continue
		var/list/each_entry = time_assoc_qdel_targets[each_time_key]
		for(var/datum/each_item in each_entry)
			if(QDELETED(each_item)) // qdeleted already?
				each_entry -= each_item
				continue
			if(MC_TICK_CHECK)
				break
			each_entry -= each_item
			qdel(each_item)
		if(!length(each_entry))
			time_assoc_qdel_targets -= each_time_key

/datum/controller/subsystem/garbage_timer/proc/qdel_in(item, timer)
	var/timer_key = "[timer + world.time]"
	if(!time_assoc_qdel_targets[timer_key])
		time_assoc_qdel_targets[timer_key] = list()

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
				each_entry.Cut(index, index+1)
				return
	else
		var/list/specified_entry = time_assoc_qdel_targets[time_key]
		var/index = specified_entry.Find(item)
		if(index)
			specified_entry.Cut(index, index+1)
			return

