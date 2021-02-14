/obj/effect/lighting_mask_holder
	anchored = TRUE
	appearance_flags = 0	//Removes TILE_BOUND meaning that the lighting mask will be visible even if the source turf is not.
	var/datum/weakref/held_mask

/obj/effect/lighting_mask_holder/proc/assign_mask(atom/movable/lighting_mask/mask)
	vis_contents += mask
	held_mask = WEAKREF(mask)
	mask.holder = WEAKREF(src)

//This may be a bug with byond, but we can control when the vis_contents is rendered
//by updating this objects matrix with the item in vis_contents being on RESET_TRANSFORM.
//Because shadows extend further than the light source, we need to be able to order the light
//to stop rendering when it is out of view, and to do this we simple need to know the bounds
//of the mask (including shadow) and the bounds of the mask without the shadow.
/obj/effect/lighting_mask_holder/proc/update_matrix(actual_bound_top, actual_bound_bottom, actual_bound_left, actual_bound_right, radius)
	transform = matrix()

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
