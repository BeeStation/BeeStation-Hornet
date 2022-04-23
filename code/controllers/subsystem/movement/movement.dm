SUBSYSTEM_DEF(movement)
	name = "Movement Loops"
	flags = SS_NO_INIT|SS_BACKGROUND|SS_TICKER
	wait = 1 //Fire each tick
	/*
		A breif aside about the bucketing system here
		The goal is to allow for higher loads of semi long delays while reducing cpu usage
		Bucket insertion and management are much less complex then what you might see in SStimer
		This is intentional, as we loop our delays much more often then that ss is designed for
		We also have much shorter term timers, so we need to worry about redundant buckets much less
	*/
	///Sorted Assoc list of "target time" -> list(things to process).
	var/list/buckets = list()
	///The time we started our last fire at
	var/canonical_time = 0
	///The visual delay of the subsystem
	var/visual_delay = 1

/datum/controller/subsystem/movement/stat_entry(msg)
	var/total_len = 0
	for(var/list/bucket_time as anything in buckets)
		total_len += length(buckets[bucket_time])
	msg = "B:[total_len]"
	return ..()

/datum/controller/subsystem/movement/Recover()
	//Get ready this is gonna be horrible
	//We need to do this to support subtypes by the by
	var/list/typenames = splittext("[type]", "/")
	var/our_name = typenames[length(typenames)] //Get the last name in the list, IE the subsystem identifier

	var/datum/controller/subsystem/movement/old_version = global.vars["SS[our_name]"]
	buckets = old_version.buckets

/datum/controller/subsystem/movement/fire(resumed)
	if(!resumed)
		canonical_time = world.time

	for(var/bucket_time as anything in buckets)
		if(text2num(bucket_time) > canonical_time || MC_TICK_CHECK)
			return
		pour_bucket(bucket_time)

/// Processes a bucket of movement loops (This should only ever be called by fire(), it exists to prevent runtime fuckery)
/datum/controller/subsystem/movement/proc/pour_bucket(bucket_time)
	var/list/processing = buckets[bucket_time] // Cache for lookup speed
	while(processing.len)
		var/datum/move_loop/loop = processing[processing.len]
		processing.len--
		loop.process() //This shouldn't get nulls, if it does, runtime
		if(!QDELETED(loop)) //Re-Insert the loop
			loop.timer = world.time + loop.delay
			queue_loop(loop)
		if(MC_TICK_CHECK)
			break
	if(length(processing))
		return // Still work to be done
	smash_bucket(bucket_time)
	visual_delay = MC_AVERAGE_FAST(visual_delay, max((world.time - canonical_time) / wait, 1))

/// Removes a bucket from our system. You only need to pass in the time, but if you pass in the index of the list you save us some work
/datum/controller/subsystem/movement/proc/smash_bucket(bucket_time)
	//Removes the assoc lookup too
	buckets -= "[bucket_time]"

/datum/controller/subsystem/movement/proc/queue_loop(datum/move_loop/loop)
	var/target_time = loop.timer
	var/string_time = "[target_time]"
	if(string_time in buckets)
		buckets[string_time] += loop
	else
		//this acts as a sorted and assoc list at the same time
		BINARY_INSERT_DEFINE(list("[string_time]" = null), buckets, SORT_VAR_NO_TYPE, target_time, SORT_ASSOC_VALUE, COMPARE_KEY)
		buckets[string_time] += list(loop) //this is stupid but if we don't do it like that we can sometimes end up with empty list entries without loops

/datum/controller/subsystem/movement/proc/dequeue_loop(datum/move_loop/loop)
	var/list/our_entries = buckets["[loop.timer]"]
	our_entries -= loop
	if(!(our_entries.len))
		smash_bucket(loop.timer)

/datum/controller/subsystem/movement/proc/add_loop(datum/move_loop/add)
	add.start_loop()
	if(QDELETED(add))
		return
	queue_loop(add)

/datum/controller/subsystem/movement/proc/remove_loop(datum/move_loop/remove)
	dequeue_loop(remove)
	remove.stop_loop()
