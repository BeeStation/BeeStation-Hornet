/datum/ruin_event
	var/warning_message = ""
	var/probability = 0
	var/start_tick_min = 0
	var/start_tick_max = 0
	var/tick_rate = 1
	var/end_tick_min = 0
	var/end_tick_max = 0
	//Instanced
	var/datum/orbital_object/z_linked/linked_z
	var/start_tick = 0
	var/end_tick = 0
	var/ticks = 0

/datum/ruin_event/New()
	. = ..()
	start_tick = rand(start_tick_min, start_tick_max)
	end_tick = rand(start_tick_min, start_tick_max)

/datum/ruin_event/proc/update()
	if(QDELETED(linked_z))
		return FALSE
	//Events only work on the first Z, multi-z linkage currently is for stations only.
	if(ticks == start_tick)
		event_start(linked_z.linked_z_level[1].z_value)
	if(end_tick && ticks >= end_tick)
		event_end(linked_z.linked_z_level[1].z_value)
		return FALSE
	if(ticks % tick_rate == 0)
		event_tick(linked_z.linked_z_level[1].z_value)
	ticks ++
	return TRUE

/datum/ruin_event/proc/pre_spawn(z_value)
	return

//Note that the list is the coordinates not the turfs themselves
/datum/ruin_event/proc/post_spawn(list/floor_turfs, z_value)
	return

/datum/ruin_event/proc/event_start(z_value)
	return

/datum/ruin_event/proc/event_tick(z_value)
	return

/datum/ruin_event/proc/event_end(z_value)
	return
