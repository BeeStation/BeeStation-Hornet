//temporary visual effects
/obj/effect/temp_visual
	icon_state = "nothing"
	anchored = TRUE
	layer = ABOVE_MOB_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/duration = 10 //in deciseconds
	var/randomdir = TRUE
	var/heap_position
	VAR_PRIVATE/destroy_at
	VAR_PRIVATE/bumped = FALSE

/obj/effect/temp_visual/Initialize(mapload)
	destroy_at = world.time + duration
	SSeffects.join_temp_visual(src)
	. = ..()
	if(randomdir)
		setDir(pick(GLOB.cardinals))

/obj/effect/temp_visual/Destroy(force)
	. = ..()
	SSeffects.leave_temp_visual(src)

/obj/effect/temp_visual/singularity_act()
	return

/obj/effect/temp_visual/singularity_pull()
	return

/obj/effect/temp_visual/dir_setting
	randomdir = FALSE

/obj/effect/temp_visual/dir_setting/Initialize(mapload, set_dir)
	if(set_dir)
		setDir(set_dir)
	. = ..()

/obj/effect/temp_visual/proc/set_destroy_at_time(new_time)
	destroy_at = new_time
	bumped = TRUE
