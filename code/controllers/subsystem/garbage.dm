/*!
## Debugging GC issues

In order to debug `qdel()` failures, there are several tools available.
To enable these tools, define `TESTING` in [_compile_options.dm](https://github.com/tgstation/-tg-station/blob/master/code/_compile_options.dm).

First is a verb called "Find References", which lists **every** refererence to an object in the world. This allows you to track down any indirect or obfuscated references that you might have missed.

Complementing this is another verb, "qdel() then Find References".
This does exactly what you'd expect; it calls `qdel()` on the object and then it finds all references remaining.
This is great, because it means that `Destroy()` will have been called before it starts to find references,
so the only references you'll find will be the ones preventing the object from `qdel()`ing gracefully.

If you have a datum or something you are not destroying directly (say via the singulo),
the next tool is `QDEL_HINT_FINDREFERENCE`. You can return this in `Destroy()` (where you would normally `return ..()`),
to print a list of references once it enters the GC queue.

Finally is a verb, "Show qdel() Log", which shows the deletion log that the garbage subsystem keeps. This is helpful if you are having race conditions or need to review the order of deletions.

Note that for any of these tools to work `TESTING` must be defined.
By using these methods of finding references, you can make your life far, far easier when dealing with `qdel()` failures.
*/

SUBSYSTEM_DEF(garbage)
	name = "Garbage"
	priority = FIRE_PRIORITY_GARBAGE
	wait = 2 SECONDS
	flags = SS_POST_FIRE_TIMING|SS_BACKGROUND|SS_NO_INIT
	runlevels = RUNLEVELS_DEFAULT | RUNLEVEL_LOBBY
	init_order = INIT_ORDER_GARBAGE
	init_stage = INITSTAGE_EARLY

	var/list/collection_timeout = list(GC_FILTER_QUEUE, GC_CHECK_QUEUE, GC_DEL_QUEUE) // deciseconds to wait before moving something up in the queue to the next level

	//Stat tracking
	var/delslasttick = 0 // number of del()'s we've done this tick
	var/gcedlasttick = 0 // number of things that gc'ed last tick
	var/totaldels = 0
	var/totalgcs = 0

	var/highest_del_ms = 0
	var/highest_del_type_string = ""

	var/list/pass_counts
	var/list/fail_counts

	var/list/items = list() // Holds our qdel_item statistics datums

	//Queue
	var/list/queues
	#ifdef REFERENCE_TRACKING
	var/list/reference_find_on_fail = list()
	#ifdef REFERENCE_TRACKING_DEBUG
	//Should we save found refs. Used for unit testing
	var/should_save_refs = FALSE
	#endif
	#endif


/datum/controller/subsystem/garbage/get_metrics()
	. = ..()
	var/list/cust = list()
	// You can calculate TGCR in kibana
	cust["total_harddels"] = totaldels
	cust["total_softdels"] = totalgcs
	var/index = 0
	for(var/list/lists in queues)
		index++
		cust["queue_[index]"] = length(lists)

	.["custom"] = cust

/datum/controller/subsystem/garbage/PreInit()
	InitQueues()

/datum/controller/subsystem/garbage/stat_entry(msg)
	var/list/counts = list()
	for (var/list/L in queues)
		counts += length(L)
	msg += "Q:[counts.Join(",")]|D:[delslasttick]|G:[gcedlasttick]|"
	msg += "GR:"
	if (!(delslasttick+gcedlasttick))
		msg += "n/a|"
	else
		msg += "[round((gcedlasttick/(delslasttick+gcedlasttick))*100, 0.01)]%|"

	msg += "TD:[totaldels]|TG:[totalgcs]|"
	if (!(totaldels+totalgcs))
		msg += "n/a|"
	else
		msg += "TGR:[round((totalgcs/(totaldels+totalgcs))*100, 0.01)]%"
	msg += " P:[pass_counts.Join(",")]"
	msg += "|F:[fail_counts.Join(",")]"
	return ..()

