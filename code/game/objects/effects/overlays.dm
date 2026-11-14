/obj/effect/overlay
	name = "overlay"

/obj/effect/overlay/singularity_act()
	return

/obj/effect/overlay/singularity_pull(obj/anomaly/singularity/singularity, current_size)
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

/obj/effect/overlay/thermite
	name = "thermite"
	desc = "Looks hot."
	icon = 'icons/effects/fire.dmi'
	icon_state = "medium" //what?
	anchored = TRUE
	plane = ABOVE_GAME_PLANE
	layer = FLY_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/overlay/vis
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE
	vis_flags = NONE
	var/unused = 0 //When detected to be unused it gets set to world.time, after a while it gets removed
	var/cache_expiration = 2 MINUTES // overlays which go unused for 2 minutes get cleaned up
	vis_flags = VIS_INHERIT_ID|VIS_INHERIT_PLANE

/obj/effect/overlay/vis/mob_alpha
	/// this separately exists because "mob_alpha_id" is to reference this single, but "mob_owner_ref" is to reference multiple things to a mob
	var/mob_owner_ref
	var/mob_alpha_id
	var/use_count = 0

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
	/// Multi-tile geometry slides in map space; single-tile doors stay upright.
	var/world_space_slide = FALSE

/obj/effect/overlay/airlock_part/proc/update_slide(airlock_state, open_speed)
	var/x_var = world_space_slide ? "pixel_x" : "pixel_w"
	var/y_var = world_space_slide ? "pixel_y" : "pixel_z"
	var/start_open = airlock_state == AIRLOCK_OPEN || airlock_state == AIRLOCK_CLOSING
	vars[x_var] = start_open ? open_px : 0
	vars[y_var] = start_open ? open_py : 0
	if(airlock_state != AIRLOCK_OPENING && airlock_state != AIRLOCK_CLOSING)
		return
	var/list/start = list(src, time = start_open ? open_speed - move_end_time : move_start_time, easing = CIRCULAR_EASING)
	start[x_var] = vars[x_var]
	start[y_var] = vars[y_var]
	var/list/finish = list(time = move_end_time - move_start_time, easing = CIRCULAR_EASING)
	finish[x_var] = start_open ? 0 : open_px
	finish[y_var] = start_open ? 0 : open_py
	animate(arglist(start))
	animate(arglist(finish))

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

/obj/effect/overlay/atmos_excited
	name = "excited group"
	icon = null
	icon_state = null
	anchored = TRUE  // should only appear in vis_contents, but to be safe
	appearance_flags = RESET_TRANSFORM | TILE_BOUND
	invisibility = INVISIBILITY_ABSTRACT
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	vis_flags = VIS_INHERIT_PLANE
	plane = ATMOS_GROUP_PLANE
	layer = ATMOS_GROUP_LAYER

/obj/effect/overlay/light_cone
	name = ""
	icon = 'icons/effects/light_overlays/light_cone.dmi'
	icon_state = "light"
	layer = O_LIGHTING_VISUAL_LAYER
	plane = O_LIGHTING_VISUAL_PLANE
	appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	vis_flags = NONE
	alpha = 110
