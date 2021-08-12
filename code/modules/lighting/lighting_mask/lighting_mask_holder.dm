/obj/effect/lighting_mask_holder
	name = ""
	anchored = TRUE
	appearance_flags = 0	//Removes TILE_BOUND meaning that the lighting mask will be visible even if the source turf is not.
	var/atom/movable/lighting_mask/held_mask

/obj/effect/lighting_mask_holder/proc/assign_mask(atom/movable/lighting_mask/mask)
	vis_contents += mask
	held_mask = mask
	mask.holder = WEAKREF(src)

/obj/effect/lighting_mask_holder/Destroy(force)
	if(held_mask)
		//goodbye
		QDEL_NULL(held_mask)
	. = ..()

/obj/effect/lighting_mask_holder/Moved(atom/OldLoc, Dir)
	. = ..()
	held_mask.light_mask_update()