/datum/controller/subsystem/garbage/Shutdown()
	//Adds the del() log to the qdel log file
	var/list/dellog = list()

	//sort by how long it's wasted hard deleting
	sortTim(items, cmp=/proc/cmp_qdel_item_time, associative = TRUE)
	for(var/path in items)
		var/datum/qdel_item/qdel_items = items[path]
		dellog += "Path: [path]"
		if (qdel_items.qdel_flags & QDEL_ITEM_SUSPENDED_FOR_LAG)
			dellog += "\tSUSPENDED FOR LAG"
		if (qdel_items.failures)
			dellog += "\tFailures: [qdel_items.failures]"
		dellog += "\tqdel() Count: [qdel_items.qdels]"
		dellog += "\tDestroy() Cost: [qdel_items.destroy_time]ms"
		if (qdel_items.hard_deletes)
			dellog += "\tTotal Hard Deletes: [qdel_items.hard_deletes]"
			dellog += "\tTime Spent Hard Deleting: [qdel_items.hard_delete_time]ms"
			dellog += "\tHighest Time Spent Hard Deleting: [qdel_items.hard_delete_max]ms"
			if (qdel_items.hard_deletes_over_threshold)
				dellog += "\tHard Deletes Over Threshold: [qdel_items.hard_deletes_over_threshold]"
		if (qdel_items.slept_destroy)
			dellog += "\tSleeps: [qdel_items.slept_destroy]"
		if (qdel_items.no_respect_force)
			dellog += "\tIgnored force: [qdel_items.no_respect_force] times"
		if (qdel_items.no_hint)
			dellog += "\tNo hint: [qdel_items.no_hint] times"
	log_qdel(dellog.Join("\n"))

/datum/controller/subsystem/garbage/fire()
	//the fact that this resets its processing each fire (rather then resume where it left off) is intentional.
	var/queue = GC_QUEUE_FILTER

	while (state == SS_RUNNING)
		switch (queue)
			if (GC_QUEUE_FILTER)
				HandleQueue(GC_QUEUE_FILTER)
				queue = GC_QUEUE_FILTER+1
			if (GC_QUEUE_CHECK)
				HandleQueue(GC_QUEUE_CHECK)
				queue = GC_QUEUE_CHECK+1
			if (GC_QUEUE_HARDDELETE)
				HandleQueue(GC_QUEUE_HARDDELETE)
				if (state == SS_PAUSED) //make us wait again before the next run.
					state = SS_RUNNING
				break



/datum/controller/subsystem/garbage/proc/InitQueues()
	if (isnull(queues)) // Only init the queues if they don't already exist, prevents overriding of recovered lists
		queues = new(GC_QUEUE_COUNT)
		pass_counts = new(GC_QUEUE_COUNT)
		fail_counts = new(GC_QUEUE_COUNT)
		for(var/i in 1 to GC_QUEUE_COUNT)
			queues[i] = list()
			pass_counts[i] = 0
			fail_counts[i] = 0

/datum/controller/subsystem/garbage/proc/HandleQueue(level = GC_QUEUE_FILTER)
	if (level == GC_QUEUE_FILTER)
		delslasttick = 0
		gcedlasttick = 0
	var/cut_off_time = world.time - collection_timeout[level] //ignore entries newer then this
	var/list/queue = queues[level]
	var/static/lastlevel
	var/static/count = 0
	if (count) //runtime last run before we could do this.
		var/c = count
		count = 0 //so if we runtime on the Cut, we don't try again.
		var/list/lastqueue = queues[lastlevel]
		lastqueue.Cut(1, c+1)

	lastlevel = level

	//We do this rather then for(var/refID in queue) because that sort of for loop copies the whole list.
	//Normally this isn't expensive, but the gc queue can grow to 40k items, and that gets costly/causes overrun.
	for (var/i in 1 to length(queue))
		var/list/L = queue[i]
		if (length(L) < 2)
			count++
			if (MC_TICK_CHECK)
				return
			continue

		var/GCd_at_time = L[1]
		if(GCd_at_time > cut_off_time)
			break // Everything else is newer, skip them
		count++
		var/refID = L[2]
		var/datum/Datum
		Datum = locate(refID)

		if (!Datum || Datum.gc_destroyed != GCd_at_time) // So if something else coincidently gets the same ref, it's not deleted by mistake
			++gcedlasttick
			++totalgcs
			pass_counts[level]++
			#ifdef REFERENCE_TRACKING
			reference_find_on_fail -= refID //It's deleted we don't care anymore.
			#endif
			if (MC_TICK_CHECK)
				return
			continue

		// Something's still referring to the qdel'd object.
		fail_counts[level]++

		#ifdef REFERENCE_TRACKING
		var/ref_searching = FALSE
		#endif

		switch (level)
			if (GC_QUEUE_CHECK)
				#ifdef REFERENCE_TRACKING
				if(reference_find_on_fail[refID])
					INVOKE_ASYNC(Datum, /datum/proc/find_references)
					ref_searching = TRUE
				#ifdef GC_FAILURE_HARD_LOOKUP
				else
					INVOKE_ASYNC(Datum, /datum/proc/find_references)
					ref_searching = TRUE
				#endif
				reference_find_on_fail -= refID
				#endif
				var/type = Datum.type
				var/datum/qdel_item/qdel_items = items[type]

				log_world("## TESTING: GC: -- \ref[Datum] | [type] was unable to be GC'd --")
				#ifdef TESTING
				for(var/c in GLOB.admins) //Using testing() here would fill the logs with ADMIN_VV garbage
					var/client/admin = c
					if(!check_rights_for(admin, R_ADMIN))
						continue
					to_chat(admin, "## TESTING: GC: -- [ADMIN_VV(Datum)] | [type] was unable to be GC'd --")
				#endif
				qdel_items.failures++

				if (qdel_items.qdel_flags & QDEL_ITEM_SUSPENDED_FOR_LAG)
					#ifdef REFERENCE_TRACKING
					if(ref_searching)
						return //ref searching intentionally cancels all further fires while running so things that hold references don't end up getting deleted, so we want to return here instead of continue
					#endif
					continue
			if (GC_QUEUE_HARDDELETE)
				HardDelete(Datum)
				if (MC_TICK_CHECK)
					return
				continue

		Queue(Datum, level+1)

		#ifdef REFERENCE_TRACKING
		if(ref_searching)
			return
		#endif

		if (MC_TICK_CHECK)
			return
	if (count)
		queue.Cut(1,count+1)
		count = 0

