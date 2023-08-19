//an "overlay" used by clockwork walls and floors to appear normal to mesons.
/obj/effect/clockwork/overlay
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/atom/linked

/obj/effect/clockwork/overlay/examine(mob/user)
	if(linked)
		return linked.examine(user)
	else
		return ..()

/obj/effect/clockwork/overlay/ex_act()
	return FALSE

/obj/effect/clockwork/overlay/singularity_act()
	return
/obj/effect/clockwork/overlay/singularity_pull()
	return

/obj/effect/clockwork/overlay/singularity_pull(S, current_size)
	return

/obj/effect/clockwork/overlay/Destroy()
	if(linked)
		linked = null
	. = ..()

/obj/effect/clockwork/overlay/wall
	name = "clockwork wall"
	icon_state = "clockwork_wall-0"
	base_icon_state = "clockwork_wall"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_BRASS_WALLS, SMOOTH_GROUP_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_BRASS_WALLS)
	icon_state = "clockwork_wall-0"
	layer = CLOSED_TURF_LAYER

/obj/effect/clockwork/overlay/wall/Initialize(mapload)
	. = ..()
	QUEUE_SMOOTH_NEIGHBORS(src)
	QUEUE_SMOOTH(src)

/obj/effect/clockwork/overlay/wall/Destroy()
	QUEUE_SMOOTH_NEIGHBORS(src)
	return ..()

/obj/effect/clockwork/overlay/floor
	icon = 'icons/turf/floors.dmi'
	icon_state = "clockwork_floor"
	layer = TURF_LAYER
	plane = FLOOR_PLANE

/obj/effect/clockwork/overlay/floor/bloodcult //this is used by BLOOD CULT, it shouldn't use such a path...
	icon_state = "cult"
