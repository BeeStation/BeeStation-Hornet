SUBSYSTEM_DEF(garbage_timer)
	name = "Garbage Timer"
	priority = FIRE_PRIORITY_GARBAGE_TIMER
	wait = 0.2 SECONDS
	flags = SS_POST_FIRE_TIMING|SS_BACKGROUND|SS_NO_INIT
	runlevels = RUNLEVELS_DEFAULT | RUNLEVEL_LOBBY
	init_order = INIT_ORDER_GARBAGE_TIMER

	/// If an item has a long timer, we don't want to bloat our checklist.
	var/list/items_quite_later = list()
	/// Items that needs to check timer for qdel.
	var/list/items_in_waiting = list()

	/// For every interval, we'll run a proc to check "list/items_quite_later" if it has an item has imminent timer
	var/slow_fire_interval = 20

	/// Kinda works like a signal. If a queue is changed while subsystem is running, stops the subsystem.
	var/interrupt = FALSE

/datum/controller/subsystem/garbage_timer/stat_entry(msg)
	msg += "QlenW:[items_in_waiting.len]|"
	msg += "QlenL: [items_quite_later.len]|"
	. = ..(msg)

/datum/controller/subsystem/garbage_timer/Recover()
	items_quite_later = SSgarbage_timer.items_quite_later
	items_in_waiting = SSgarbage_timer.items_in_waiting

/datum/controller/subsystem/garbage_timer/fire()
	if(!(times_fired % slow_fire_interval)) // we do this every 20 fires
		fire_check_late_qdels()

	if(!items_in_waiting.len) // nothing to do
		return

	fire_checks_qdels()

#define INTERRUPT_FLAG_PRIMARY 1
#define INTERRUPT_FLAG_SECONDARY 2

/// checks if an item should be delete. Stops when there are too many qdel items
/datum/controller/subsystem/garbage_timer/proc/fire_checks_qdels()
	interrupt = NONE
	for(var/datum/each in items_in_waiting)
		if(interrupt & INTERRUPT_FLAG_PRIMARY)
			break
		if(QDELETED(each)) // qdeleted already?
			items_in_waiting -= each
			continue
		if(MC_TICK_CHECK)
			break
		if(items_in_waiting[each] > world.time)
			continue
		items_in_waiting -= each
		qdel(each)
	interrupt = NONE

/// checks how many times an item should wait. If time is less, sends it to queue.
/datum/controller/subsystem/garbage_timer/proc/fire_check_late_qdels()
	interrupt = NONE
	var/timer_condition = wait * slow_fire_interval
	for(var/datum/each in items_quite_later)
		if(interrupt & INTERRUPT_FLAG_SECONDARY)
			break
		if(QDELETED(each)) // qdeleted already?
			items_quite_later -= each
			continue
		var/my_time = items_quite_later[each]
		if(items_quite_later[each] - world.time > timer_condition)
			continue
		items_quite_later -= each
		items_in_waiting[each] = my_time
	interrupt = NONE

/datum/controller/subsystem/garbage_timer/proc/qdel_in(item, timer)
	if(!timer)
		stack_trace("qdel_in() is called without timer.")
		timer = 10

	if(timer > wait * (slow_fire_interval - 2)) // we don't want to handle these every tick
		items_quite_later[item] = timer + world.time
		return TRUE

	items_in_waiting[item] = timer + world.time
	return TRUE

/datum/controller/subsystem/garbage_timer/proc/qdel_timer_cancel(datum/item)
	if(QDELETED(item))
		return

	var/index
	if(items_quite_later[item])
		interrupt |= INTERRUPT_FLAG_SECONDARY
		index = items_quite_later.Find(item)
		items_quite_later.Cut(index, index+1)
		return

	if(items_in_waiting[item])
		interrupt |= INTERRUPT_FLAG_PRIMARY
		index = items_in_waiting.Find(item)
		items_in_waiting.Cut(index, index+1)
		return
