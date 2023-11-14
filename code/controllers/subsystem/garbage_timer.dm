SUBSYSTEM_DEF(garbage_timer)
	name = "Garbage Timer"
	priority = FIRE_PRIORITY_GARBAGE_TIMER
	wait = 0.2 SECONDS
	flags = SS_POST_FIRE_TIMING|SS_BACKGROUND|SS_NO_INIT
	runlevels = RUNLEVELS_DEFAULT | RUNLEVEL_LOBBY
	init_order = INIT_ORDER_GARBAGE_TIMER

	var/list/items_quite_later = list()
	var/list/items_in_waiting = list()
	var/list/items_imminent = list()

	var/slow_fire_interval = 20
	var/currently_handling = FALSE

/datum/controller/subsystem/garbage_timer/stat_entry(msg)
	msg += "Qlen:[items_in_waiting.len]|"
	msg += "H:[currently_handling ? "T" : "F"]"
	. = ..(msg)

/datum/controller/subsystem/garbage_timer/fire()
	if(!(times_fired % slow_fire_interval)) // we do this every 20 fires
		fire_check_late_qdels()

	if(!items_in_waiting.len) // nothing to do
		return

	if(currently_handling)
		return

	INVOKE_ASYNC(src, PROC_REF(aync_fire))
	//aync_fire()

/datum/controller/subsystem/garbage_timer/proc/aync_fire()
	currently_handling = TRUE
	fire_checks_qdels()
	fire_sends_qdels()
	currently_handling = FALSE

#define SLOW_QDEL_MIN 500
#define SLOW_QDEL_MAX 1500

/// checks if an item should be delete. Stops when there are too many qdel items
/datum/controller/subsystem/garbage_timer/proc/fire_checks_qdels()
	if(items_in_waiting.len >= SLOW_QDEL_MAX)
		log_game("WARNING: Garbage Timer system is handling more than [SLOW_QDEL_MAX] items ([items_in_waiting.len]).")
		message_admins("Garbage Timer system is handling more than [SLOW_QDEL_MAX] items ([items_in_waiting.len]).")
	var/maximum_qdel_insertable = clamp(items_in_waiting.len, SLOW_QDEL_MIN, min(items_in_waiting.len / 2, SLOW_QDEL_MAX))
	for(var/each in items_in_waiting)
		if(!each) // qdeleted already?
			items_in_waiting -= each
		if(items_imminent.len > maximum_qdel_insertable)
			break
		if(items_in_waiting[each] > world.time)
			continue
		items_in_waiting -= each
		items_imminent += each

#undef SLOW_QDEL_MIN
#undef SLOW_QDEL_MAX

/datum/controller/subsystem/garbage_timer/proc/fire_sends_qdels(error=FALSE)
	for(var/each in items_imminent)
		qdel(each)
	items_imminent.Cut()

/// checks how many times an item should wait. If time is less, sends it to queue.
/datum/controller/subsystem/garbage_timer/proc/fire_check_late_qdels()
	for(var/each in items_quite_later)
		if(!each) // qdeleted already?
			items_quite_later -= each
		var/my_time = items_quite_later[each]
		if(items_quite_later[each] - world.time > 70 SECONDS)
			continue
		items_quite_later -= each
		items_in_waiting[each] = my_time

/datum/controller/subsystem/garbage_timer/proc/qdel_in(item, timer)
	if(!timer)
		stack_trace("qdel_in() is called without timer.")
		timer = 10

	if(timer > wait * (slow_fire_interval - 2)) // we don't want to handle these every tick
		items_quite_later[item] = timer + world.time
		return

	items_in_waiting[item] = timer + world.time
