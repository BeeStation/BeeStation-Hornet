PROCESSING_SUBSYSTEM_DEF(effects)
	name = "Effects"
	wait = 0.2 SECONDS
	stat_tag = "EFFECTS"
	var/datum/heap/destroy_heap = new /datum/heap/effect_heap(GLOBAL_PROC_REF(HeapEffectDestroyAtCompare))

/datum/controller/subsystem/processing/effects/fire(resumed)
	MC_SPLIT_TICK_INIT(2)
	MC_SPLIT_TICK
	var/obj/effect/temp_visual/top_visual = destroy_heap.pop()
	while (istype(top_visual))
		if (top_visual.destroy_at > world.time)
			// Re-enter the queue if we were bumped
			if (top_visual.bumped)
				destroy_heap.insert(top_visual)
				top_visual.bumped = FALSE
				top_visual = destroy_heap.pop()
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

/**
 * Elements need to maintain knowledge of where they are within the heap for fast removal
 * in cases where events are prematurely deleted from the heap.
 */
/datum/heap/effect_heap/delete_at(index)
	var/obj/effect/temp_visual/removed = ..()
	if (removed)
		removed.heap_position = null
	return removed

/datum/heap/effect_heap/pop()
	var/obj/effect/temp_visual/swapped = ..()
	swapped.heap_position = null

/datum/heap/effect_heap/swim(index)
	var/parent = round(index * 0.5)
	var/obj/effect/temp_visual/swapped

	while(parent > 0 && (call(cmp)(L[index],L[parent]) > 0))
		swapped = L[index]
		swapped.heap_position = parent
		swapped = L[parent]
		swapped.heap_position = index
		L.Swap(index,parent)
		index = parent
		parent = round(index * 0.5)
	return index

/datum/heap/effect_heap/sink(index)
	var/g_child = get_greater_child(index)
	var/obj/effect/temp_visual/swapped

	while(g_child > 0 && (call(cmp)(L[index],L[g_child]) < 0))
		swapped = L[index]
		swapped.heap_position = g_child
		swapped = L[g_child]
		swapped.heap_position = index
		L.Swap(index,g_child)
		index = g_child
		g_child = get_greater_child(index)
