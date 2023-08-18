/obj/effect/overlay
	name = "overlay"

/obj/effect/overlay/singularity_act()
	return

/obj/effect/overlay/singularity_pull()
	return

/obj/effect/overlay/beam//Not actually a projectile, just an effect.
	name="beam"
	icon='icons/effects/beam.dmi'
	icon_state="b_beam"
	var/atom/BeamSource

/obj/effect/overlay/beam/Initialize(mapload)
	. = ..()
	QDEL_IN(src, 10)

/obj/effect/overlay/palmtree_r
	name = "palm tree"
	icon = 'icons/misc/beach2.dmi'
	icon_state = "palm1"
	density = TRUE
	layer = WALL_OBJ_LAYER
	anchored = TRUE

/obj/effect/overlay/palmtree_l
	name = "palm tree"
	icon = 'icons/misc/beach2.dmi'
	icon_state = "palm2"
	density = TRUE
	layer = WALL_OBJ_LAYER
	anchored = TRUE

/obj/effect/overlay/coconut
	gender = PLURAL
	name = "coconuts"
	icon = 'icons/misc/beach.dmi'
	icon_state = "coconuts"

/obj/effect/overlay/sparkles
	gender = PLURAL
	name = "sparkles"
	icon = 'icons/effects/effects.dmi'
	icon_state = "shieldsparkles"
	anchored = TRUE

/obj/effect/overlay/vis
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE
	vis_flags = NONE
	var/unused = 0 //When detected to be unused it gets set to world.time, after a while it gets removed
	var/cache_expiration = 2 MINUTES // overlays which go unused for 2 minutes get cleaned up
	vis_flags = VIS_INHERIT_ID|VIS_INHERIT_PLANE

/obj/effect/overlay/airlock_part
	anchored = TRUE
	plane = FLOAT_PLANE
	layer = FLOAT_LAYER - 1
	vis_flags = VIS_INHERIT_ID
	var/side_id
	var/open_px = 0
	var/open_py = 0
	var/move_start_time = 0 // for opening; closing uses reversed.
	var/move_end_time = 3.5
	var/aperture_angle = 0

/obj/effect/overlay/timer
	name = "timer overlay"
	icon = 'icons/effects/cooldown.dmi'
	icon_state = "second"

/obj/effect/overlay/closet_door
	anchored = TRUE
	plane = FLOAT_PLANE
	layer = FLOAT_LAYER
	vis_flags = VIS_INHERIT_ID
	appearance_flags = KEEP_TOGETHER | LONG_GLIDE | PIXEL_SCALE
