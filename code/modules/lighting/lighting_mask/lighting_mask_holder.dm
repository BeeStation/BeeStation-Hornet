/obj/effect/lighting_mask_holder
	name = ""
	anchored = TRUE
	appearance_flags = 0	//Removes TILE_BOUND meaning that the lighting mask will be visible even if the source turf is not.
	var/datum/weakref/held_mask
	glide_size = INFINITY

/obj/effect/lighting_mask_holder/proc/assign_mask(atom/movable/lighting_mask/mask)
	vis_contents += mask
	held_mask = WEAKREF(mask)
	mask.holder = WEAKREF(src)

/obj/effect/lighting_mask_holder/Destroy(force)
	var/atom/movable/lighting_mask/located = held_mask?.resolve()
	if(located)
		//goodbye
		qdel(located)
		held_mask = null
	. = ..()

/obj/effect/lighting_mask_holder/Moved(atom/OldLoc, Dir)
	. = ..()
	var/atom/movable/lighting_mask/mask = held_mask.resolve()
	mask.calculate_lighting_shadows()
