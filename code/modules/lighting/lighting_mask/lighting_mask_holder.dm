/obj/effect/lighting_mask_holder
	appearance_flags = 0	//Removes TILE_BOUND meaning that the lighting mask will be visible even if the source turf is not.
	var/datum/weakref/held_mask

/obj/effect/lighting_mask_holder/proc/assign_mask(atom/movable/lighting_mask/mask)
	vis_contents += mask
	held_mask = WEAKREF(mask)
	mask.holder = WEAKREF(src)

//Byond rendering is calculated based on whether or not the icon is visible.
//Simply scale our blank icon by the range
/obj/effect/lighting_mask_holder/proc/update_matrix(range)
	//transform = matrix(range, 0, 0, 0, range, 0)

/obj/effect/lighting_mask_holder/Destroy(force)
	var/atom/movable/lighting_mask/located = held_mask?.resolve()
	if(located)
		if(!located.destroying)
			return QDEL_HINT_LETMELIVE
		qdel(located)
		held_mask = null
	. = ..()

/obj/effect/lighting_mask_holder/Moved(atom/OldLoc, Dir)
	. = ..()
	var/atom/movable/lighting_mask/mask = held_mask.resolve()
	mask.calculate_lighting_shadows(OldLoc)