/datum/controller/subsystem/garbage/proc/Queue(datum/Datum, level = GC_QUEUE_FILTER)
	if (isnull(Datum))
		return
	if (level > GC_QUEUE_COUNT)
		HardDelete(Datum)
		return
	var/gctime = world.time
	var/refid = "\ref[Datum]"

	Datum.gc_destroyed = gctime
	var/list/queue = queues[level]

	queue[++queue.len] = list(gctime, refid) // not += for byond reasons

//this is mainly to separate things profile wise.
/datum/controller/subsystem/garbage/proc/HardDelete(datum/Datum)
	++delslasttick
	++totaldels
	var/type = Datum.type
	var/refID = "\ref[Datum]"

	var/tick_usage = TICK_USAGE
	del(Datum)
	tick_usage = TICK_USAGE_TO_MS(tick_usage)

	var/datum/qdel_item/qdel_items = items[type]
	qdel_items.hard_deletes++
	qdel_items.hard_delete_time += tick_usage
	if (tick_usage > qdel_items.hard_delete_max)
		qdel_items.hard_delete_max = tick_usage
	if (tick_usage > highest_del_ms)
		highest_del_ms = tick_usage
		highest_del_type_string = "[type]"

	var/time = MS2DS(tick_usage)

	if (time > 1 SECONDS)
		postpone(time)
	var/threshold = CONFIG_GET(number/hard_deletes_overrun_threshold)
	if (threshold && (time > threshold SECONDS))
		if (!(qdel_items.qdel_flags & QDEL_ITEM_ADMINS_WARNED))
			log_game("Error: [type]([refID]) took longer than [threshold] seconds to delete (took [round(time/10, 0.1)] seconds to delete)")
			message_admins("Error: [type]([refID]) took longer than [threshold] seconds to delete (took [round(time/10, 0.1)] seconds to delete).")
			qdel_items.qdel_flags |= QDEL_ITEM_ADMINS_WARNED
		qdel_items.hard_deletes_over_threshold++
		var/overrun_limit = CONFIG_GET(number/hard_deletes_overrun_limit)
		if (overrun_limit && qdel_items.hard_deletes_over_threshold >= overrun_limit)
			qdel_items.qdel_flags |= QDEL_ITEM_SUSPENDED_FOR_LAG

/datum/controller/subsystem/garbage/Recover()
	InitQueues() //We first need to create the queues before recovering data
	if (istype(SSgarbage.queues))
		for (var/i in 1 to SSgarbage.queues.len)
			queues[i] |= SSgarbage.queues[i]

