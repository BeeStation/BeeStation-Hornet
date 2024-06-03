PROCESSING_SUBSYSTEM_DEF(effects)
	name = "Effects"
	wait = 0.2 SECONDS
	stat_tag = "EFF"
	var/datum/heap/destroy_heap = new /datum/heap(GLOBAL_PROC_REF(HeapEffectDestroyAtCompare))

/datum/controller/subsystem/processing/effects/fire(resumed)
	MC_SPLIT_TICK_INIT(2)
	MC_SPLIT_TICK
	var/obj/effect/temp_visual/top_visual = destroy_heap.pop()
	while (istype(top_visual))
		if (top_visual.destroy_at > world.time)
			// Re-enter the queue if we were bumped
			if (top_visual.bumped)
				destroy_heap.insert(top_visual)
				continue
			break
		qdel(top_visual)
		top_visual = destroy_heap.pop()
	MC_SPLIT_TICK
	return ..()

/datum/controller/subsystem/processing/effects/proc/join_temp_visual(obj/effect/temp_visual/visual)
	visual.heap_position = destroy_heap.insert(visual)

/datum/controller/subsystem/processing/effects/proc/leave_temp_visual(obj/effect/temp_visual/visual)
	if (visual.heap_position)
		destroy_heap.delete_at(visual.heap_position)
	visual.heap_position = null

/proc/HeapEffectDestroyAtCompare(obj/effect/temp_visual/a, obj/effect/temp_visual/b)
	return b.destroy_at - a.destroy_at