/// Qdel Item: Holds statistics on each type that passes thru qdel
/datum/qdel_item
	var/name = "" //!Holds the type as a string for this type
	var/qdels = 0 //!Total number of times it's passed thru qdel.
	var/destroy_time = 0 //!Total amount of milliseconds spent processing this type's Destroy()
	var/failures = 0 //!Times it was queued for soft deletion but failed to soft delete.
	var/hard_deletes = 0 //!Different from failures because it also includes QDEL_HINT_HARDDEL deletions
	var/hard_delete_time = 0 //!Total amount of milliseconds spent hard deleting this type.
	var/hard_delete_max = 0 //!Highest time spent hard_deleting this in ms.
	var/hard_deletes_over_threshold = 0 //!Number of times hard deletes took longer than the configured threshold
	var/no_respect_force = 0 //!Number of times it's not respected force=TRUE
	var/no_hint = 0 //!Number of times it's not even bother to give a qdel hint
	var/slept_destroy = 0 //!Number of times it's slept in its destroy
	var/qdel_flags = 0 //!Flags related to this type's trip thru qdel.

/datum/qdel_item/New(mytype)
	name = "[mytype]"


/// Should be treated as a replacement for the 'del' keyword.
///
/// Datums passed to this will be given a chance to clean up references to allow the GC to collect them.
/proc/qdel(datum/Datum, force=FALSE, ...)
	if(!istype(Datum))
		del(Datum)
		return

	var/datum/qdel_item/qdel_items = SSgarbage.items[Datum.type]
	if (!qdel_items)
		qdel_items = SSgarbage.items[Datum.type] = new /datum/qdel_item(Datum.type)
	qdel_items.qdels++

	if(isnull(Datum.gc_destroyed))
		if (SEND_SIGNAL(Datum, COMSIG_PARENT_PREQDELETED, force)) // Give the components a chance to prevent their parent from being deleted
			return
		Datum.gc_destroyed = GC_CURRENTLY_BEING_QDELETED
		var/start_time = world.time
		var/start_tick = world.tick_usage
		SEND_SIGNAL(Datum, COMSIG_PARENT_QDELETING, force) // Let the (remaining) components know about the result of Destroy
		var/hint = Datum.Destroy(arglist(args.Copy(2))) // Let our friend know they're about to get fucked up.
		if(world.time != start_time)
			qdel_items.slept_destroy++
		else
			qdel_items.destroy_time += TICK_USAGE_TO_MS(start_tick)
		if(!Datum)
			return
		switch(hint)
			if (QDEL_HINT_QUEUE) //qdel should queue the object for deletion.
				SSgarbage.Queue(Datum)
			if (QDEL_HINT_IWILLGC)
				Datum.gc_destroyed = world.time
				return
			if (QDEL_HINT_LETMELIVE) //qdel should let the object live after calling destory.
				if(!force)
					Datum.gc_destroyed = null //clear the gc variable (important!)
					return
				// Returning LETMELIVE after being told to force destroy
				// indicates the objects Destroy() does not respect force
				#ifdef TESTING
				if(!qdel_items.no_respect_force)
					testing("WARNING: [Datum.type] has been force deleted, but is \
						returning an immortal QDEL_HINT, indicating it does \
						not respect the force flag for qdel(). It has been \
						placed in the queue, further instances of this type \
						will also be queued.")
				#endif
				qdel_items.no_respect_force++

				SSgarbage.Queue(Datum)
			if (QDEL_HINT_HARDDEL) //qdel should assume this object won't gc, and queue a hard delete
				SSgarbage.Queue(Datum, GC_QUEUE_HARDDELETE)
			if (QDEL_HINT_HARDDEL_NOW) //qdel should assume this object won't gc, and hard del it post haste.
				SSgarbage.HardDelete(Datum)
			#ifdef REFERENCE_TRACKING
			if (QDEL_HINT_FINDREFERENCE) //qdel will, if REFERENCE_TRACKING is enabled, display all references to this object, then queue the object for deletion.
				SSgarbage.Queue(Datum)
				Datum.find_references() //This breaks ci. Consider it insurance against somehow pring reftracking on accident
			if (QDEL_HINT_IFFAIL_FINDREFERENCE) //qdel will, if REFERENCE_TRACKING is enabled and the object fails to collect, display all references to this object.
				SSgarbage.Queue(Datum)
				SSgarbage.reference_find_on_fail["\ref[Datum]"] = TRUE
			#endif
			else
				#ifdef TESTING
				if(!qdel_items.no_hint)
					testing("WARNING: [Datum.type] is not returning a qdel hint. It is being placed in the queue. Further instances of this type will also be queued.")
				#endif
				qdel_items.no_hint++
				SSgarbage.Queue(Datum)
	else if(Datum.gc_destroyed == GC_CURRENTLY_BEING_QDELETED)
		CRASH("[Datum.type] destroy proc was called multiple times, likely due to a qdel loop in the Destroy logic")
